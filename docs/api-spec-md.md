# api-spec.md - Tempo API仕様書

## 📚 API概要

TempoアプリのFirebase Cloud Functions APIおよびクライアント側のサービス層仕様

### エンドポイント構成
```
https://asia-northeast1-tempo-app.cloudfunctions.net/
├── auth/                    # 認証関連
├── users/                   # ユーザー管理
├── matching/                # マッチング
├── connections/             # 24時間接続
├── chat/                    # チャット
├── encouragements/          # 応援システム
└── admin/                   # 管理機能
```

---

## 🔐 認証API

### POST /auth/sendOTP
電話番号認証のOTP送信

#### Request
```typescript
{
  phoneNumber: string;  // "+819012345678"
  recaptchaToken?: string;
}
```

#### Response
```typescript
{
  success: boolean;
  verificationId: string;
  message: string;
}
```

#### Cloud Function実装
```typescript
// functions/src/auth/sendOTP.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const sendOTP = functions
  .region('asia-northeast1')
  .https.onCall(async (data, context) => {
    const { phoneNumber } = data;
    
    // レート制限チェック
    const rateLimitKey = `otp_${phoneNumber}`;
    const attempts = await checkRateLimit(rateLimitKey);
    if (attempts > 5) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Too many attempts. Please try again later.'
      );
    }
    
    // 電話番号バリデーション
    if (!isValidJapanesePhone(phoneNumber)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Invalid phone number format'
      );
    }
    
    // Firebase Auth でOTP送信処理
    // クライアント側で処理するため、ここではレート制限のみ
    await incrementRateLimit(rateLimitKey);
    
    return {
      success: true,
      message: 'OTP sent successfully'
    };
  });
```

### POST /auth/verifyOTP
OTP検証と認証完了

#### Request
```typescript
{
  verificationId: string;
  otp: string;  // "123456"
}
```

#### Response
```typescript
{
  success: boolean;
  token: string;
  userId: string;
  isNewUser: boolean;
}
```

---

## 👤 ユーザー管理API

### GET /users/profile
ユーザープロフィール取得

#### Flutter Service実装
```dart
// lib/services/user_service.dart
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<TempoUser?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get();
    
    if (!doc.exists) return null;
    
    return TempoUser.fromFirestore(doc);
  }
  
  Stream<TempoUser?> watchCurrentUser() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists 
            ? TempoUser.fromFirestore(doc) 
            : null);
  }
}
```

### PUT /users/profile
プロフィール更新

#### Request
```dart
class UpdateProfileRequest {
  final String? name;
  final String? imageUrl;
  final Map<String, dynamic>? tempoPreference;
  
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (tempoPreference != null) 'tempo.preference': tempoPreference,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
```

#### Flutter実装
```dart
Future<void> updateProfile(UpdateProfileRequest request) async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) throw Exception('Not authenticated');
  
  await _firestore
      .collection('users')
      .doc(uid)
      .update(request.toJson());
}
```

### POST /users/status
ステータス更新

#### Request
```dart
class UpdateStatusRequest {
  final String location;     // "home" | "work" | "cafe" | "transit" | "other"
  final String activity;     // "studying" | "working" | "netflix" | "gaming" | "hima"
  final String mood;         // "😊" | "😪" | "😎" | "🥺" | "😤" | "🤔"
  final String? message;     // Max 20 characters
  
  Map<String, dynamic> toJson() => {
    'tempo.currentStatus': {
      'location': location,
      'activity': activity,
      'mood': mood,
      'message': message,
      'updatedAt': FieldValue.serverTimestamp(),
    },
    'lastOpenedAt': FieldValue.serverTimestamp(),
  };
}
```

