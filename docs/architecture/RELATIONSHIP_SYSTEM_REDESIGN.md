# 段階的リレーションシステム設計書

## 作成日
2025-10-06

## 概要
**気軽な出会い**から**深い友人関係**へと自然に進化する、段階的なユーザーリレーションシステムを設計。\
ユーザー操作を複雑にせず、**自動的に関係性が深まる**仕組みを実現。

---

## 🎯 設計コンセプト

### コアアイデア
**「フォローから始まり、交流によって自動的にフレンドに進化」**

- ✅ 初めは**気軽にフォロー**（X/Instagram風）
- ✅ 交流が深まると**自動的にフレンド化**（ユーザー操作不要）
- ✅ フレンドになると**特別な機能が解放**

---

## 📊 現状分析

### 既存システムの課題

| システム | 実装状況 | 課題 |
|---------|---------|------|
| **フォローシステム** | ✅ 実装済み | 片方向、カジュアル |
| **フレンドシステム** | ⚠️ 一部実装 | 使われていない、ハードルが高い |
| **topFriends** | ✅ 実装済み | 手動選択、意味が不明確 |
| **friendIds** | ✅ 実装済み | 相互フォローと区別できない |

### 既存データ構造

```dart
// users/{userId}
{
  "followingCount": 120,      // フォロー中の人数
  "followerCount": 80,        // フォロワー数
  "friendIds": [],            // フレンド一覧（未使用）
  "topFriends": [],           // お気に入りフレンド（手動選択）
}

// followings/{userId}
{
  "data": [
    { "userId": "user123", "createdAt": Timestamp }
  ]
}

// followers/{userId}
{
  "data": [
    { "userId": "user456", "createdAt": Timestamp }
  ]
}
```

---

## 🚀 新しいリレーションシステム設計

### コンセプト: **一方向のラベル付けシステム**

ユーザーが**自分にとって**相手がどういう存在かを**手動で設定**できる。\
これは**一方向**で、相手には見えない（プライベートラベル）。

```
レベル0: 知らない人（Stranger）
    ↓ フォロー
レベル1: フォロー中（Following）★ 既存
    ↓ 手動で「フレンド」設定
レベル2: フレンド（Friend）★ 新規（一方向）
    ↓ 手動で「親友」設定
レベル3: 親友（Best Friend）★ 新規（一方向）

別軸: スキップ（Skip）★ 新規（一方向）
    ↓ フォロー中だが非表示にしたい人
```

### レベル定義（一方向）

| レベル | 名称 | 設定方法 | 意味 | できること |
|-------|------|---------|------|-----------|
| **0** | 知らない人 | - | まだフォローしていない | プロフィール閲覧のみ |
| **1** | フォロー中 | フォローボタン | カジュアルなつながり | 投稿が見える、足あと |
| **2** | フレンド | 手動ラベル | 気になる人 | **優先表示**、通知ON |
| **3** | 親友 | 手動ラベル | 特に親しい人 | **最優先**、常に通知 |
| **-** | スキップ | 手動ラベル | フォロー中だが非表示 | タイムライン非表示 |

**重要**: これらは**自分から見た相手のラベル**であり、**相手には見えない**（Instagram の「親しい友達」リストと同じ）

---

## 📐 交流スコア（Interaction Score）システム ★ 参考データのみ

### 概要
ユーザー間の交流の深さを数値化し、**データ分析や推薦に活用**。\
**自動的なレベル変更はしない**が、ユーザーに**「この人をフレンドにしませんか？」と提案**する材料として使う。

### スコア計算ロジック（バックグラウンド）

| アクション | スコア |
|-----------|--------|
| **DM送信** | +5 |
| **通話（5分以上）** | +10 |
| **投稿にいいね** | +2 |
| **投稿にコメント** | +3 |
| **プロフィール訪問** | +1 |
| **ステータス更新を確認** | +1 |

### スコアの活用方法

#### 1. フレンド推薦
```
スコアが50以上のユーザーに対して通知:
「〇〇さんをフレンドに追加しませんか？」
```

#### 2. データ分析
- 誰と交流が多いか可視化
- チャーン予測（スコアが下がっている = 関係が冷めている）

#### 3. タイムラインソート
- フォロー中のユーザーを交流スコア順にソート
- よく交流する人の投稿を優先表示

**重要**: スコアは**裏側で計算**するだけで、**ユーザーには見せない**（シンプルに保つため）

---

## 🗂️ データモデル設計

### 1. `relationships/{userId}/labels/{targetId}` ★ 新規コレクション（一方向）

