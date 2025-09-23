# migration.md - BLANK→Tempo移行計画書

## 🔄 移行概要

既存BLANKアプリを1週間でTempoにリブランディング・機能改修

### 移行方針
- **段階的移行**: 既存機能を活かしつつ段階的に改修
- **データ保持**: 既存データは削除せず非表示化
- **ロールバック可能**: 問題発生時は即座に戻せる設計

---

## 📊 現状分析

### 既存アプリ構成

```
BLANK App
├── 認証（Firebase Auth）         ✅ 流用可能
├── プロフィール                  ⚠️ 改修必要
├── フォロー/フォロワー            ❌ 非表示化
├── 投稿機能                      ❌ 無効化
├── いいね機能                    ❌ 無効化
├── DM/チャット                   ✅ 流用可能
├── 通知（FCM）                   ✅ 流用可能
└── 画像アップロード              ⚠️ 制限付き利用
```

### データベース構成

```javascript
// 既存コレクション
users/              → 改修して利用
posts/              → 非表示（削除しない）
direct_messages/    → そのまま利用
notifications/      → そのまま利用
follows/            → 非表示（削除しない）
likes/              → 非表示（削除しない）

// 新規コレクション
tempoConnections/   → 新規作成
encouragements/     → 新規作成
systemConfig/       → 新規作成
```

---

## 🚀 Day-by-Day 移行計画

### Day 1: 基盤準備とデータモデル改修

#### 作業内容
```bash
# 1. ブランチ作成
git checkout -b feature/tempo-migration
git push -u origin feature/tempo-migration

# 2. 依存関係更新
flutter pub upgrade
flutter pub add gap
flutter pub add collection
```

#### Firebaseスキーマ更新
```javascript
// migration_day1.js
const admin = require('firebase-admin');
const db = admin.firestore();

async function migrateUsersCollection() {
  const batch = db.batch();
  const users = await db.collection('users').get();
  
  users.forEach(doc => {
    // Tempo用フィールド追加
    batch.update(doc.ref, {
      'tempo': {
        'currentStatus': {
          'location': 'home',
          'activity': 'hima',
          'mood': '😊',
          'message': null,
          'updatedAt': admin.firestore.FieldValue.serverTimestamp()
        },
        'preference': {
          'ageRangeMin': 18,
          'ageRangeMax': 35,
          'locationRange': 'all',
          'autoAccept': false
        },
        'stats': {
          'totalConnections': 0,
          'currentConnections': 0
        },
        'badges': [],
        'dailyLimits': {
          'encouragementsUsed': 0,
          'lastResetAt': admin.firestore.FieldValue.serverTimestamp()
        }
      },
      // 既存フィールドは保持（UIで非表示）
      '_migrationVersion': '1.0.0',
      '_migratedAt': admin.firestore.FieldValue.serverTimestamp()
    });
  });
  
  await batch.commit();
  console.log(`Migrated ${users.size} users`);
}
```

#### コード改修
```dart
// lib/domain/entity/user.dart
class User {
  // 既存フィールド（非表示予定）
  @Deprecated('Will be hidden in Tempo')
  final int? followerCount;
  @Deprecated('Will be hidden in Tempo')
  final int? followingCount;
  
  // Tempo新規フィールド
  final TempoData? tempo;
  
  // コンストラクタ改修
  User({
    required this.id,
    required this.name,
    this.followerCount, // Optional for backward compatibility
    this.followingCount, // Optional for backward compatibility
    this.tempo,
  });
  
  // Factory改修
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'],
      // 既存フィールドは条件付き読み込み
      followerCount: data['followerCount'],
      followingCount: data['followingCount'],
      // Tempo data
      tempo: data['tempo'] != null 
        ? TempoData.fromJson(data['tempo'])
        : null,
    );
  }
}
```

### Day 2: UI全面改修

#### テーマ変更
```dart
// lib/core/theme/app_theme.dart → tempo_theme.dart
class TempoTheme {
  // 既存テーマをコメントアウト
  // static final oldTheme = ThemeData(...);
  
  static final lightTheme = ThemeData(
    primaryColor: const Color(0xFF4A90E2),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF4A90E2),
      secondary: const Color(0xFFFF6B35),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF212121),
      elevation: 0,
    ),
  );
}

// main.dart
void main() {
  runApp(
    MaterialApp(
      title: 'Tempo', // BLANK → Tempo
      theme: TempoTheme.lightTheme, // テーマ変更
      home: _getInitialScreen(),
    ),
  );
}
```

