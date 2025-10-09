# フォロー独立型タグシステム 最終設計書

## 作成日
2025-10-06

## 概要
**フォローとは完全に独立**したプライベートタグシステム。\
ユーザーは誰に対しても（フォローの有無に関わらず）自由にタグを付けられる。

---

## 🎯 設計コンセプト

### 核心アイデア
**「フォロー = 公開的な繋がり」「タグ = プライベートなメモ・分類」**

```
フォロー
  ↓
公開的な行為（相手に通知が届く）
投稿が見える、足あとが残る

タグ付け
  ↓
プライベートな分類（相手には見えない）
自分だけの整理術
```

### 重要な分離
| 機能 | フォロー | タグ |
|-----|---------|------|
| **目的** | 繋がる | 分類・メモ |
| **公開性** | 相手に通知 | 完全プライベート |
| **対象** | 他のユーザー | 誰でも（フォロー外もOK） |
| **影響** | タイムライン表示 | 表示には影響しない |

---

## 📖 ユースケース

### UC-1: フォローしていない「推し」をタグ付け
```
みくは、有名人Aをフォローしていない（フォロー枠が埋まっている）。
でも、「推し」タグを付けて、自分の中で管理したい。
```

#### 実現可能な操作
```
1. プロフィール訪問
2. タグボタンをタップ
3. 「推し」タグを追加
4. フォローはしていないが、「推しリスト」に表示される
```

---

### UC-2: フォロー中だが「スキップ」したい人
```
あおいは、Bさんをフォローしているが、投稿があまり見たくない。
アンフォローは失礼なので、「スキップ」タグを付けて非表示にしたい。
```

#### 実現可能な操作
```
1. Bさんのプロフィールで「スキップ」タグを追加
2. フォローは継続（相手には分からない）
3. タイムラインでは「スキップ」タグを除外して表示
```

---

### UC-3: フォロー関係なく「気になる人」をリスト化
```
そうたは、まだフォローしていないが「気になる人」リストを作りたい。
後でフォローするかもしれないし、しないかもしれない。
```

#### 実現可能な操作
```
1. 気になる人のプロフィールで「気になる」タグを追加
2. フォローはしていない
3. 「気になるリスト」で一覧表示できる
4. 後日フォローするかどうか検討
```

---

### UC-4: フォロワーを分類（フォローバックしていない人）
```
みくは、自分をフォローしてくれている人（200人）を分類したい。
全員をフォローバックはしていないが、「ファン」「知り合い」などで分けたい。
```

#### 実現可能な操作
```
1. フォロワー一覧を見る
2. Aさんに「ファン」タグを追加
3. Bさんに「知り合い」タグを追加
4. フォローバックはしていないが、タグで管理できる
```

---

### UC-5: 複数タグで多面的に管理
```
あおいは、Cさんを「仕事」「フレンド」「ランチ仲間」の3タグで管理したい。
```

#### 実現可能な操作
```
1. Cさんに複数タグを追加
2. 「仕事」タブでも「フレンド」タブでも表示される
3. 検索で「ランチ仲間」を指定すると出てくる
```

---

## 🗂️ データモデル設計

### 1. `users/{userId}/tags/{tagId}` - カスタムタグ定義

ユーザーが作成したタグの定義。

```typescript
interface UserTag {
  tagId: string;           // タグID（自動生成 or システムタグID）
  name: string;            // 「推し」「仕事」「家族」など
  icon: string;            // Emoji: 😍, 💼, 👨‍👩‍👧‍👦
  color: string;           // カラーコード: #FF6B9D
  priority: number;        // 優先度 1〜5
  isSystemTag: boolean;    // true: プリセット, false: カスタム

  // 表示設定
  showInTimeline: boolean; // タイムラインに表示するか
  enableNotifications: boolean; // このタグの人からの通知を受け取るか

  // メタデータ
  createdAt: Timestamp;
  updatedAt: Timestamp;
  userCount: number;       // このタグが付いているユーザー数
}
```

#### システムタグのプリセット