ユーザーが**自分にとって**相手がどういう存在かを記録する。\
**一方向**なので、`relationships/{userId}/labels/{targetId}` は `userId` から見た `targetId` のラベル。

```typescript
interface RelationshipLabel {
  userId: string;              // 自分のID
  targetId: string;            // 相手のID
  label: 'following' | 'friend' | 'best_friend' | 'skip';  // ラベル

  // 交流スコア（参考データ、ユーザーには非表示）
  interactionScore: number;    // 現在のスコア（バックグラウンド計算）
  lastInteractionAt: Timestamp; // 最後の交流日時

  // 統計情報（データ分析用）
  totalDmCount: number;        // DM送信回数
  totalCallDuration: number;   // 通話時間（秒）
  totalLikes: number;          // いいね数
  totalComments: number;       // コメント数
  totalProfileVisits: number;  // プロフィール訪問回数

  // メタデータ
  createdAt: Timestamp;        // フォロー開始日時
  updatedAt: Timestamp;        // 最終更新日時
  labelSetAt?: Timestamp;      // ラベルを設定した日時
  labelSetManually: boolean;   // 手動でラベルを設定したか（true = 手動、false = デフォルト）
}
```

### ラベルの初期値

| 状態 | label | labelSetManually |
|------|-------|------------------|
| フォローした直後 | `'following'` | `false` |
| ユーザーが「フレンド」に設定 | `'friend'` | `true` |
| ユーザーが「親友」に設定 | `'best_friend'` | `true` |
| ユーザーが「スキップ」に設定 | `'skip'` | `true` |

### 2. `users/{userId}` 拡張

```typescript
interface UserAccount {
  // ... 既存フィールド

  followingCount: number;      // フォロー中（レベル1以上）
  followerCount: number;       // フォロワー数

  // ★ 新規追加
  friendCount: number;         // フレンド数（自分が「フレンド」ラベルを付けた人数）
  bestFriendCount: number;     // 親友数（自分が「親友」ラベルを付けた人数）

  // ★ 既存フィールドは維持（後方互換性）
  topFriends: string[];        // 廃止予定（friend ラベルで代替）
  friendIds: string[];         // 廃止予定（friend ラベルで代替）
}
```

### カウンターの更新ロジック

```javascript
// ユーザーが「フレンド」ラベルを設定したとき
await admin.firestore().doc(`users/${userId}`).update({
  friendCount: FieldValue.increment(1)
});

// ユーザーが「親友」ラベルを設定したとき
await admin.firestore().doc(`users/${userId}`).update({
  bestFriendCount: FieldValue.increment(1),
  friendCount: FieldValue.increment(-1)  // フレンドから親友に昇格
});
```

### 3. 既存コレクションの維持

```typescript
// followings/{userId} - そのまま維持
{
  data: [
    { userId: "user123", createdAt: Timestamp }
  ]
}

// followers/{userId} - そのまま維持
{
  data: [
    { userId: "user456", createdAt: Timestamp }
  ]
}
```

---

## 🎨 UI/UX設計 ★ 超シンプル設計

### コンセプト
**フォローボタン1つ + 長押しでラベル設定**

### 1. プロフィール画面のボタン表示

#### 基本操作
```
[  フォロー  ]  ← タップでフォロー
[ フォロー中 ]  ← タップでアンフォロー、長押しでラベル設定
```

#### 長押しでメニュー表示（Instagram風）

```dart
Widget _buildRelationshipButton(String label, bool isFollowing) {
  return GestureDetector(
    onTap: () {
      if (!isFollowing) {
        followUser();  // フォロー
      } else {
        unfollowUser();  // アンフォロー
      }
    },
    onLongPress: () {
      if (isFollowing) {
        // ★ 長押しでラベル設定メニューを表示
        showLabelMenu();
      }
    },
    child: Container(
      child: Row(
        children: [
          _getLabelIcon(label),  // ラベルに応じたアイコン
          Text(isFollowing ? 'フォロー中' : 'フォロー'),
        ],
      ),
    ),
  );
}

// ラベル設定メニュー
void showLabelMenu() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      children: [
        ListTile(
          leading: Icon(Icons.person),
          title: Text('フォロー中'),
          subtitle: Text('通常のフォロー'),
          onTap: () => setLabel('following'),
        ),
        ListTile(
          leading: Icon(Icons.star, color: Colors.amber),
          title: Text('フレンド'),
          subtitle: Text('気になる人 - 優先表示・通知ON'),
          onTap: () => setLabel('friend'),
        ),
        ListTile(
          leading: Icon(Icons.favorite, color: Colors.pink),
          title: Text('親友'),
          subtitle: Text('特に親しい人 - 最優先・常に通知'),
          onTap: () => setLabel('best_friend'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.visibility_off, color: Colors.grey),
          title: Text('スキップ'),
          subtitle: Text('フォロー中だがタイムライン非表示'),
          onTap: () => setLabel('skip'),
        ),
      ],
    ),
  );
}
```