#### ホーム画面改修
```dart
// lib/presentation/pages/home/home_page.dart
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 既存のフィード表示を削除
    // return PostFeedWidget(); // 削除
    
    // Tempo用のホーム画面
    return TempoHomePage();
  }
}

// lib/presentation/pages/home/tempo_home_page.dart
class TempoHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 既存のヘッダーコンポーネントを改修
            _buildStatusSection(ref),
            const SizedBox(height: 20),
            _buildMatchingSection(ref),
          ],
        ),
      ),
      // 既存のボトムナビゲーションを改修
      bottomNavigationBar: TempoBottomNav(),
    );
  }
}
```

### Day 3: マッチング機能実装

#### 既存の検索機能を改修
```dart
// lib/domain/service/search_service.dart → matching_service.dart
class MatchingService {
  final FirebaseFirestore _firestore;
  
  // 既存の検索ロジックを流用
  Stream<List<User>> findMatches(User currentUser) {
    // 既存のユーザー検索を改修
    return _firestore
        .collection('users')
        .where('isOnline', isEqualTo: true)
        // フォロワー数での並び替えを削除
        // .orderBy('followerCount', descending: true) // 削除
        // Tempoの条件に変更
        .where('tempo.currentStatus.activity', 
               isEqualTo: currentUser.tempo?.currentStatus.activity)
        .orderBy('tempo.currentStatus.updatedAt', descending: true)
        .limit(10)
        .snapshots()
        .map(_convertToUsers);
  }
}
```

### Day 4: 24時間タイマー実装

#### 新規コレクション作成
```dart
// lib/data/repository/connection_repository.dart
class ConnectionRepository {
  final FirebaseFirestore _firestore;
  
  Future<String> createConnection(String userId1, String userId2) async {
    final doc = await _firestore.collection('tempoConnections').add({
      'users': [userId1, userId2],
      'startedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(Duration(hours: 24))
      ),
      'status': 'active',
      'extensionCount': 0,
    });
    
    // 既存の通知システムを活用
    await _sendConnectionNotification(userId2);
    
    return doc.id;
  }
}
```

### Day 5: チャット機能改修

#### 既存チャットを24時間対応に
```dart
// lib/presentation/pages/chat/chat_page.dart
class ChatPage extends ConsumerWidget {
  final String roomId;
  final String? connectionId; // Tempo用に追加
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tempo接続の場合
    if (connectionId != null) {
      final connection = ref.watch(connectionProvider(connectionId!));
      
      return Scaffold(
        appBar: AppBar(
          title: Text(otherUser.name),
          // 24時間タイマー表示追加
          actions: [
            ConnectionTimerWidget(
              expiresAt: connection.expiresAt,
            ),
          ],
        ),
        body: Column(
          children: [
            // 期限切れ警告
            if (connection.isExpiringSoon)
              ExtensionPromptBanner(),
            
            // 既存のチャットWidget活用
            Expanded(
              child: ExistingChatWidget(
                roomId: roomId,
                // 期限切れたら読み取り専用
                isReadOnly: connection.isExpired,
              ),
            ),
            
            // 既存の入力欄を条件付き表示
            if (!connection.isExpired)
              ExistingMessageInput(roomId: roomId),
          ],
        ),
      );
    }
    
    // 既存のDM（互換性のため残す）
    return ExistingChatPage(roomId: roomId);
  }
}
```

### Day 6: 応援システム実装

#### 既存のリアクション機能を改修
```dart
// lib/presentation/widgets/reaction_bar.dart → encouragement_bar.dart
class EncouragementBar extends StatelessWidget {
  final String connectionId;
  final int dailyLimit = 3;
  
  @override
  Widget build(BuildContext context) {
    // 既存のリアクションUIを流用
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStamp('energy', '⚡', 'がんばれ！'),
          _buildStamp('relax', '🌙', 'お疲れ様'),
          _buildStamp('empathy', '🎯', 'それな！'),
          _buildStamp('praise', '✨', '天才！'),
          _buildStamp('cheer', '💪', '大丈夫'),
        ],
      ),
    );
  }
}
```

### Day 7: 最終調整とリリース準備

#### 機能フラグで段階的有効化
```dart
// lib/core/config/feature_flags.dart
class FeatureFlags {
  // 既存機能の無効化
  static const bool showPosts = false;
  static const bool showFollowers = false;
  static const bool showLikes = false;
  
  // Tempo機能の有効化
  static const bool enableTempo = true;
  static const bool enableMatching = true;
  static const bool enable24HourTimer = true;
  static const bool enableEncouragements = true;
  
  // 段階的ロールアウト
  static bool isTempoEnabled(String userId) {
    // 特定ユーザーから段階的に有効化
    final testUsers = ['user1', 'user2', 'user3'];
    return testUsers.contains(userId) || enableTempo;
  }
}
```