```typescript
const SYSTEM_TAGS = [
  {
    tagId: 'oshi',
    name: '推し',
    icon: '✨',
    color: '#9370DB',
    priority: 5,
    isSystemTag: true,
    showInTimeline: true,
    enableNotifications: true,
  },
  {
    tagId: 'friend',
    name: 'フレンド',
    icon: '⭐',
    color: '#FFD700',
    priority: 4,
    isSystemTag: true,
    showInTimeline: true,
    enableNotifications: true,
  },
  {
    tagId: 'family',
    name: '家族',
    icon: '👨‍👩‍👧‍👦',
    color: '#90EE90',
    priority: 5,
    isSystemTag: true,
    showInTimeline: true,
    enableNotifications: true,
  },
  {
    tagId: 'work',
    name: '仕事',
    icon: '💼',
    color: '#4682B4',
    priority: 3,
    isSystemTag: true,
    showInTimeline: true,
    enableNotifications: false,  // 仕事は通知OFF推奨
  },
  {
    tagId: 'watch_later',
    name: '気になる',
    icon: '👀',
    color: '#87CEEB',
    priority: 2,
    isSystemTag: true,
    showInTimeline: false,  // フォローしていないので非表示
    enableNotifications: false,
  },
  {
    tagId: 'skip',
    name: 'スキップ',
    icon: '🚫',
    color: '#D3D3D3',
    priority: 1,
    isSystemTag: true,
    showInTimeline: false,  // 明示的に非表示
    enableNotifications: false,
  },
];
```

---

### 2. `user_tags/{userId}/tagged_users/{targetId}` ★ 新コレクション名

誰にどのタグを付けているかを記録。\
**フォロー状態とは完全に独立**。

```typescript
interface TaggedUser {
  userId: string;          // 自分のID
  targetId: string;        // タグを付けた相手のID
  tags: string[];          // タグID配列（複数可）

  // ★ フォロー状態は参照しない（独立している）
  // ★ 交流スコアは別途管理

  // メモ機能（オプション）
  memo?: string;           // プライベートメモ

  // メタデータ
  createdAt: Timestamp;    // 最初にタグを付けた日時
  updatedAt: Timestamp;    // 最終更新日時
}
```

#### 例

```json
// user_tags/user123/tagged_users/user456
{
  "userId": "user123",
  "targetId": "user456",
  "tags": ["oshi", "friend", "custom_tag_abc"],
  "memo": "推しの中でも特に好き",
  "createdAt": "2025-10-01T10:00:00Z",
  "updatedAt": "2025-10-06T15:30:00Z"
}
```

---

### 3. `followings/{userId}` - 既存のフォローシステム（維持）

フォローシステムは既存のまま維持。\
**タグとは完全に独立**。

```typescript
// followings/user123
{
  data: [
    { userId: "user456", createdAt: Timestamp },
    { userId: "user789", createdAt: Timestamp },
  ]
}
```

---

### 4. `users/{userId}` - カウンター追加

```typescript
interface UserAccount {
  // ... 既存フィールド

  followingCount: number;      // フォロー数（既存）
  followerCount: number;       // フォロワー数（既存）

  // ★ 新規追加: タグ関連のカウンター
  taggedUserCount: number;     // タグを付けたユーザー数
  customTagCount: number;      // 作成したカスタムタグ数
}
```

---

## 🎨 UI/UX設計

### 1. プロフィール画面

#### フォローボタン + タグボタン（独立）

```
┌─────────────────────────────┐
│   👤 山田太郎               │
│   @yamada_taro              │
│                             │
│   [ フォロー中 ▼ ]  [🏷️ タグ]│
│         ↑              ↑     │
│    フォロー状態      タグ管理│
│                             │
│   タグ: ⭐ 💼 😍          │
└─────────────────────────────┘
```

#### タグボタンをタップ → タグ選択メニュー

```
┌────────────────────────────┐
│ タグを選択                  │
├────────────────────────────┤
│ ✅ ⭐ フレンド              │
│ ✅ 💼 仕事                  │
│ ☐ ✨ 推し                  │
│ ☐ 👨‍👩‍👧‍👦 家族                 │
│ ☐ 👀 気になる               │
│ ☐ 🚫 スキップ               │
├────────────────────────────┤
│ 😍 推し友（カスタム）       │
│ 🎓 大学（カスタム）         │
├────────────────────────────┤
│ ➕ 新しいタグを作成        │
└────────────────────────────┘
```

#### フォロー状態との表示

```
フォロー中 + タグあり:
[ フォロー中 ▼ ]  [🏷️ ⭐💼]

フォロー中 + タグなし:
[ フォロー中 ▼ ]  [🏷️ タグ]

フォローしていない + タグあり:
[ フォロー ]  [🏷️ ✨👀]

フォローしていない + タグなし:
[ フォロー ]  [🏷️ タグ]
```

---

### 2. タグ管理画面（マイタグ）

```
┌────────────────────────────┐
│ マイタグ                    │
├────────────────────────────┤
│ システムタグ                │
├────────────────────────────┤
│ ✨ 推し (8人)              │
│ ⭐ フレンド (45人)         │
│ 👨‍👩‍👧‍👦 家族 (12人)           │
│ 💼 仕事 (20人)             │
│ 👀 気になる (15人)         │
│ 🚫 スキップ (5人)          │
├────────────────────────────┤
│ カスタムタグ                │
├────────────────────────────┤
│ 😍 推し友 (5人)            │
│ 🎓 大学 (30人)             │
│ 🎮 ゲーム友 (12人)         │
│ 🍕 ランチ仲間 (8人)        │
├────────────────────────────┤
│ ➕ 新しいタグを作成        │
└────────────────────────────┘
```

