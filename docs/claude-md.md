# claude.md - Tempo開発用AIプロンプト集

## 🎯 プロジェクト概要

**アプリ名**: Tempo（テンポ）
**コンセプト**: 今この瞬間を共有し、同じテンポの人と24時間限定で繋がるSNS
**技術スタック**: Flutter 3.x + Firebase
**開発期間**: 1週間MVP → 段階的拡張
**既存アプリ**: BLANKからのリブランディング

## 🏗 アーキテクチャコンテキスト

```dart
// プロジェクト構造
lib/
├── core/
│   ├── theme/          # Tempoテーマ
│   ├── utils/          # 共通ユーティリティ
│   └── constants/      # 定数定義
├── data/
│   ├── repositories/   # Firebase接続層
│   └── models/         # Firestoreモデル
├── domain/
│   ├── entities/       # ビジネスエンティティ
│   └── services/       # ビジネスロジック
└── presentation/
    ├── pages/          # 画面
    ├── widgets/        # 共通Widget
    └── providers/      # Riverpod Provider
```

## 💻 コード生成プロンプト

### 1. データモデル生成

```
Create a Firestore data model in Dart for Tempo app.
Requirements:
- User model WITHOUT numeric fields (no follower count, no likes)
- TempoStatus with location (home/work/cafe/transit), activity (studying/working/netflix/gaming/hima), mood (emoji), message (20 chars max)
- TempoConnection for 24-hour limited connections with extension capability
- Use freezed for immutability
- Include fromJson/toJson for Firestore
```

### 2. UI画面生成

```
Create a Flutter home screen for Tempo SNS app:
- Top section: Large status card showing user's current location/activity/mood
- Middle: Horizontal carousel of matched users (PageView)
- Bottom: Connect button with haptic feedback
- Use Material 3 design
- Colors: Primary #4A90E2, Secondary #FF6B35
- NO grid view, NO follower counts, NO numeric metrics
- Include loading and empty states
```

### 3. マッチングロジック

```
Implement a Firestore-based matching algorithm in Dart:
- Find users with same activity (weight: 0.5)
- Similar mood compatibility (weight: 0.3)
- Time proximity within 30 minutes (weight: 0.2)
- Exclude already connected users
- Add 20% random factor for serendipity
- Optimize for real-time updates using snapshots
- Consider Firestore index requirements
```

### 4. 24時間タイマー実装

```
Create a 24-hour connection timer system in Flutter:
- Auto-expire connections after 24 hours
- Show remaining time in hours:minutes
- Warning state when < 1 hour remaining
- Extension mechanism (both users must approve)
- Maximum 4 extensions per connection
- Use Stream for real-time updates
- Handle timezone differences
```

### 5. ステータス更新UI

```
Build a quick status update screen in Flutter:
Step 1: Location selector (5 options with icons)
Step 2: Activity selector (show recent + suggestions)
Step 3: Mood picker (6 emojis only)
Optional: 20-character message input
- Smooth animations between steps
- Auto-save to Firestore
- Learn user patterns for smart defaults
```

### 6. チャット改修

```
Modify existing chat to add Tempo features:
- Display 24-hour timer in app bar
- Add extension prompt when < 1 hour left
- Integrate encouragement stamps (5 types, 3 per day limit)
- Make chat read-only after expiration
- Keep message history but prevent new messages
- Add haptic feedback for interactions
```

### 7. Firebase Security Rules

```
Write Firestore security rules for Tempo:
- Users can only edit their own profile
- Connections require mutual consent
- Chat messages only visible to connection participants
- Encouragements limited to 3 per day per user
- Status updates max once per minute
- Block users under 18 from 22:00-06:00
```

### 8. Riverpod状態管理

```
Create Riverpod providers for Tempo app:
- CurrentUserProvider (Firebase Auth + profile)
- StatusProvider (real-time status updates)
- MatchingProvider (potential matches stream)
- ConnectionsProvider (active connections with timers)
- ChatProvider (messages with pagination)
Use AsyncValue for loading states
Include error handling and retry logic
```

## 🎨 UI/UXプロンプト

### カラーパレット適用

```
Apply Tempo color scheme to Flutter widgets:
Primary: #4A90E2 (trust, connection)
Secondary: #FF6B35 (warmth, energy)
Background: #F5F5F5
Success: #4CAF50
Warning: #FFC107 (for timer warnings)
Error: #F44336
Mood colors: Map each emoji to specific color
Create consistent elevation and shadow system
```

### アニメーション実装

```
Add micro-interactions to Tempo app:
- Pulse animation on match (1.5s duration)
- Bounce effect on stamp send (0.5s)
- Fade in/out for status changes
- Slide transitions between screens
- Haptic feedback: light for success, strong for match
- Loading skeletons instead of spinners
Use Flutter's AnimationController
```

