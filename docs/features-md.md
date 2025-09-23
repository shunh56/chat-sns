# features.md - Tempo機能要件定義書

## 📋 機能一覧サマリー

### MVP機能（Week 1）
- ✅ ユーザー認証（電話番号）
- ✅ リアルタイムステータス
- ✅ マッチングシステム
- ✅ 24時間フレンド
- ✅ チャット機能
- ✅ 応援スタンプ
- ✅ プロフィール（数字非表示）

### Phase 2（Week 2-4）
- 🔄 位置情報マッチング
- 🔄 グループ機能
- 🔄 イベント機能
- 🔄 通知最適化

### Phase 3（Month 2+）
- 📅 プレミアム機能
- 📅 AIレコメンド
- 📅 収益化機能

---

## 🔐 認証機能

### F001: 電話番号認証

#### 機能概要
既存のFirebase Authentication を活用した電話番号認証

#### 詳細仕様
```dart
class AuthenticationService {
  // 電話番号送信
  Future<void> sendOTP(String phoneNumber) async {
    // +81 を自動付与（日本）
    // SMS送信（Firebase Auth）
    // 60秒のクールダウン
  }
  
  // OTP検証
  Future<User?> verifyOTP(String otp) async {
    // 6桁の数字
    // 3分間有効
    // 5回失敗で30分ロック
  }
}
```

#### UI要件
- 電話番号入力: 090-1234-5678 形式
- OTP入力: 6マスの個別入力欄
- リトライボタン: 60秒後に有効化

#### エラーハンドリング
- 無効な電話番号
- OTP期限切れ
- ネットワークエラー
- レート制限

---

## 📍 ステータス機能

### F002: リアルタイムステータス更新

#### 機能概要
3ステップで現在の状態を更新

#### データ構造
```dart
class TempoStatus {
  final String location;   // home|work|cafe|transit|other
  final String activity;   // studying|working|netflix|gaming|hima
  final String mood;       // 😊|😪|😎|🥺|😤|🤔
  final String? message;   // 最大20文字
  final DateTime updatedAt;
}
```

#### 更新フロー
```
1. 場所選択（5択）
   [🏠 家] [🏢 職場] [☕ カフェ] [🚃 移動中] [📍 その他]

2. 活動選択（履歴＋候補）
   最近: [勉強] [Netflix]
   候補: [ゲーム] [暇] [仕事] [食事]

3. 気分選択（6択）
   [😊] [😪] [😎] [🥺] [😤] [🤔]

4. 一言（任意）
   [________________] 20文字まで
```

#### 制限事項
- 更新間隔: 最短1分
- 文字数: 20文字（全角半角問わず）
- 絵文字: 気分のみ使用可

### F003: ステータス自動推定

#### 機能概要
時間帯と曜日から活動を推定

```dart
class StatusPredictor {
  String predictActivity(DateTime now, List<String> history) {
    // 平日9-18時 → "working"
    // 平日19-22時 → "netflix"
    // 週末午後 → "hima"
    // 履歴から学習
  }
}
```

---

## 🤝 マッチング機能

### F004: リアルタイムマッチング

#### アルゴリズム仕様
```dart
class MatchingAlgorithm {
  double calculateScore(User a, User b) {
    double score = 0.0;
    
    // 同じ活動: 50%
    if (a.activity == b.activity) score += 0.5;
    
    // 似た気分: 30%
    if (isMoodCompatible(a.mood, b.mood)) score += 0.3;
    
    // 時間の近さ: 20%
    final timeDiff = a.updatedAt.difference(b.updatedAt);
    if (timeDiff < Duration(minutes: 30)) score += 0.2;
    
    // ランダム要素: ±20%
    score *= (0.8 + Random().nextDouble() * 0.4);
    
    return score;
  }
}
```