#### 表示例（アイコンでラベルを表現）

```
┌─────────────────────────────┐
│   👤 山田太郎               │
│   @yamada_taro              │
│                             │
│   [  フォロー  ]            │
└─────────────────────────────┘

┌─────────────────────────────┐
│   👤 田中花子               │
│   @tanaka_hanako            │
│                             │
│   [ フォロー中 ]  ← タップで解除、長押しでメニュー
└─────────────────────────────┘

┌─────────────────────────────┐
│   👤 佐藤次郎               │
│   @sato_jiro                │
│                             │
│   [ ⭐ フォロー中 ]  ← フレンド
└─────────────────────────────┘

┌─────────────────────────────┐
│   👤 鈴木三郎               │
│   @suzuki_saburo            │
│                             │
│   [ 💖 フォロー中 ]  ← 親友 │
└─────────────────────────────┘

┌─────────────────────────────┐
│   👤 高橋四郎               │
│   @takahashi_shiro          │
│                             │
│   [ 👁️‍🗨️ フォロー中 ]  ← スキップ（非表示）
└─────────────────────────────┘
```

### 2. タブバー設計

```
┌─────────┬─────────┬─────────┬──────┬──────┐
│ すべて  │ フレンド │  親友   │スキップ│フォロワー│
│   120   │    45   │   12    │  8   │  80  │
└─────────┴─────────┴─────────┴──────┴──────┘
  ↑           ↑          ↑         ↑       ↑
全フォロー  label=friend  best_friend skip  逆方向
```

#### 各タブの説明

| タブ | 対象 | ソート順 |
|-----|------|---------|
| **すべて** | フォロー中全員（skip除く） | 交流スコア順 |
| **フレンド** | `label='friend'` の人 | 交流スコア順 |
| **親友** | `label='best_friend'` の人 | 交流スコア順 |
| **スキップ** | `label='skip'` の人 | 最近フォローした順 |
| **フォロワー** | 自分をフォローしている全員 | 最近フォローされた順 |

### 3. ラベル別の機能

| ラベル | タイムライン表示 | 通知 | 優先度 |
|-------|----------------|------|--------|
| **following** | ✅ 表示 | 基本通知のみ | 通常 |
| **friend** | ✅ 優先表示 | すべて通知 | 高 |
| **best_friend** | ✅ 最優先表示 | **常に通知** | 最高 |
| **skip** | ❌ 非表示 | 通知なし | なし |

### 4. フレンド推薦（交流スコア活用）

```dart
// ホーム画面の上部に表示
Widget _buildFriendSuggestion() {
  return Card(
    child: Column(
      children: [
        Text('よく交流している人をフレンドに追加しませんか？'),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.imageUrl),
          ),
          title: Text(user.name),
          subtitle: Text('最近${dmCount}回メッセージ交換しました'),
          trailing: ElevatedButton(
            onPressed: () => setLabel(user.id, 'friend'),
            child: Text('フレンドに追加'),
          ),
        ),
      ],
    ),
  );
}
```

---

## ⚙️ ラベル設定のロジック

### ユーザーがラベルを設定（Flutter側）

```dart
// プロフィール画面でラベル設定
Future<void> setLabel(String targetId, String label) async {
  final userId = currentUserId;

  // Firestore に保存
  await FirebaseFirestore.instance
      .doc('relationships/$userId/labels/$targetId')
      .set({
    'userId': userId,
    'targetId': targetId,
    'label': label,
    'labelSetAt': Timestamp.now(),
    'labelSetManually': true,
    'updatedAt': Timestamp.now(),
  }, SetOptions(merge: true));

  // カウンター更新（Cloud Functions で処理）
  // → onLabelChanged トリガーが自動実行される
}
```

### Firebase Functions: ラベル変更時の処理

