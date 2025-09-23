# database.md - Tempoデータベース設計書

## 📊 Firestore構造概要

既存BLANKアプリのFirestore構造を活用しつつ、Tempo用に改修・拡張

```
firestore/
├── users/                    # ユーザー情報（既存改修）
├── tempoConnections/         # 24時間接続（新規）
├── encouragements/           # 応援履歴（新規）
├── tempoEvents/             # イベント（新規）
├── direct_messages/         # DM（既存活用）
└── systemConfig/            # システム設定（新規）
```

---

## 👤 Users コレクション（改修）

### 既存フィールドの活用と変更

```javascript
// users/{userId}
{
  // ===== 基本情報（既存活用） =====
  "userId": string,              // ドキュメントID
  "name": string,                // 表示名
  "username": string,            // ユーザー名（ユニーク）
  "imageUrl": string | null,     // プロフィール画像
  "isOnline": boolean,           // オンラインステータス
  "lastOpenedAt": timestamp,     // 最終アクセス
  "createdAt": timestamp,        // 作成日時
  
  // ===== Tempo専用フィールド（新規追加） =====
  "tempo": {
    "currentStatus": {
      "location": string,        // "home" | "work" | "cafe" | "transit" | "other"
      "activity": string,        // "studying" | "working" | "netflix" | "gaming" | "hima"
      "mood": string,            // "😊" | "😪" | "😎" | "🥺" | "😤" | "🤔"
      "message": string | null,  // 20文字制限
      "updatedAt": timestamp     // 更新時刻
    },
    
    "preference": {
      "ageRangeMin": number,     // マッチング年齢下限
      "ageRangeMax": number,     // マッチング年齢上限
      "locationRange": string,   // "area" | "prefecture" | "region" | "all"
      "autoAccept": boolean,     // 自動承認
      "timeType": string,        // "morning" | "night" | "both"
      "activityLevel": string    // "active" | "moderate" | "relaxed"
    },
    
    "stats": {
      "totalConnections": number,    // 総接続数（表示しない）
      "currentConnections": number,  // 現在の接続数（表示しない）
      "weeklyActivity": map,         // 曜日別アクティビティ
      "encouragementSent": number,   // 送った応援数（表示しない）
      "encouragementReceived": number // もらった応援数（表示しない）
    },
    
    "badges": string[],              // 獲得バッジリスト
    "dailyLimits": {
      "encouragementsUsed": number,  // 今日使った応援数
      "lastResetAt": timestamp       // 最終リセット時刻
    }
  },
  
  // ===== 既存フィールド（非表示化） =====
  // これらは削除せず、UIで参照しないだけ
  "friendIds": string[],         // 非表示
  "followerCount": number,        // 非表示
  "followingCount": number,       // 非表示
  
  // ===== プライバシー設定（改修） =====
  "privacy": {
    "ageVisible": boolean,         // 年齢表示
    "locationPrecision": string,   // "exact" | "area" | "prefecture"
    "allowMessages": string,       // "all" | "connections" | "none"
    "blockList": string[]          // ブロックユーザーID
  },
  
  // ===== 安全機能（新規） =====
  "safety": {
    "isMinor": boolean,            // 未成年フラグ
    "parentalControl": boolean,    // 保護者管理有効
    "reportCount": number,         // 通報された回数
    "lastReportAt": timestamp | null
  }
}
```

### インデックス設定
```javascript
// 複合インデックス
[
  ["tempo.currentStatus.activity", "tempo.currentStatus.updatedAt"],
  ["tempo.currentStatus.mood", "isOnline"],
  ["createdAt", "isOnline"],
  ["tempo.preference.ageRangeMin", "tempo.preference.ageRangeMax"]
]
```

---

## 🤝 TempoConnections コレクション（新規）

24時間限定の接続を管理

```javascript
// tempoConnections/{connectionId}
{
  "connectionId": string,          // ドキュメントID（自動生成）
  "users": string[],               // [userId1, userId2]
  "userDetails": [                // ユーザー詳細（キャッシュ）
    {
      "userId": string,
      "name": string,
      "imageUrl": string | null
    }
  ],
  
  "status": string,                // "active" | "extended" | "expired" | "archived"
  "startedAt": timestamp,          // 接続開始時刻
  "expiresAt": timestamp,          // 期限切れ時刻
  
  "matchingInfo": {
    "commonActivity": string,       // 共通の活動
    "commonMood": string,           // 共通の気分
    "matchScore": number,           // マッチングスコア（0-1）
    "isRandom": boolean             // ランダムマッチングか
  },
  
  "extension": {
    "count": number,                // 延長回数（0-4）
    "lastExtendedAt": timestamp | null,
    "pendingRequests": string[]     // 延長リクエスト中のユーザーID
  },
  
  "interaction": {
    "messageCount": number,         // メッセージ数
    "lastMessageAt": timestamp | null,
    "encouragementCount": number    // 応援数
  },
  
  "metadata": {
    "createdAt": timestamp,
    "updatedAt": timestamp,
    "endedReason": string | null    // "expired" | "manual" | "blocked"
  }
}
```