#### 気分の相性マトリクス
| | 😊 | 😪 | 😎 | 🥺 | 😤 | 🤔 |
|---|---|---|---|---|---|---|
| 😊 | ◎ | △ | ○ | △ | × | △ |
| 😪 | △ | ◎ | × | ○ | △ | △ |
| 😎 | ○ | × | ◎ | × | △ | ○ |
| 🥺 | △ | ○ | × | ◎ | △ | ○ |
| 😤 | × | △ | △ | △ | ◎ | △ |
| 🤔 | △ | △ | ○ | ○ | △ | ◎ |

#### マッチング条件
- オンラインユーザーのみ
- 既に接続中の相手は除外
- ブロックユーザー除外
- 年齢範囲フィルター（±3歳）

### F005: マッチング通知

#### 通知仕様
```dart
class MatchNotification {
  String title = "🎵 テンポが合いました";
  String body = "${user.name}さんと共通点があります";
  
  // 共通点表示
  List<String> commonPoints = [
    "同じく${activity}中",
    "気分も${mood}",
  ];
}
```

---

## ⏰ 24時間フレンド機能

### F006: 接続管理

#### データ構造
```dart
class TempoConnection {
  final String id;
  final List<String> users;
  final DateTime startedAt;
  final DateTime expiresAt;
  final ConnectionStatus status;
  final int extensionCount;
  
  Duration get remaining => expiresAt.difference(DateTime.now());
  bool get isExpiringSoon => remaining < Duration(hours: 1);
  bool get canExtend => extensionCount < 4;
}

enum ConnectionStatus {
  active,    // アクティブ
  extended,  // 延長済み
  expired,   // 期限切れ
  archived   // アーカイブ
}
```

### F007: 延長メカニズム

#### 延長ルール
- 両者の同意が必要
- 最大4回まで（合計5日間）
- 1時間前から延長可能
- 延長ごとに+24時間

```dart
class ExtensionRequest {
  // ユーザーAが延長リクエスト
  Future<void> requestExtension(String connectionId) async {
    // pending状態に
    await markAsPending(connectionId, userId);
  }
  
  // ユーザーBが承認
  Future<void> approveExtension(String connectionId) async {
    if (bothUsersPending()) {
      await extendConnection(connectionId);
      // 通知送信
    }
  }
}
```

### F008: タイマー表示

#### UI仕様
```dart
class ConnectionTimer extends StatelessWidget {
  // 通常時: 青色で "残り23時間45分"
  // 1時間以下: オレンジで点滅
  // 10分以下: 赤色で強調
  // 期限切れ: グレーで "期限切れ"
}
```

---

## 💬 チャット機能

### F009: メッセージ送受信

#### 既存機能の改修点
- 24時間後は読み取り専用
- メッセージ削除不可
- 既読表示なし（プレッシャー軽減）

#### メッセージ種別
```dart
enum MessageType {
  text,          // テキスト
  encouragement, // 応援スタンプ
  system,        // システム通知
}

class Message {
  final String id;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? stampType;
  final DateTime createdAt;
}
```

### F010: 応援スタンプ

#### スタンプ定義
```dart
const stamps = {
  'energy': {'emoji': '⚡', 'text': 'がんばれ！', 'color': 0xFFFFD700},
  'relax': {'emoji': '🌙', 'text': 'お疲れ様', 'color': 0xFF6B46C1},
  'empathy': {'emoji': '🎯', 'text': 'それな！', 'color': 0xFF4A90E2},
  'praise': {'emoji': '✨', 'text': '天才！', 'color': 0xFFFF6B35},
  'cheer': {'emoji': '💪', 'text': '大丈夫', 'color': 0xFF4CAF50},
};
```

#### 送信制限
- 1日3個まで（0時リセット）
- 同じ相手には1時間に1個
- アニメーション付き送信

---

## 👤 プロフィール機能

### F011: 数字非表示プロフィール

#### 表示項目
```dart
class UserProfile {
  // 表示する
  final String name;
  final String? imageUrl;
  final String? bio;        // 100文字
  final List<String> tags;  // 最大5個
  final TempoStatus currentStatus;
  
  // 表示しない
  // - フォロワー数
  // - 投稿数
  // - いいね数
  // - 友達数
}
```