#### バリデーション
```dart
void validateStatusUpdate(UpdateStatusRequest request) {
  // 場所バリデーション
  const validLocations = ['home', 'work', 'cafe', 'transit', 'other'];
  if (!validLocations.contains(request.location)) {
    throw ValidationException('Invalid location');
  }
  
  // アクティビティバリデーション
  const validActivities = ['studying', 'working', 'netflix', 'gaming', 'hima'];
  if (!validActivities.contains(request.activity)) {
    throw ValidationException('Invalid activity');
  }
  
  // 気分バリデーション
  const validMoods = ['😊', '😪', '😎', '🥺', '😤', '🤔'];
  if (!validMoods.contains(request.mood)) {
    throw ValidationException('Invalid mood');
  }
  
  // メッセージ長バリデーション
  if (request.message != null && request.message!.length > 20) {
    throw ValidationException('Message too long');
  }
}
```

---

## 🤝 マッチングAPI

### GET /matching/candidates
マッチング候補取得

#### Flutter Service実装
```dart
// lib/services/matching_service.dart
class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<List<MatchCandidate>> getMatchCandidates({
    required TempoUser currentUser,
    int limit = 10,
  }) {
    return _firestore
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .where('tempo.currentStatus.activity', 
               isEqualTo: currentUser.currentStatus.activity)
        .orderBy('tempo.currentStatus.updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
          final users = snapshot.docs
              .map((doc) => TempoUser.fromFirestore(doc))
              .where((user) => user.userId != currentUser.userId)
              .toList();
          
          // スコア計算
          final candidates = users.map((user) {
            final score = calculateCompatibility(currentUser, user);
            return MatchCandidate(user: user, score: score);
          }).toList();
          
          // スコア順にソート
          candidates.sort((a, b) => b.score.compareTo(a.score));
          
          return candidates;
        });
  }
  
  double calculateCompatibility(TempoUser user1, TempoUser user2) {
    double score = 0.0;
    
    // アクティビティマッチ（50%）
    if (user1.currentStatus.activity == user2.currentStatus.activity) {
      score += 0.5;
    }
    
    // 気分の相性（30%）
    final moodScore = getMoodCompatibility(
      user1.currentStatus.mood,
      user2.currentStatus.mood,
    );
    score += moodScore * 0.3;
    
    // 時間の近さ（20%）
    final timeDiff = user1.currentStatus.updatedAt
        .difference(user2.currentStatus.updatedAt)
        .inMinutes.abs();
    if (timeDiff < 30) {
      score += (1 - timeDiff / 30) * 0.2;
    }
    
    // ランダム要素（±10%）
    final random = Random().nextDouble() * 0.2 - 0.1;
    score = (score + random).clamp(0.0, 1.0);
    
    return score;
  }
}
```

### POST /matching/connect
接続リクエスト送信

#### Request
```dart
class ConnectRequest {
  final String targetUserId;
  final String? message;
  
  Map<String, dynamic> toJson() => {
    'targetUserId': targetUserId,
    'message': message,
    'requestedAt': FieldValue.serverTimestamp(),
  };
}
```

#### Cloud Function実装
```typescript
// functions/src/matching/connect.ts
export const connect = functions
  .region('asia-northeast1')
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { targetUserId, message } = data;
    const currentUserId = context.auth.uid;
    
    // 既存接続チェック
    const existingConnection = await db
      .collection('tempoConnections')
      .where('users', 'array-contains', currentUserId)
      .where('status', 'in', ['active', 'extended'])
      .get();
    
    const hasConnectionWithTarget = existingConnection.docs.some(doc => {
      const users = doc.data().users;
      return users.includes(targetUserId);
    });
    
    if (hasConnectionWithTarget) {
      throw new functions.https.HttpsError(
        'already-exists',
        'Connection already exists'
      );
    }
    
    // 接続作成
    const connectionRef = await db.collection('tempoConnections').add({
      users: [currentUserId, targetUserId],
      startedAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 24 * 60 * 60 * 1000)
      ),
      status: 'active',
      extensionCount: 0,
      matchingInfo: {
        message: message,
      },
    });
    
    // 通知送信
    await sendConnectionNotification(targetUserId, currentUserId);
    
    return {
      success: true,
      connectionId: connectionRef.id,
    };
  });
```