---

## 🔧 既存機能の扱い

### 非表示にする機能

```dart
// lib/presentation/widgets/deprecated/
// これらのWidgetは表示しないが、コードは残す

class FollowerCountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Tempoでは非表示
    if (FeatureFlags.showFollowers) {
      return _buildOriginalWidget();
    }
    return SizedBox.shrink();
  }
}
```

### 無効化する機能

```dart
// lib/domain/service/post_service.dart
class PostService {
  Future<void> createPost(Post post) async {
    // Tempoでは投稿機能無効
    if (!FeatureFlags.showPosts) {
      throw UnsupportedError('Posts are disabled in Tempo');
    }
    // 既存の投稿ロジック
  }
}
```

### 流用する機能

```dart
// これらはそのまま使用
- Firebase Authentication
- Push Notifications (FCM)
- Image Upload (プロフィール画像のみ)
- Report/Block System
- Privacy Settings
```

---

## 📱 アプリ設定の更新

### app/build.gradle
```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.tempo" // 変更する場合
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 2 // インクリメント
        versionName "1.0.0" // Tempo v1
        
        // アプリ名変更
        resValue "string", "app_name", "Tempo"
    }
}
```

### Info.plist
```xml
<key>CFBundleDisplayName</key>
<string>Tempo</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.tempo</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>2</string>
```

### pubspec.yaml
```yaml
name: tempo # blank → tempo
description: 今この瞬間を共有する新しいSNS
version: 1.0.0+1

# アイコン生成
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/tempo_icon.png"
  
# スプラッシュ画面
flutter_native_splash:
  color: "#4A90E2"
  image: assets/splash/tempo_logo.png
```

---

## 🚨 ロールバック計画

### 問題発生時の対処

```dart
// lib/main.dart
void main() {
  // 緊急時は環境変数で切り替え
  final bool useTempoMode = 
    const String.fromEnvironment('USE_TEMPO', defaultValue: 'true') == 'true';
  
  runApp(
    useTempoMode ? TempoApp() : BlankApp(),
  );
}
```

### データベースロールバック

```javascript
// rollback_tempo.js
async function rollbackTempoMigration() {
  const batch = db.batch();
  const users = await db.collection('users')
    .where('_migrationVersion', '==', '1.0.0')
    .get();
  
  users.forEach(doc => {
    // Tempoフィールドを削除
    batch.update(doc.ref, {
      'tempo': admin.firestore.FieldValue.delete(),
      '_migrationVersion': admin.firestore.FieldValue.delete(),
      '_migratedAt': admin.firestore.FieldValue.delete(),
    });
  });
  
  await batch.commit();
  console.log('Rollback completed');
}
```

---

## ✅ 移行チェックリスト

### 開発環境
- [ ] Firebaseプロジェクト設定確認
- [ ] 環境変数設定
- [ ] 開発用証明書準備

### コード変更
- [ ] パッケージ名/Bundle ID（必要に応じて）
- [ ] アプリ名変更
- [ ] カラーテーマ適用
- [ ] アイコン変更
- [ ] スプラッシュ画面

### データベース
- [ ] Firestoreルール更新
- [ ] インデックス作成
- [ ] 移行スクリプト実行
- [ ] バックアップ作成

### テスト
- [ ] 既存ユーザーでの動作確認
- [ ] 新規ユーザー登録
- [ ] 主要機能の動作確認
- [ ] iOS/Android両方でテスト

### リリース準備
- [ ] ストア説明文更新
- [ ] スクリーンショット準備
- [ ] プライバシーポリシー更新
- [ ] 利用規約更新

---

## 📊 移行後のモニタリング

### 監視項目
```dart
// lib/core/analytics/migration_analytics.dart
class MigrationAnalytics {
  static void trackMigrationEvent(String event, Map<String, dynamic> params) {
    FirebaseAnalytics.instance.logEvent(
      name: 'tempo_migration_$event',
      parameters: {
        ...params,
        'migration_version': '1.0.0',
        'is_existing_user': true,
      },
    );
  }
  
  // 追跡するイベント
  static const events = [
    'first_open_after_migration',
    'tempo_status_created',
    'first_match',
    'first_24h_connection',
    'feature_discovery',
  ];
}
```

---

**この移行計画は実行時に随時更新してください。**
**問題が発生した場合は、即座にロールバック計画を実行してください。**

**作成日**: 2025/01/XX
**最終更新**: 2025/01/XX
**担当者**: 開発チーム
