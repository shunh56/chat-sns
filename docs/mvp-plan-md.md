# mvp-plan.md - Tempo 1週間MVP実装計画

## 🎯 MVP成功基準

### 必達目標
- ✅ App Store / Google Play 申請可能な状態
- ✅ 100人規模のベータテスト可能
- ✅ コア機能の動作保証
- ✅ クラッシュ率 < 1%

### スコープ
**IN SCOPE**
- 電話番号認証
- リアルタイムステータス
- 基本マッチング
- 24時間タイマー
- シンプルチャット
- 応援スタンプ

**OUT OF SCOPE**
- 位置情報マッチング
- グループ機能
- イベント機能
- 課金機能
- 高度なAI推薦

---

## 📅 Day-by-Day実装スケジュール

### Day 0（準備日）: 日曜日

```bash
# 環境準備チェックリスト
✅ Flutter 3.x インストール確認
✅ Firebase プロジェクト確認
✅ IDE設定（VS Code / Android Studio）
✅ エミュレータ/実機準備
✅ Gitリポジトリ準備
✅ 必要な画像素材準備

# プロジェクト初期化
flutter create tempo --org com.yourcompany
cd tempo
flutter pub add firebase_core firebase_auth cloud_firestore
flutter pub add flutter_riverpod go_router gap
```

---

### Day 1: 月曜日（基盤構築）

#### 🎯 目標
- プロジェクトセットアップ完了
- 認証機能実装
- 基本的なUI骨格作成

#### 📝 タスク（8時間）

##### 9:00-11:00: プロジェクト基盤
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    ProviderScope(
      child: TempoApp(),
    ),
  );
}

class TempoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tempo',
      theme: TempoTheme.lightTheme,
      home: AuthWrapper(),
    );
  }
}
```

##### 11:00-13:00: テーマ設定
```dart
// lib/core/theme/tempo_theme.dart
class TempoTheme {
  static final lightTheme = ThemeData(
    primaryColor: const Color(0xFF4A90E2),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF4A90E2),
      secondary: const Color(0xFFFF6B35),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  );
}
```

##### 14:00-16:00: 認証実装
```dart
// lib/services/auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String) onCodeSent,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+81${phoneNumber.replaceAll('-', '')}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
```

##### 16:00-18:00: データモデル定義
```dart
// lib/models/tempo_user.dart
@freezed
class TempoUser with _$TempoUser {
  factory TempoUser({
    required String userId,
    required String name,
    String? imageUrl,
    required TempoStatus currentStatus,
    required bool isOnline,
  }) = _TempoUser;
}

@freezed
class TempoStatus with _$TempoStatus {
  factory TempoStatus({
    required String location,
    required String activity,
    required String mood,
    String? message,
    required DateTime updatedAt,
  }) = _TempoStatus;
}
```

#### ✅ Day 1 チェックポイント
- [ ] Firebase接続確認
- [ ] 電話番号認証動作
- [ ] 基本的なナビゲーション
- [ ] テーマ適用

---

### Day 2: 火曜日（メイン画面UI）

#### 🎯 目標
- ホーム画面完成
- ステータス更新UI
- プロフィール画面

#### 📝 タスク（8時間）

##### 9:00-12:00: ホーム画面
```dart
// lib/screens/home_screen.dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 自分のステータス表示
            MyStatusCard(user: currentUser),
            SizedBox(height: 20),
            
            // マッチング候補
            Expanded(
              child: MatchingCarousel(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TempoBottomNav(),
    );
  }
}
```

##### 13:00-15:00: ステータス更新画面
```dart
// lib/screens/status_update_screen.dart
class StatusUpdateScreen extends StatefulWidget {
  @override
  _StatusUpdateScreenState createState() => _StatusUpdateScreenState();
}