---

## ⏰ 24時間接続API

### GET /connections/active
アクティブな接続一覧

#### Flutter実装
```dart
Stream<List<TempoConnection>> getActiveConnections() {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  
  return _firestore
      .collection('tempoConnections')
      .where('users', arrayContains: uid)
      .where('status', whereIn: ['active', 'extended'])
      .orderBy('startedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TempoConnection.fromFirestore(doc))
          .toList());
}
```

### POST /connections/{connectionId}/extend
接続延長リクエスト

#### Cloud Function実装
```typescript
export const extendConnection = functions
  .region('asia-northeast1')
  .https.onCall(async (data, context) => {
    const { connectionId } = data;
    const userId = context.auth?.uid;
    
    if (!userId) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const connectionRef = db.collection('tempoConnections').doc(connectionId);
    const connection = await connectionRef.get();
    
    if (!connection.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Connection not found'
      );
    }
    
    const connectionData = connection.data()!;
    
    // ユーザーが接続のメンバーか確認
    if (!connectionData.users.includes(userId)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Not a member of this connection'
      );
    }
    
    // 延長回数チェック
    if (connectionData.extensionCount >= 4) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Maximum extensions reached'
      );
    }
    
    // 延長処理
    const newExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
    
    await connectionRef.update({
      expiresAt: admin.firestore.Timestamp.fromDate(newExpiresAt),
      extensionCount: admin.firestore.FieldValue.increment(1),
      status: 'extended',
      [`extension.${userId}`]: true,
    });
    
    // 両者が同意した場合のみ延長
    const updatedConnection = await connectionRef.get();
    const extensionData = updatedConnection.data()!.extension || {};
    const allUsersAgreed = connectionData.users.every(
      (uid: string) => extensionData[uid] === true
    );
    
    if (allUsersAgreed) {
      await connectionRef.update({
        'extension': admin.firestore.FieldValue.delete(),
      });
      
      // 通知送信
      const otherUserId = connectionData.users.find(
        (uid: string) => uid !== userId
      );
      await sendExtensionNotification(otherUserId);
    }
    
    return {
      success: true,
      extended: allUsersAgreed,
    };
  });
```

---

## 💬 チャットAPI

### GET /chat/{connectionId}/messages
メッセージ取得

#### Flutter実装
```dart
Stream<List<ChatMessage>> getMessages(String connectionId) {
  return _firestore
      .collection('tempoConnections')
      .doc(connectionId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList());
}
```

### POST /chat/{connectionId}/send
メッセージ送信

#### Request
```dart
class SendMessageRequest {
  final String text;
  final String? replyTo;
  
  Map<String, dynamic> toJson() => {
    'text': text,
    'senderId': FirebaseAuth.instance.currentUser!.uid,
    'createdAt': FieldValue.serverTimestamp(),
    'type': 'text',
    if (replyTo != null) 'replyTo': replyTo,
  };
}
```

#### Flutter実装
```dart
Future<void> sendMessage(
  String connectionId,
  SendMessageRequest request,
) async {
  // 接続の有効性チェック
  final connection = await _firestore
      .collection('tempoConnections')
      .doc(connectionId)
      .get();
  
  if (!connection.exists) {
    throw Exception('Connection not found');
  }
  
  final connectionData = connection.data()!;
  final expiresAt = (connectionData['expiresAt'] as Timestamp).toDate();
  
  if (DateTime.now().isAfter(expiresAt)) {
    throw Exception('Connection has expired');
  }
  
  // メッセージ送信
  await _firestore
      .collection('tempoConnections')
      .doc(connectionId)
      .collection('messages')
      .add(request.toJson());
  
  // 最終メッセージ更新
  await _firestore
      .collection('tempoConnections')
      .doc(connectionId)
      .update({
    'lastMessage': request.text,
    'lastMessageAt': FieldValue.serverTimestamp(),
    'interaction.messageCount': FieldValue.increment(1),
  });
}
```