## 🔥 Firebase最適化

### Firestoreクエリ最適化

```
Optimize Firestore queries for Tempo:
1. Create composite indexes for:
   - users: [activity, mood, updatedAt]
   - connections: [users, status, expiresAt]
2. Implement pagination (limit 20)
3. Use local cache for recent queries
4. Batch write operations
5. Use FieldValue.serverTimestamp()
Consider query cost implications
```

### Cloud Functions

```
Create Cloud Functions for Tempo backend:
1. Auto-expire connections after 24 hours
2. Clean up expired data daily
3. Calculate and cache compatibility scores
4. Send push notifications for matches
5. Enforce daily limits (encouragements)
Use TypeScript, handle errors gracefully
```

## 🐛 エラーハンドリング

### 一般的なエラー処理

```
Implement comprehensive error handling:
- Network errors: Show offline mode
- Firebase errors: User-friendly messages
- Validation errors: Inline field errors
- Rate limiting: Show cooldown timer
- Permission errors: Request required permissions
Use try-catch with specific error types
Log errors to Crashlytics
```

## 🧪 テストプロンプト

### 単体テスト

```
Write unit tests for Tempo core features:
- Status update validation
- Matching algorithm accuracy
- Timer countdown logic
- Extension limit enforcement
- Daily limit counters
Use flutter_test and mockito
Aim for 80% coverage on business logic
```

## 📱 プラットフォーム別対応

### iOS特有の実装

```
Handle iOS-specific requirements:
- Request notification permissions
- Handle App Store review guidelines
- Implement Apple Sign In (optional)
- Handle iOS 14+ privacy requirements
- Test on iPhone X and newer
```

### Android特有の実装

```
Handle Android-specific requirements:
- Request location permissions properly
- Handle battery optimization
- Support Android 12+ Material You
- Test on various screen sizes
- Handle back button navigation
```

## 🚀 パフォーマンス最適化

### Widget最適化

```
Optimize Flutter widgets for performance:
- Use const constructors wherever possible
- Implement ListView.builder for long lists
- Use CachedNetworkImage for avatars
- Lazy load heavy widgets
- Minimize widget rebuilds with selective updates
- Use RepaintBoundary for complex widgets
```

### 状態管理最適化

```
Optimize Riverpod state management:
- Use .select() for granular updates
- Implement proper disposal
- Cache expensive computations
- Use family providers for parametrized state
- Avoid unnecessary provider rebuilds
```

## 🔐 セキュリティ実装

### データ保護

```
Implement security best practices:
- Never store sensitive data in plain text
- Use Firebase Auth for all authentication
- Implement rate limiting on all APIs
- Sanitize user inputs
- Blur location to neighborhood level
- Implement report/block functionality
```

## 📊 分析実装

### イベントトラッキング

```
Implement analytics tracking:
Events to track:
- status_updated
- match_created
- connection_extended
- chat_message_sent
- encouragement_sent
Use Firebase Analytics
Include user properties (non-PII)
```

## 💡 AIへの追加コンテキスト

### 重要な制約
- **数字を一切表示しない**（フォロワー数、いいね数など）
- **24時間で自動的に接続が切れる**
- **1日3個までの応援スタンプ制限**
- **20文字のメッセージ制限**
- **未成年は22時-6時自動オフライン**

### 既存アプリからの移行
- 認証システムは既存のものを流用
- プロフィール機能は改修して使用
- チャット基盤は既存のものを改修
- データベースは既存Firebaseプロジェクトを使用

### コーディング規約
```dart
// 命名規則
class TempoUserEntity {}  // クラス: PascalCase
final userId = '';         // 変数: camelCase
const MAX_MESSAGE = 20;    // 定数: UPPER_SNAKE

// ファイル構造
tempo_user.dart           // ファイル: snake_case
TempoUserWidget           // Widget: PascalCase + Widget

// コメント
/// ドキュメンテーションコメント
// 実装コメントは最小限に
```

## 🎯 開発優先順位

### Week 1 (MVP)
1. ✅ 基本的なステータス更新
2. ✅ シンプルなマッチング
3. ✅ 24時間タイマー
4. ✅ 基本チャット
5. ✅ 応援スタンプ

### Week 2-4
- 位置情報マッチング
- グループ機能
- イベント機能
- プレミアム機能

### Month 2+
- AI最適化
- 収益化
- グローバル展開

---

**使用方法**: 
1. 各プロンプトをClaude/ChatGPT/Copilotにコピー
2. 必要に応じてコンテキストを追加
3. 生成されたコードをレビュー・調整
4. 既存コードとの統合

**更新日**: 2025/01/XX