```javascript
// Firebase Functions (Firestore Trigger)
exports.onLabelChanged = functions.firestore
  .document('relationships/{userId}/labels/{targetId}')
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    const targetId = context.params.targetId;

    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;

    // 削除された場合
    if (!after) {
      if (before?.label === 'friend') {
        await decrementFriendCount(userId);
      } else if (before?.label === 'best_friend') {
        await decrementBestFriendCount(userId);
      }
      return;
    }

    const oldLabel = before?.label || 'following';
    const newLabel = after.label;

    // ラベルが変更された場合のみカウンター更新
    if (oldLabel !== newLabel) {
      await updateLabelCounters(userId, oldLabel, newLabel);
    }
  });

/**
 * ラベルカウンター更新
 */
async function updateLabelCounters(userId, oldLabel, newLabel) {
  const userRef = admin.firestore().doc(`users/${userId}`);

  // 旧ラベルのカウントを減らす
  if (oldLabel === 'friend') {
    await userRef.update({ friendCount: FieldValue.increment(-1) });
  } else if (oldLabel === 'best_friend') {
    await userRef.update({ bestFriendCount: FieldValue.increment(-1) });
  }

  // 新ラベルのカウントを増やす
  if (newLabel === 'friend') {
    await userRef.update({ friendCount: FieldValue.increment(1) });
  } else if (newLabel === 'best_friend') {
    await userRef.update({ bestFriendCount: FieldValue.increment(1) });
  }
}
```

### フォロー時の自動ラベル作成

```javascript
// Firebase Functions (Firestore Trigger)
exports.onFollowCreated = functions.firestore
  .document('followings/{userId}')
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const before = change.before.data();
    const after = change.after.data();

    // 新しくフォローしたユーザーを検出
    const newFollows = after.data.filter(f =>
      !before.data.some(b => b.userId === f.userId)
    );

    for (const follow of newFollows) {
      const targetId = follow.userId;

      // ★ デフォルトラベル 'following' を作成
      await admin.firestore()
        .doc(`relationships/${userId}/labels/${targetId}`)
        .set({
          userId: userId,
          targetId: targetId,
          label: 'following',
          interactionScore: 0,
          lastInteractionAt: admin.firestore.Timestamp.now(),
          totalDmCount: 0,
          totalCallDuration: 0,
          totalLikes: 0,
          totalComments: 0,
          totalProfileVisits: 0,
          createdAt: admin.firestore.Timestamp.now(),
          updatedAt: admin.firestore.Timestamp.now(),
          labelSetManually: false,  // 自動作成
        });
    }
  });
```

### 交流スコア更新（バックグラウンド）

```javascript
/**
 * DMを送信したときに交流スコアを加算
 */
exports.onDmSent = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    const senderId = message.senderId;
    const receiverId = message.receiverId;

    // 双方向で交流スコアを加算
    await updateInteractionScore(senderId, receiverId, { action: 'dm_sent', score: 5 });
    await updateInteractionScore(receiverId, senderId, { action: 'dm_received', score: 3 });
  });

/**
 * 交流スコア更新の共通ロジック
 */
async function updateInteractionScore(userId, targetId, interaction) {
  const labelRef = admin.firestore()
    .doc(`relationships/${userId}/labels/${targetId}`);

  const label = await labelRef.get();

  if (!label.exists) {
    // ラベルがない場合は何もしない（フォローしていない）
    return;
  }

  const data = label.data();
  const newScore = (data.interactionScore || 0) + interaction.score;

  await labelRef.update({
    interactionScore: newScore,
    lastInteractionAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
    // アクション別のカウンター更新
    ...(interaction.action === 'dm_sent' && { totalDmCount: FieldValue.increment(1) }),
    ...(interaction.action === 'call_completed' && {
      totalCallDuration: FieldValue.increment(interaction.metadata.duration)
    }),
  });

  // ★ スコアが50以上の場合、フレンド推薦通知を送る
  if (data.interactionScore < 50 && newScore >= 50 && data.label === 'following') {
    await sendFriendSuggestion(userId, targetId);
  }
}

/**
 * フレンド推薦通知
 */
async function sendFriendSuggestion(userId, targetId) {
  await sendNotification(userId, {
    title: '〇〇さんをフレンドに追加しませんか？',
    body: '最近よく交流しています',
    type: 'friend_suggestion',
    targetId: targetId,
  });
}
```

---

## 🎁 レベル別機能解放

### レベル0: 知らない人

- ✅ プロフィール閲覧
- ❌ DM送信不可
- ❌ 通話リクエスト不可
- ❌ 投稿非表示

### レベル1: フォロー中（Following）

- ✅ プロフィール閲覧
- ✅ 投稿が見える
- ✅ 足あとが残る
- ❌ DM送信不可（相互フォローまで）
- ❌ 通話リクエスト不可

### レベル2: つながり（Connection）

- ✅ すべてのレベル1の機能
- ✅ **DM送信可能**
- ✅ **通話リクエスト可能**
- ✅ ストーリー閲覧
- ✅ ステータス更新通知