---

## ⚡ 応援システムAPI

### POST /encouragements/send
応援スタンプ送信

#### Request
```dart
class SendEncouragementRequest {
  final String toUserId;
  final String connectionId;
  final String type;  // "energy" | "relax" | "empathy" | "praise" | "cheer"
  
  Map<String, dynamic> toJson() => {
    'fromUserId': FirebaseAuth.instance.currentUser!.uid,
    'toUserId': toUserId,
    'connectionId': connectionId,
    'type': type,
    'createdAt': FieldValue.serverTimestamp(),
    'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
  };
}
```

#### Cloud Function実装
```typescript
export const sendEncouragement = functions
  .region('asia-northeast1')
  .https.onCall(async (data, context) => {
    const userId = context.auth?.uid;
    if (!userId) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }
    
    const { toUserId, connectionId, type } = data;
    
    // 1日の制限チェック
    const today = new Date().toISOString().split('T')[0];
    const dailyCount = await db
      .collection('encouragements')
      .where('fromUserId', '==', userId)
      .where('date', '==', today)
      .get();
    
    if (dailyCount.size >= 3) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Daily encouragement limit reached'
      );
    }
    
    // 応援送信
    await db.collection('encouragements').add({
      fromUserId: userId,
      toUserId: toUserId,
      connectionId: connectionId,
      type: type,
      emoji: getEmojiForType(type),
      message: getMessageForType(type),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      date: today,
    });
    
    // ユーザー統計更新
    await db.collection('users').doc(userId).update({
      'tempo.stats.encouragementSent': admin.firestore.FieldValue.increment(1),
      'tempo.dailyLimits.encouragementsUsed': admin.firestore.FieldValue.increment(1),
    });
    
    await db.collection('users').doc(toUserId).update({
      'tempo.stats.encouragementReceived': admin.firestore.FieldValue.increment(1),
    });
    
    // プッシュ通知
    await sendEncouragementNotification(toUserId, type);
    
    return { success: true };
  });

function getEmojiForType(type: string): string {
  const emojis: { [key: string]: string } = {
    'energy': '⚡',
    'relax': '🌙',
    'empathy': '🎯',
    'praise': '✨',
    'cheer': '💪',
  };
  return emojis[type] || '👍';
}

function getMessageForType(type: string): string {
  const messages: { [key: string]: string } = {
    'energy': 'がんばれ！',
    'relax': 'お疲れ様',
    'empathy': 'それな！',
    'praise': '天才！',
    'cheer': '大丈夫',
  };
  return messages[type] || '応援してます';
}
```

---

## 🔔 通知API

### POST /notifications/register
FCMトークン登録

#### Request
```dart
class RegisterTokenRequest {
  final String token;
  final String platform;  // "ios" | "android"
  
  Future<void> register() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'fcmToken': token,
      'platform': platform,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}
```

### 通知送信関数
```typescript
// functions/src/notifications/send.ts
async function sendNotification(
  userId: string,
  title: string,
  body: string,
  data?: { [key: string]: string }
) {
  const userDoc = await db.collection('users').doc(userId).get();
  const userData = userDoc.data();
  
  if (!userData?.fcmToken) {
    console.log('No FCM token for user:', userId);
    return;
  }
  
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data || {},
    token: userData.fcmToken,
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
    android: {
      priority: 'high' as const,
      notification: {
        sound: 'default',
        priority: 'high' as const,
      },
    },
  };
  
  try {
    await admin.messaging().send(message);
    console.log('Notification sent successfully');
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}
```

---

## 🛡 エラーハンドリング

### エラーコード一覧

| コード | 説明 | HTTPステータス |
|--------|------|---------------|
| `unauthenticated` | 認証が必要 | 401 |
| `permission-denied` | 権限がない | 403 |
| `not-found` | リソースが見つからない | 404 |
| `already-exists` | 既に存在する | 409 |
| `resource-exhausted` | 制限に達した | 429 |
| `invalid-argument` | 不正なパラメータ | 400 |
| `internal` | サーバーエラー | 500 |