---

### 3. タグ詳細画面（タグをタップ）

```
┌────────────────────────────┐
│ ✨ 推し (8人)              │
├────────────────────────────┤
│ 設定                        │
│ ├ タイムライン表示: ON      │
│ ├ 通知: ON                  │
│ └ 優先度: ⭐⭐⭐⭐⭐      │
├────────────────────────────┤
│ タグが付いている人          │
├────────────────────────────┤
│ 👤 山田太郎 [フォロー中]   │
│ 👤 田中花子 [フォロー中]   │
│ 👤 佐藤次郎 [未フォロー]   │
│     ↑                       │
│   フォローしていなくてもOK  │
└────────────────────────────┘
```

---

### 4. タイムライン画面（タグフィルタ）

```
┌────────────────────────────┐
│ フィルタ: [すべて ▼]       │
├────────────────────────────┤
│ ☑️ フォロー中（全員）      │
│                             │
│ タグでフィルタ:             │
│ ☑️ ✨ 推し                  │
│ ☑️ ⭐ フレンド              │
│ ☐ 💼 仕事                  │
│ ☐ 👨‍👩‍👧‍👦 家族                 │
│                             │
│ ☑️ 🚫 スキップを除外       │
└────────────────────────────┘
```

#### フィルタ適用後

```
表示対象:
- フォロー中 AND (推しタグ OR フレンドタグ)
- かつ、スキップタグを除外
```

---

### 5. ユーザーリスト画面（タブバー）

```
┌──────┬──────┬──────┬──────┬──────┐
│フォロー│フォロワー│ 推し │フレンド│ +   │
│ 120  │  80  │  8   │  45  │     │
└──────┴──────┴──────┴──────┴──────┘
  ↑       ↑       ↑       ↑      ↑
フォロー フォロワー タグ   タグ   カスタム
 中の人   (逆方向)  で    で     タグ
                  フィルタ フィルタ 一覧
```

**重要**: 「推し」「フレンド」タブには、**フォローしていない人も含まれる**

---

## ⚙️ 実装ロジック

### 1. タグを追加（Flutter側）

```dart
// プロフィール画面でタグ追加
Future<void> addTag(String targetId, String tagId) async {
  final userId = currentUserId;

  // タグ追加
  await FirebaseFirestore.instance
      .doc('user_tags/$userId/tagged_users/$targetId')
      .set({
    'userId': userId,
    'targetId': targetId,
    'tags': FieldValue.arrayUnion([tagId]),
    'updatedAt': Timestamp.now(),
  }, SetOptions(merge: true));

  // カウンター更新（Cloud Functions で自動処理）
}
```

### 2. タグを削除

```dart
Future<void> removeTag(String targetId, String tagId) async {
  final userId = currentUserId;

  await FirebaseFirestore.instance
      .doc('user_tags/$userId/tagged_users/$targetId')
      .update({
    'tags': FieldValue.arrayRemove([tagId]),
    'updatedAt': Timestamp.now(),
  });
}
```

### 3. タグでユーザーを取得

```dart
Stream<List<UserAccount>> getUsersByTag(String tagId) {
  final userId = currentUserId;

  return FirebaseFirestore.instance
      .collection('user_tags/$userId/tagged_users')
      .where('tags', arrayContains: tagId)
      .snapshots()
      .asyncMap((snapshot) async {
    final targetIds = snapshot.docs
        .map((d) => d.data()['targetId'] as String)
        .toList();

    // ユーザー情報を取得
    final users = await Future.wait(
      targetIds.map((id) => getUserById(id))
    );

    return users;
  });
}
```

### 4. タイムラインをタグでフィルタ

```dart
Stream<List<Post>> getTimelineWithTagFilter(List<String> includeTags, List<String> excludeTags) {
  final userId = currentUserId;

  return FirebaseFirestore.instance
      .collection('user_tags/$userId/tagged_users')
      .where('tags', arrayContainsAny: includeTags)  // いずれかのタグを持つ
      .snapshots()
      .asyncMap((snapshot) async {
    final targetIds = snapshot.docs
        .map((d) => d.data()['targetId'] as String)
        .toList();

    // excludeTags を持つユーザーを除外
    final excludedUsers = await _getUsersByTags(excludeTags);
    final excludedIds = excludedUsers.map((u) => u.userId).toSet();

    final filteredIds = targetIds.where((id) => !excludedIds.contains(id)).toList();

    // フォロー中のユーザーと AND 条件
    final followingIds = await getFollowingIds();
    final finalIds = filteredIds.where((id) => followingIds.contains(id)).toList();

    // 投稿を取得
    return await getPostsByUserIds(finalIds);
  });
}
```