class _StatusUpdateScreenState extends State<StatusUpdateScreen> {
  int currentStep = 0;
  String? selectedLocation;
  String? selectedActivity;
  String? selectedMood;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ステータス更新')),
      body: PageView(
        children: [
          LocationStep(onSelect: (location) {
            setState(() => selectedLocation = location);
          }),
          ActivityStep(onSelect: (activity) {
            setState(() => selectedActivity = activity);
          }),
          MoodStep(onSelect: (mood) {
            setState(() => selectedMood = mood);
          }),
        ],
      ),
    );
  }
}
```

##### 15:00-18:00: UIコンポーネント作成
```dart
// lib/widgets/status_card.dart
class StatusCard extends StatelessWidget {
  final TempoStatus status;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFFFF6B35)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(getLocationIcon(status.location)),
              SizedBox(width: 8),
              Text(status.activity),
            ],
          ),
          Text(status.mood, style: TextStyle(fontSize: 32)),
          if (status.message != null)
            Text(status.message!),
        ],
      ),
    );
  }
}
```

---

### Day 3: 水曜日（マッチングロジック）

#### 🎯 目標
- マッチングアルゴリズム実装
- Firestore連携
- リアルタイム更新

#### 📝 タスク（8時間）

##### 9:00-12:00: マッチングサービス
```dart
// lib/services/matching_service.dart
class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<List<TempoUser>> findMatches(TempoUser currentUser) {
    return _firestore
        .collection('users')
        .where('tempo.currentStatus.activity', 
               isEqualTo: currentUser.currentStatus.activity)
        .where('isOnline', isEqualTo: true)
        .orderBy('tempo.currentStatus.updatedAt')
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TempoUser.fromFirestore(doc))
            .where((user) => user.userId != currentUser.userId)
            .toList());
  }
  
  double calculateCompatibility(TempoUser user1, TempoUser user2) {
    double score = 0.0;
    
    // 同じ活動: 50%
    if (user1.currentStatus.activity == user2.currentStatus.activity) {
      score += 0.5;
    }
    
    // 気分の相性: 30%
    if (areMoodsCompatible(user1.currentStatus.mood, 
                          user2.currentStatus.mood)) {
      score += 0.3;
    }
    
    // 時間の近さ: 20%
    final timeDiff = user1.currentStatus.updatedAt
        .difference(user2.currentStatus.updatedAt)
        .inMinutes.abs();
    if (timeDiff < 30) {
      score += 0.2 * (1 - timeDiff / 30);
    }
    
    return score;
  }
}
```

##### 13:00-16:00: マッチングUI
```dart
// lib/widgets/matching_carousel.dart
class MatchingCarousel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchingProvider);
    
    return matches.when(
      data: (users) => PageView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return MatchCard(user: users[index]);
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('エラーが発生しました'),
    );
  }
}
```

##### 16:00-18:00: Provider設定
```dart
// lib/providers/matching_provider.dart
final matchingProvider = StreamProvider<List<TempoUser>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final matchingService = ref.watch(matchingServiceProvider);
  
  return matchingService.findMatches(currentUser);
});
```

---

### Day 4: 木曜日（24時間タイマー）

#### 🎯 目標
- 接続管理システム
- タイマー実装
- 延長機能

#### 📝 タスク（8時間）

##### 9:00-12:00: 接続管理
```dart
// lib/services/connection_service.dart
class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<String> createConnection(String userId1, String userId2) async {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(hours: 24));
    
    final doc = await _firestore.collection('tempoConnections').add({
      'users': [userId1, userId2],
      'startedAt': now,
      'expiresAt': expiresAt,
      'status': 'active',
      'extensionCount': 0,
    });
    
    // スケジューラー設定（Cloud Functions側で処理）
    await _scheduleExpiration(doc.id, expiresAt);
    
    return doc.id;
  }
  
  Future<void> extendConnection(String connectionId) async {
    final doc = await _firestore
        .collection('tempoConnections')
        .doc(connectionId)
        .get();
    
    final data = doc.data()!;
    if (data['extensionCount'] < 4) {
      await doc.reference.update({
        'expiresAt': DateTime.now().add(Duration(hours: 24)),
        'extensionCount': FieldValue.increment(1),
        'status': 'extended',
      });
    }
  }
}
```

##### 13:00-16:00: タイマーWidget
```dart
// lib/widgets/connection_timer.dart
class ConnectionTimer extends StatelessWidget {
  final DateTime expiresAt;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: Stream.periodic(Duration(seconds: 1), (_) {
        return expiresAt.difference(DateTime.now()).inSeconds;
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data! <= 0) {
          return Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('期限切れ', style: TextStyle(color: Colors.white)),
          );
        }
        
        final duration = Duration(seconds: snapshot.data!);
        final hours = duration.inHours;
        final minutes = duration.inMinutes % 60;
        final isWarning = hours < 1;
        
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isWarning ? Colors.orange : Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '残り ${hours}時間${minutes}分',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
```

---

### Day 5: 金曜日（チャット機能）

#### 🎯 目標
- メッセージ送受信
- 応援スタンプ
- リアルタイム同期

#### 📝 タスク（8時間）

##### 9:00-12:00: チャット基盤
```dart
// lib/screens/chat_screen.dart
class ChatScreen extends ConsumerWidget {
  final String connectionId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionProvider(connectionId));
    final messages = ref.watch(messagesProvider(connectionId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(connection.otherUser.name),
        actions: [
          ConnectionTimer(expiresAt: connection.expiresAt),
        ],
      ),
      body: Column(
        children: [
          if (connection.isExpiringSoon)
            ExtensionBanner(
              onExtend: () => _extendConnection(connectionId),
            ),
          
          Expanded(
            child: MessageList(messages: messages),
          ),
          
          if (!connection.isExpired)
            MessageInput(
              onSend: (text) => _sendMessage(text),
              onStamp: (type) => _sendStamp(type),
            ),
        ],
      ),
    );
  }
}
```

##### 13:00-16:00: 応援スタンプ
```dart
// lib/widgets/encouragement_bar.dart
class EncouragementBar extends StatelessWidget {
  final Function(String) onSend;
  