### サブコレクション: messages
```javascript
// tempoConnections/{connectionId}/messages/{messageId}
{
  "messageId": string,
  "senderId": string,
  "type": string,                  // "text" | "encouragement" | "system"
  "content": {
    "text": string | null,         // テキストメッセージ
    "stampType": string | null,    // スタンプタイプ
    "systemMessage": string | null // システムメッセージ
  },
  "createdAt": timestamp,
  "isRead": boolean
}
```

---

## ⚡ Encouragements コレクション（新規）

応援（推し合い）の履歴

```javascript
// encouragements/{encouragementId}
{
  "encouragementId": string,       // ドキュメントID
  "fromUserId": string,            // 送信者
  "toUserId": string,              // 受信者
  "connectionId": string,          // 関連する接続ID
  
  "type": string,                  // "energy" | "relax" | "empathy" | "praise" | "cheer"
  "emoji": string,                 // "⚡" | "🌙" | "🎯" | "✨" | "💪"
  "message": string,               // "がんばれ！" など
  
  "createdAt": timestamp,
  "date": string                   // "2025-01-20" 形式（集計用）
}
```

---

## 🎉 TempoEvents コレクション（将来実装）

```javascript
// tempoEvents/{eventId}
{
  "eventId": string,
  "title": string,
  "description": string,
  "type": string,                  // "online" | "offline" | "hybrid"
  
  "schedule": {
    "startTime": timestamp,
    "endTime": timestamp,
    "timezone": string
  },
  
  "location": {
    "type": string,                // "online" | "physical"
    "venue": string | null,        // 会場名
    "address": string | null,      // 住所
    "url": string | null           // オンラインURL
  },
  
  "capacity": {
    "min": number,
    "max": number,
    "current": number
  },
  
  "participants": string[],        // 参加者ID
  "waitlist": string[],            // キャンセル待ち
  
  "pricing": {
    "amount": number,
    "currency": string,
    "type": string                 // "free" | "paid" | "donation"
  },
  
  "status": string,                // "draft" | "published" | "ongoing" | "completed" | "cancelled"
  "createdBy": string,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

---

## 🔧 SystemConfig コレクション（新規）

システム全体の設定値

```javascript
// systemConfig/settings
{
  "maintenance": {
    "isEnabled": boolean,
    "message": string,
    "startTime": timestamp | null,
    "endTime": timestamp | null
  },
  
  "limits": {
    "dailyEncouragements": number,  // 3
    "maxExtensions": number,        // 4
    "connectionDuration": number,   // 24 (hours)
    "messageLength": number,        // 20
    "minAge": number,              // 13
    "curfewStart": number,         // 22 (時)
    "curfewEnd": number            // 6 (時)
  },
  
  "features": {
    "locationMatching": boolean,
    "groupChat": boolean,
    "events": boolean,
    "premium": boolean
  },
  
  "version": {
    "current": string,
    "minimum": string,
    "forceUpdate": boolean
  }
}
```

---

## 🔄 既存データ移行計画

### Phase 1: 初期移行（Day 1）

```javascript
// Cloud Function: migrateUsersToTempo
exports.migrateUsersToTempo = functions.https.onCall(async (data, context) => {
  const batch = firestore.batch();
  const usersSnapshot = await firestore.collection('users').get();
  
  usersSnapshot.forEach(doc => {
    const user = doc.data();
    const tempoData = {
      tempo: {
        currentStatus: {
          location: 'home',
          activity: 'hima',
          mood: '😊',
          message: null,
          updatedAt: FieldValue.serverTimestamp()
        },
        preference: {
          ageRangeMin: 18,
          ageRangeMax: 35,
          locationRange: 'all',
          autoAccept: false,
          timeType: 'both',
          activityLevel: 'moderate'
        },
        stats: {
          totalConnections: 0,
          currentConnections: 0,
          weeklyActivity: {},
          encouragementSent: 0,
          encouragementReceived: 0
        },
        badges: [],
        dailyLimits: {
          encouragementsUsed: 0,
          lastResetAt: FieldValue.serverTimestamp()
        }
      }
    };
    
    batch.update(doc.ref, tempoData);
  });
  
  await batch.commit();
  return { success: true, count: usersSnapshot.size };
});
```

### Phase 2: 既存機能の段階的無効化

```javascript
// 既存フィールドを隠す
const hiddenFields = [
  'friendIds',
  'followerCount', 
  'followingCount',
  'posts',
  'likes'
];