### Flutter側エラーハンドリング
```dart
class ApiException implements Exception {
  final String code;
  final String message;
  
  ApiException(this.code, this.message);
  
  String get userMessage {
    switch (code) {
      case 'unauthenticated':
        return 'ログインが必要です';
      case 'permission-denied':
        return 'この操作は許可されていません';
      case 'not-found':
        return '見つかりませんでした';
      case 'already-exists':
        return '既に存在します';
      case 'resource-exhausted':
        return '制限に達しました。しばらくお待ちください';
      case 'invalid-argument':
        return '入力内容を確認してください';
      default:
        return 'エラーが発生しました';
    }
  }
}

// 使用例
try {
  await matchingService.connect(userId);
} on FirebaseFunctionsException catch (e) {
  final apiError = ApiException(e.code, e.message ?? '');
  showSnackBar(context, apiError.userMessage);
} catch (e) {
  showSnackBar(context, 'エラーが発生しました');
}
```

---

## 📊 レート制限

### 制限設定
```typescript
const rateLimits = {
  'otp_send': { max: 5, window: 3600 },        // 1時間に5回
  'status_update': { max: 60, window: 3600 },  // 1時間に60回
  'message_send': { max: 100, window: 3600 },  // 1時間に100回
  'encouragement': { max: 3, window: 86400 },  // 1日3回
  'connection_create': { max: 10, window: 86400 }, // 1日10回
};
```

### レート制限実装
```typescript
async function checkRateLimit(
  key: string,
  type: keyof typeof rateLimits
): Promise<boolean> {
  const limit = rateLimits[type];
  const now = Date.now();
  const windowStart = now - (limit.window * 1000);
  
  const ref = db.collection('rateLimits').doc(`${type}_${key}`);
  const doc = await ref.get();
  
  if (!doc.exists) {
    await ref.set({
      attempts: [now],
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return true;
  }
  
  const data = doc.data()!;
  const recentAttempts = data.attempts.filter(
    (timestamp: number) => timestamp > windowStart
  );
  
  if (recentAttempts.length >= limit.max) {
    return false;
  }
  
  recentAttempts.push(now);
  await ref.update({
    attempts: recentAttempts,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  return true;
}
```

---

## 🔒 セキュリティ

### 認証チェック
```typescript
function requireAuth(context: functions.https.CallableContext) {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Authentication required'
    );
  }
  return context.auth.uid;
}
```

### 入力検証
```typescript
function validateInput<T>(
  data: any,
  schema: { [K in keyof T]: (value: any) => boolean }
): T {
  const errors: string[] = [];
  
  for (const [key, validator] of Object.entries(schema)) {
    if (!validator(data[key])) {
      errors.push(`Invalid ${key}`);
    }
  }
  
  if (errors.length > 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      errors.join(', ')
    );
  }
  
  return data as T;
}

// 使用例
const validated = validateInput<{ phoneNumber: string }>(data, {
  phoneNumber: (v) => typeof v === 'string' && /^\+81\d{10,11}$/.test(v),
});
```

---

## 📈 モニタリング

### ログ記録
```typescript
function logApiCall(
  functionName: string,
  userId: string,
  params: any,
  result: 'success' | 'error',
  error?: any
) {
  const log = {
    functionName,
    userId,
    params: JSON.stringify(params),
    result,
    error: error?.message || null,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  };
  
  // Firestore に記録
  db.collection('apiLogs').add(log);
  
  // Cloud Logging
  if (result === 'error') {
    console.error('API Error:', log);
  } else {
    console.log('API Call:', log);
  }
}
```

---

**このAPI仕様書は継続的に更新されます。**
**新機能追加時は必ずこのドキュメントも更新してください。**

**作成日**: 2025/01/XX
**最終更新**: 2025/01/XX
**バージョン**: 1.0.0