  final stamps = [
    {'type': 'energy', 'emoji': '⚡', 'text': 'がんばれ！'},
    {'type': 'relax', 'emoji': '🌙', 'text': 'お疲れ様'},
    {'type': 'empathy', 'emoji': '🎯', 'text': 'それな！'},
    {'type': 'praise', 'emoji': '✨', 'text': '天才！'},
    {'type': 'cheer', 'emoji': '💪', 'text': '大丈夫'},
  ];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stamps.map((stamp) {
          return IconButton(
            onPressed: () => onSend(stamp['type']!),
            icon: Text(stamp['emoji']!, style: TextStyle(fontSize: 24)),
          );
        }).toList(),
      ),
    );
  }
}
```

---

### Day 6: 土曜日（最終調整）

#### 🎯 目標
- バグ修正
- パフォーマンス改善
- UI調整

#### 📝 タスク（8時間）

##### 9:00-12:00: バグ修正
```dart
// エラーハンドリング追加
try {
  await matchingService.findMatches(currentUser);
} catch (e) {
  showSnackBar(context, 'マッチングエラーが発生しました');
  FirebaseCrashlytics.instance.recordError(e, null);
}
```

##### 13:00-15:00: パフォーマンス最適化
```dart
// 画像キャッシュ
CachedNetworkImage(
  imageUrl: user.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
);

// Firestoreキャッシュ
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

##### 15:00-18:00: 最終テスト
```dart
// test/integration_test.dart
void main() {
  testWidgets('Full app flow test', (WidgetTester tester) async {
    await tester.pumpWidget(TempoApp());
    
    // 認証
    await tester.enterText(find.byType(TextField), '09012345678');
    await tester.tap(find.text('送信'));
    await tester.pump();
    
    // ステータス更新
    await tester.tap(find.text('家'));
    await tester.tap(find.text('暇'));
    await tester.tap(find.text('😊'));
    
    // マッチング
    expect(find.byType(MatchCard), findsWidgets);
  });
}
```

---

### Day 7: 日曜日（リリース準備）

#### 🎯 目標
- ストア申請準備
- ドキュメント整備
- 最終確認

#### 📝 タスク（8時間）

##### 9:00-12:00: ビルド作成
```bash
# iOS
flutter build ios --release
open ios/Runner.xcworkspace
# Archive → Distribute App

# Android
flutter build appbundle --release
# Google Play Console でアップロード
```

##### 13:00-15:00: ストア情報準備
- アプリ名: Tempo
- 説明文: 今この瞬間を共有する新しいSNS
- スクリーンショット: 5枚以上
- アイコン: 1024x1024
- プライバシーポリシーURL
- 利用規約URL

##### 15:00-18:00: 最終チェック
- [ ] クラッシュなく動作
- [ ] 全機能テスト完了
- [ ] ストア申請完了
- [ ] バックアップ作成

---

## 🚀 デプロイ手順

### Firebase設定
```bash
# Firestore ルール
firebase deploy --only firestore:rules

# Cloud Functions
firebase deploy --only functions

# インデックス
firebase deploy --only firestore:indexes
```

### 環境変数
```dart
// lib/config/env.dart
class Environment {
  static const String apiKey = String.fromEnvironment('API_KEY');
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
}
```

---

## 🐛 トラブルシューティング

### よくある問題と解決策

#### 認証が動かない
```dart
// iOS: Info.plist に追加
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>

// Android: SHA-1 fingerprint を Firebase に追加
keytool -list -v -keystore ~/.android/debug.keystore
```

#### Firestoreエラー
```dart
// インデックスエラー
// Firebase Console で自動作成リンクをクリック

// 権限エラー
// Security Rules を確認
```

---

## ✅ MVP完成チェックリスト

### 必須機能
- [ ] ユーザー登録/認証
- [ ] プロフィール作成
- [ ] ステータス更新
- [ ] マッチング表示
- [ ] 24時間接続作成
- [ ] チャット送受信
- [ ] タイマー表示
- [ ] 延長機能
- [ ] 応援スタンプ

### 品質基準
- [ ] クラッシュ率 < 1%
- [ ] 主要フロー完走率 > 90%
- [ ] レスポンス時間 < 3秒

### リリース準備
- [ ] App Store申請
- [ ] Google Play申請
- [ ] プライバシーポリシー
- [ ] 利用規約
- [ ] サポート連絡先

---

**このMVP計画を1週間で完遂します！**
**毎日の進捗を記録し、問題があれば即座に対処してください。**

**開始日**: 2025/01/XX
**完了予定**: 2025/01/XX