// UIで参照しないようにする
// データは保持（rollback可能）
```

---

## 📐 Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ユーザー
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow update: if isOwner(userId) && 
                       validUserUpdate(request.resource.data);
      allow create: if isAuthenticated() && 
                       request.auth.uid == userId;
    }
    
    // 接続
    match /tempoConnections/{connectionId} {
      allow read: if isAuthenticated() && 
                     isConnectionMember(resource.data.users);
      allow create: if isAuthenticated() && 
                       validConnection(request.resource.data);
      allow update: if isConnectionMember(resource.data.users) && 
                       validConnectionUpdate();
    }
    
    // メッセージ
    match /tempoConnections/{connectionId}/messages/{messageId} {
      allow read: if isConnectionMember(get(/databases/$(database)/documents/
                     tempoConnections/$(connectionId)).data.users);
      allow create: if isConnectionMember(get(/databases/$(database)/documents/
                       tempoConnections/$(connectionId)).data.users) && 
                       validMessage(request.resource.data);
    }
    
    // 応援
    match /encouragements/{encouragementId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
                       dailyLimitNotExceeded() && 
                       validEncouragement(request.resource.data);
    }
    
    // ヘルパー関数
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isConnectionMember(users) {
      return request.auth.uid in users;
    }
    
    function dailyLimitNotExceeded() {
      // 1日3個制限のチェック
      return true; // 実装省略
    }
    
    function validUserUpdate(data) {
      // 更新可能フィールドのチェック
      return true; // 実装省略
    }
    
    function validConnection(data) {
      // 接続データの妥当性チェック
      return data.users.size() == 2;
    }
    
    function validMessage(data) {
      // メッセージの妥当性チェック
      return data.text.size() <= 500;
    }
    
    function validEncouragement(data) {
      // 応援の妥当性チェック
      return data.type in ['energy', 'relax', 'empathy', 'praise', 'cheer'];
    }
  }
}
```

---

## 🎯 パフォーマンス最適化

### インデックス戦略

```javascript
// 必須インデックス
firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "tempo.currentStatus.activity", "order": "ASCENDING" },
        { "fieldPath": "tempo.currentStatus.updatedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "tempoConnections",
      "queryScope": "COLLECTION", 
      "fields": [
        { "fieldPath": "users", "arrayConfig": "CONTAINS" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "expiresAt", "order": "ASCENDING" }
      ]
    }
  ]
}
```

### キャッシュ戦略

```dart
// Flutterクライアント側
class FirestoreCache {
  static const cacheSettings = PersistenceSettings(
    sizeBytes: 10 * 1024 * 1024, // 10MB
  );
  
  static void enableOffline() {
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
```

---

## 📊 監視とメトリクス

### 監視対象

```javascript
// Cloud Monitoring メトリクス
const metrics = {
  'connection_creation_rate': '1分あたりの新規接続数',
  'active_connections': 'アクティブな接続総数',
  'message_rate': '1分あたりのメッセージ数',
  'encouragement_rate': '1分あたりの応援数',
  'user_online_count': 'オンラインユーザー数'
};
```

### アラート設定

```yaml
# monitoring.yaml
alerts:
  - name: high_connection_rate
    condition: connection_creation_rate > 100/min
    notification: slack
    
  - name: low_active_users
    condition: user_online_count < 10
    notification: email
    
  - name: database_size
    condition: database_size > 1GB
    notification: slack
```

---

## 🔐 バックアップ戦略

### 定期バックアップ

```bash
# 日次バックアップ（Cloud Scheduler）
gcloud firestore export gs://tempo-backups/$(date +%Y%m%d)

# 重要コレクションのみ
gcloud firestore export \
  --collection-ids=users,tempoConnections \
  gs://tempo-backups/critical/$(date +%Y%m%d)
```

### リストア手順

```bash
# 特定日付からリストア
gcloud firestore import gs://tempo-backups/20250120

# 特定コレクションのみ
gcloud firestore import \
  --collection-ids=users \
  gs://tempo-backups/critical/20250120
```

---

**このデータベース設計は随時更新されます。**
**実装前に最新版を確認してください。**

**作成日**: 2025/01/XX
**最終更新**: 2025/01/XX
**バージョン**: 1.0.0