### F012: テンポ設定

#### ユーザー傾向設定
```dart
class TempoPreference {
  final TimePreference timeType;     // morning|night
  final ActivityLevel activityLevel; // active|moderate|relaxed
  final SocialStyle socialStyle;     // open|selective|private
}
```

---

## 🔔 通知機能

### F013: プッシュ通知

#### 通知種別と文言
```dart
const notifications = {
  'match': '🎵 新しいテンポ仲間が見つかりました',
  'message': '💬 メッセージが届いています',
  'encouragement': '⚡ 応援をもらいました！',
  'extension': '⏰ 接続があと1時間で切れます',
  'expired': '👋 24時間の接続が終了しました',
};
```

#### 通知設定
- 通知ON/OFF
- 時間帯設定（22時-8時はOFF等）
- 種別ごとの設定

---

## 🛡 安全機能

### F014: ブロック・通報

#### ブロック仕様
- 即座に接続解除
- 今後マッチングしない
- メッセージ履歴は保持（証拠用）

#### 通報カテゴリ
```dart
enum ReportReason {
  inappropriate,  // 不適切な内容
  harassment,     // 嫌がらせ
  spam,          // スパム
  fake,          // なりすまし
  underage,      // 未成年の不適切利用
  other,         // その他
}
```

### F015: 未成年保護

#### 制限事項
- 22時-6時: 自動オフライン
- 位置情報: より曖昧化
- マッチング: 年齢範囲制限
- 通報: 優先対応

---

## 📊 分析機能

### F016: ユーザー向け統計

#### 表示内容（数字は最小限）
```dart
class UserStats {
  // 今週のサマリー
  final Map<String, int> activityDistribution;
  final String mostCommonMood;
  final String mostActiveTime;
  
  // グラフ表示（数字なし）
  Widget buildActivityGraph() {
    // 波形グラフで可視化
    // 具体的な数字は表示しない
  }
}
```

---

## 🎮 ゲーミフィケーション

### F017: アチーブメント

#### バッジシステム
```dart
enum Badge {
  firstConnection('初めての出会い'),
  weekStreak('7日連続ログイン'),
  nightOwl('夜型マスター'),
  earlyBird('朝型マスター'),
  himaKing('暇の達人'),
  encourager('応援の天使'),
}
```

#### 獲得条件
- 内部的にカウント
- 数字は見せない
- サプライズで付与

---

## 🌐 システム機能

### F018: オフライン対応

#### キャッシュ戦略
```dart
class OfflineSupport {
  // 最後のステータス保持
  // メッセージの下書き保存
  // 接続タイマーの継続表示
  // オンライン復帰時に同期
}
```

### F019: エラーハンドリング

#### ユーザーフレンドリーなエラー
```dart
const errorMessages = {
  'network': 'ネットワークに接続できません。しばらくしてからお試しください。',
  'timeout': 'タイムアウトしました。もう一度お試しください。',
  'permission': 'この操作には権限が必要です。',
  'limit': '制限に達しました。しばらくお待ちください。',
};
```

---

## 🚀 Phase 2 機能（詳細はfuture-features.mdへ）

### 位置情報マッチング
- 同じエリアの人を優先
- プライバシーに配慮した実装

### グループ機能
- 3人以上の同時接続
- グループチャット

### イベント機能
- オンライン/オフライン meetup
- 参加費管理

---

## 📝 実装優先順位

### Week 1 必須機能
1. 認証（F001）
2. ステータス（F002）
3. マッチング（F004）
4. 24時間タイマー（F006）
5. チャット（F009）

### Week 2 追加機能
6. 応援スタンプ（F010）
7. 延長機能（F007）
8. 通知（F013）

### Week 3 改善機能
9. プロフィール（F011）
10. ブロック（F014）
11. 統計（F016）

---

**この仕様書は開発の進行に応じて更新されます。**
**実装時は最新版を確認してください。**

**作成日**: 2025/01/XX
**最終更新**: 2025/01/XX
**バージョン**: 1.0.0