---

## 🔄 Firebase Functions

### 1. タグカウンター更新

```javascript
// Firebase Functions (Firestore Trigger)
exports.onTaggedUserChanged = functions.firestore
  .document('user_tags/{userId}/tagged_users/{targetId}')
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    const targetId = context.params.targetId;

    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;

    const beforeTags = before?.tags || [];
    const afterTags = after?.tags || [];

    // タグが追加された場合
    const addedTags = afterTags.filter(t => !beforeTags.includes(t));
    for (const tagId of addedTags) {
      await incrementTagCount(userId, tagId);
    }

    // タグが削除された場合
    const removedTags = beforeTags.filter(t => !afterTags.includes(t));
    for (const tagId of removedTags) {
      await decrementTagCount(userId, tagId);
    }

    // taggedUserCount 更新
    if (!before && after) {
      // 新規作成
      await FirebaseFirestore.instance.doc(`users/${userId}`).update({
        taggedUserCount: FieldValue.increment(1)
      });
    } else if (before && !after) {
      // 削除
      await FirebaseFirestore.instance.doc(`users/${userId}`).update({
        taggedUserCount: FieldValue.increment(-1)
      });
    }
  });

/**
 * タグのユーザー数をインクリメント
 */
async function incrementTagCount(userId, tagId) {
  await admin.firestore()
    .doc(`users/${userId}/tags/${tagId}`)
    .update({
      userCount: FieldValue.increment(1)
    });
}
```

---

## 📊 データ分析の可能性

### 1. タグ利用状況の分析

```sql
-- 人気タグランキング
SELECT tagId, COUNT(*) as usage_count
FROM user_tags/{userId}/tagged_users
GROUP BY tagId
ORDER BY usage_count DESC;
```

### 2. ユーザー間の関係性分析

```
誰が誰を「推し」タグに入れているか可視化
→ インフルエンサー検出
→ コミュニティ分析
```

### 3. タグの組み合わせ分析

```
「推し」+「フレンド」の組み合わせが多い
→ 推しと友達になりたい人が多い
→ 推し友マッチング機能を提案
```

---

## 💼 ビジネス的メリット

### 1. ユーザーエンゲージメント
- ✅ フォローしていない人もタグ付けできる → リスト作成が楽しい
- ✅ 「気になる」リストで後でフォロー → コンバージョン向上

### 2. データインサイト
- ✅ 誰が誰を「推し」に入れているか可視化
- ✅ タグの利用傾向でユーザー理解

### 3. プライバシー尊重
- ✅ タグは完全プライベート → 安心して使える
- ✅ フォローしなくても管理できる → 社交的負担軽減

### 4. カスタマイズ性
- ✅ Z世代が求める自己表現
- ✅ 自分だけの整理術

---

## 🚀 実装ステップ（18日間）

### Phase 1: データモデル実装 (3日)
1. `user_tags` コレクション作成
2. `users/{userId}/tags` コレクション作成
3. Firestore Security Rules

### Phase 2: タグUI実装 (5日)
1. プロフィール画面のタグボタン
2. タグ選択メニュー
3. システムタグのプリセット

### Phase 3: カスタムタグ作成 (4日)
1. タグ作成UI
2. アイコン・色選択
3. タグ編集・削除

### Phase 4: タグフィルタ (3日)
1. タイムラインフィルタ
2. ユーザーリストタブ
3. タグ詳細画面

### Phase 5: Firebase Functions (3日)
1. カウンター更新
2. タグ推薦
3. データ分析

---

## 📝 まとめ

### ✅ 設計の核心

| 項目 | 内容 |
|-----|------|
| **独立性** | フォローとタグは完全に独立 |
| **プライバシー** | タグは完全プライベート |
| **柔軟性** | フォロー外の人もタグ付け可能 |
| **カスタマイズ** | 自由にタグ作成 |
| **データ活用** | タグで関係性分析 |

### 期待される効果
- **エンゲージメント向上**: タグ付けが楽しい
- **整理整頓**: フォロー関係なく管理
- **データインサイト**: タグで関係性可視化
- **Z世代訴求**: カスタマイズ性と自己表現

### 次のアクション
1. Phase 1: データモデル実装
2. Phase 2: タグUI実装
3. Phase 3: カスタムタグ作成

---

## 変更履歴
- 2025-10-06: 初版作成（フォロー独立型タグシステム設計完了）