### レベル3: 親しい友達（Close Friend）

- ✅ すべてのレベル2の機能
- ✅ **優先通知**（友達オンライン通知など）
- ✅ **ストーリー限定公開**（親しい友達のみ）
- ✅ **プロフィール詳細閲覧**（位置情報など）
- ✅ **通話優先**（親しい友達からの通話は最優先）

---

## 📱 実装ステップ

### Phase 1: データモデル実装 (3日)

1. ✅ `relationships/{userId}/connections/{targetId}` コレクション作成
2. ✅ `RelationshipConnection` エンティティ作成
3. ✅ `users/{userId}` に `connectionCount`, `closeFriendCount` 追加
4. ✅ Firestore Security Rules 更新

### Phase 2: 相互フォロー検知と自動つながり化 (3日)

1. ✅ Firebase Functions: `onFollowCreated` 実装
2. ✅ 相互フォローチェックロジック
3. ✅ `createConnection()` 実装
4. ✅ 通知送信

### Phase 3: 交流スコアシステム (4日)

1. ✅ `updateInteractionScore()` 共通ロジック実装
2. ✅ DM送信時のトリガー
3. ✅ 通話終了時のトリガー
4. ✅ いいね・コメント時のトリガー
5. ✅ スコア減衰の定期実行（Cloud Scheduler）

### Phase 4: 親しい友達自動昇格 (2日)

1. ✅ `promoteToCloseFriend()` 実装
2. ✅ スコア100到達時のトリガー
3. ✅ 通知送信

### Phase 5: UI/UX実装 (5日)

1. ✅ プロフィール画面のボタン改修
2. ✅ タブバー改修（4タブ）
3. ✅ 交流スコアプログレスバー表示
4. ✅ レベル別のアイコン・色分け
5. ✅ 通知UI

### Phase 6: 機能解放ロジック (3日)

1. ✅ DM送信制限（レベル2以上）
2. ✅ 通話リクエスト制限（レベル2以上）
3. ✅ 優先通知ロジック（レベル3のみ）
4. ✅ ストーリー限定公開

---

## 📊 ビジネス的メリット

### 1. エンゲージメント向上

- **交流を促進**: スコアを貯めるために、ユーザーが積極的に交流
- **リテンション向上**: 親しい友達ができるとアプリに留まる

### 2. ユーザー体験の向上

- **シンプル**: 「フォロー」のワンボタンで始められる
- **自然な進化**: 勝手に親しい友達になっていく
- **達成感**: スコアが可視化され、親しい友達になる瞬間が嬉しい

### 3. マネタイズポイント

- **プレミアム機能**: 交流スコアを2倍にするブースト
- **親しい友達枠拡張**: デフォルト50人 → プレミアムで無制限
- **ストーリー限定公開枠拡張**

### 4. データ分析

- **交流スコア**: どの機能が交流を生むか分析
- **レベル遷移率**: どれくらいのユーザーが親しい友達になるか
- **チャーン予測**: スコアが下がっているユーザーを検知

---

## 🔄 マイグレーション戦略

### 既存データの扱い

#### 1. `friendIds` → `connections`

```javascript
// マイグレーションスクリプト
async function migrateFriendIds() {
  const users = await admin.firestore().collection('users').get();

  for (const userDoc of users.docs) {
    const user = userDoc.data();
    const userId = userDoc.id;
    const friendIds = user.friendIds || [];

    for (const friendId of friendIds) {
      // 相互フォローをチェック
      const isMutual = await checkMutualFollow(userId, friendId);

      if (isMutual) {
        // つながりを作成
        await createConnection(userId, friendId);
      }
    }
  }
}
```

#### 2. `topFriends` の廃止

- 既存の `topFriends` は読み取り専用として残す
- 新規では使用せず、交流スコア上位12人を自動表示

---

## 📝 まとめ

### ✅ 設計のポイント

1. **シンプルな操作**: フォローボタン1つだけ
2. **自動進化**: 相互フォロー → つながり → 親しい友達
3. **可視化**: 交流スコアでモチベーション向上
4. **段階的解放**: レベルに応じて機能が増える

### 期待される効果

- **DAU向上**: 交流を促進する仕組み
- **リテンション向上**: 親しい友達ができると定着
- **UX向上**: シンプルで分かりやすい

### 次のアクション

1. Phase 1: データモデル実装
2. Phase 2: 相互フォロー検知
3. Phase 3: 交流スコアシステム
4. Phase 4: UI/UX実装

---

## 変更履歴
- 2025-10-06: 初版作成（段階的リレーションシステム設計完了）
