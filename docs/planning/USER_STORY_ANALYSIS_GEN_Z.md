# Z世代向けリレーションシステム分析 & 再設計

## 作成日
2025-10-06

## 概要
Z世代のユーザーストーリーを深掘りし、**カスタマイズ性**と**自己表現**を重視した段階的リレーションシステムを再設計。

---

## 🧑‍🤝‍🧑 Z世代のユーザーストーリー分析

### ペルソナ設定

#### ペルソナ1: みく（18歳、大学1年生）
- **性格**: 社交的、新しい出会いが好き
- **SNS利用**: Instagram, TikTok ヘビーユーザー
- **ニーズ**: 「推しと繋がりたい」「趣味友を作りたい」

#### ペルソナ2: そうた（20歳、大学3年生）
- **性格**: 内向的、少人数との深い関係を好む
- **SNS利用**: Discord, X（旧Twitter）
- **ニーズ**: 「親友だけと深く繋がりたい」「プライバシー重視」

#### ペルソナ3: あおい（22歳、社会人1年目）
- **性格**: 多趣味、複数のコミュニティに所属
- **SNS利用**: Instagram, Threads, BeReal
- **ニーズ**: 「趣味ごとにグループ分けしたい」「仕事とプライベートを分けたい」

---

## 📖 ユーザーストーリー（US）

### US-1: 新しい人と出会う（みく）
```
みくは、大学で同じ趣味の人を見つけた。
気軽にフォローして、まずは様子を見たい。
```

#### 現在の設計の問題
- ✅ フォローはできる
- ❌ フォローした時点で「どういう関係」か分からない
- ❌ 後から整理するのが面倒

#### 改善案
- ✅ **フォロー時にタグを選べる**（例: 「大学」「趣味友」）
- ✅ タグは後から変更可能
- ✅ 複数タグ設定可能

---

### US-2: 推しと繋がる（みく）
```
みくは、推しのアーティストをフォローした。
他のフォロワーとは違う「特別な存在」として管理したい。
```

#### 現在の設計の問題
- ❌ 「フレンド」「親友」では表現できない
- ❌ 「推し」というカテゴリがない

#### 改善案
- ✅ **カスタムタグ「推し」を作成**
- ✅ 「推し」タグにはハートアイコン💖
- ✅ 推しの投稿を最優先表示

---

### US-3: 友達をグループ分け（あおい）
```
あおいは、友達を「仕事」「趣味」「家族」に分けたい。
タイムラインで特定のグループだけ見たい。
```

#### 現在の設計の問題
- ❌ ラベルが1つしか付けられない
- ❌ グループ分けができない

#### 改善案
- ✅ **複数タグ設定可能**（例: 「仕事」+「フレンド」）
- ✅ タグごとにタイムラインフィルタ
- ✅ 「仕事」タグだけ通知OFF可能

---

### US-4: 親友だけに限定公開（そうた）
```
そうたは、内向的で親友3人だけと深く繋がりたい。
親友だけに見せる投稿やストーリーを作りたい。
```

#### 現在の設計の問題
- ✅ 「親友」ラベルはあるが、カスタマイズ性がない
- ❌ 「親友」という名前が固定

#### 改善案
- ✅ **「親友」タグの名前を変更可能**（例: 「マブダチ」「相棒」）
- ✅ 親友タグのユーザーだけに限定公開
- ✅ 親友タグは最大20人まで

---

### US-5: フォロワーを整理する（あおい）
```
あおいは、フォロワーが増えすぎて整理したい。
「スキップ」ではなく「知り合い」程度の関係として残したい。
```

#### 現在の設計の問題
- ❌ 「スキップ」は「非表示」の意味が強すぎる
- ❌ 「知り合い」レベルのタグがない

#### 改善案
- ✅ **「知り合い」タグを追加**（通知少なめ、表示は残す）
- ✅ タグの優先度を可視化（星の数で表現）

---

### US-6: タグを自分好みにカスタマイズ（みく）
```
みくは、Z世代らしく自己表現したい。
「フレンド」ではなく「モーニング娘。好き友」「推し友」のように
自分だけのタグを作りたい。
```

#### 現在の設計の問題
- ❌ ラベルが固定（following, friend, best_friend）
- ❌ 自己表現ができない

#### 改善案
- ✅ **カスタムタグを自由に作成**
- ✅ タグごとにアイコン・色をカスタマイズ
- ✅ プリセットタグ + カスタムタグの両方提供

---

## 🎯 Z世代が求めるもの

### 1. カスタマイズ性
- **固定されたラベルではなく、自分で作れるタグ**
- Instagram の「親しい友達」、TikTok の「お気に入り」のように

### 2. 自己表現
- **タグの名前、アイコン、色を自由に設定**
- 「フレンド」ではなく「推し友」「バイト仲間」など

### 3. プライバシーコントロール
- **タグごとに公開範囲を設定**
- 「家族」タグには見せない投稿など

### 4. シンプルさ
- **複雑すぎない UI**
- フォロー時にサクッとタグ選択、後から変更可能

### 5. 視覚的な分かりやすさ
- **アイコン、色で直感的に区別**
- タグクラウド、カラフルなバッジ

---

## 🚀 新設計: カスタムタグシステム

### コンセプト
**「フォロー + 自由にタグ付け」**

### タグの種類

#### 1. システムタグ（プリセット）
| タグ名 | アイコン | 色 | 意味 |
|-------|---------|---|------|
| **フォロー中** | 👤 | グレー | デフォルト |
| **フレンド** | ⭐ | 黄色 | 気になる人 |
| **親友** | 💖 | ピンク | 特に親しい |
| **知り合い** | 👋 | 水色 | カジュアル |
| **推し** | ✨ | 紫 | 憧れの人 |
| **家族** | 👨‍👩‍👧‍👦 | 緑 | 家族・親戚 |

#### 2. カスタムタグ（ユーザー作成）
```typescript
interface CustomTag {
  id: string;
  name: string;          // 「推し友」「バイト仲間」など自由
  icon: string;          // Emoji または Icon
  color: string;         // カラーコード
  priority: number;      // 優先度（1〜5）
  createdAt: Timestamp;
}
```

### タグの機能レベル

| 優先度 | 機能 |
|-------|------|
| **1** | タイムライン非表示、通知なし |
| **2** | タイムライン表示（低優先）、基本通知のみ |
| **3** | タイムライン優先表示、すべて通知 |
| **4** | タイムライン最優先、常に通知 |
| **5** | 最最優先、プッシュ通知必須 |

---

## 🎨 UI/UX設計（Z世代向け）

### 1. フォロー時のタグ選択

#### フォローボタンを長押し → タグ選択メニュー

```
┌────────────────────────────┐
│ どんな関係ですか？          │
├────────────────────────────┤
│ 👤 フォロー中（デフォルト）│
│ ⭐ フレンド                │
│ 💖 親友                    │
│ ✨ 推し                    │
│ 👨‍👩‍👧‍👦 家族                 │
├────────────────────────────┤
│ ➕ カスタムタグを作成      │
└────────────────────────────┘
```

#### タップでフォロー → デフォルトは「フォロー中」

```
[  フォロー  ]  ← タップ: デフォルトでフォロー
                  長押し: タグ選択
```

### 2. カスタムタグ作成

```
┌────────────────────────────┐
│ 新しいタグを作成            │
├────────────────────────────┤
│ タグ名:                     │
│ [推し友_____________]       │
├────────────────────────────┤
│ アイコン:                   │
│ 😍 💕 🌟 🎉 ✨ 🔥        │
│ （絵文字選択）              │
├────────────────────────────┤
│ カラー:                     │
│ 🟥 🟧 🟨 🟩 🟦 🟪         │
├────────────────────────────┤
│ 優先度:                     │
│ ⭐☆☆☆☆ (1: 低)           │
│ ⭐⭐⭐☆☆ (3: 中)          │
│ ⭐⭐⭐⭐⭐ (5: 最高)       │
├────────────────────────────┤
│        [ 作成 ]            │
└────────────────────────────┘
```

### 3. プロフィール画面の表示（複数タグ対応）

```
┌─────────────────────────────┐
│   👤 山田太郎               │
│   @yamada_taro              │
│                             │
│   [ ⭐💖 フォロー中 ]       │
│     ↑  ↑                   │
│  フレンド 親友              │
│                             │
│   タグ: #フレンド #親友     │
└─────────────────────────────┘
```

### 4. タブバー（タグフィルタ）

```
┌──────┬──────┬──────┬──────┬──────┐
│すべて│フレンド│ 親友 │ 推し │ +   │
│ 120  │  45  │  12  │  8   │     │
└──────┴──────┴──────┴──────┴──────┘
  ↑       ↑       ↑       ↑      ↑
全タグ  tag=friend best  oshi  カスタム
```

#### 「+」タップでカスタムタグ一覧

```
┌────────────────────────────┐
│ マイタグ                    │
├────────────────────────────┤
│ 😍 推し友 (5人)            │
│ 🎓 大学 (20人)             │
│ 💼 仕事 (15人)             │
│ 🎮 ゲーム友 (8人)          │
├────────────────────────────┤
│ ➕ 新しいタグを作成        │
└────────────────────────────┘
```

### 5. タイムライン（タグフィルタ）

```
┌────────────────────────────┐
│ フィルタ: [すべて ▼]       │
│                             │
│ ✅ 💖 親友                  │
│ ✅ ⭐ フレンド              │
│ ✅ 😍 推し友                │
│ ☐ 👤 フォロー中             │
│ ☐ 👋 知り合い               │
└────────────────────────────┘
```

---

## 🗂️ データモデル設計（改良版）

### 1. `users/{userId}/tags/{tagId}` ★ 新規コレクション

ユーザーが作成したカスタムタグを保存。

```typescript
interface UserTag {
  tagId: string;           // タグID（自動生成）
  name: string;            // 「推し友」「バイト仲間」など
  icon: string;            // Emoji または Icon
  color: string;           // #FF6B9D など
  priority: number;        // 1〜5（優先度）
  isSystemTag: boolean;    // false（カスタムタグ）
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### システムタグのプリセット

```typescript
const SYSTEM_TAGS = [
  { tagId: 'following', name: 'フォロー中', icon: '👤', color: '#gray', priority: 2 },
  { tagId: 'friend', name: 'フレンド', icon: '⭐', color: '#FFD700', priority: 3 },
  { tagId: 'best_friend', name: '親友', icon: '💖', color: '#FF69B4', priority: 4 },
  { tagId: 'acquaintance', name: '知り合い', icon: '👋', color: '#87CEEB', priority: 2 },
  { tagId: 'oshi', name: '推し', icon: '✨', color: '#9370DB', priority: 5 },
  { tagId: 'family', name: '家族', icon: '👨‍👩‍👧‍👦', color: '#90EE90', priority: 4 },
];
```

### 2. `relationships/{userId}/labels/{targetId}` ★ 複数タグ対応

```typescript
interface RelationshipLabel {
  userId: string;
  targetId: string;
  tags: string[];          // ★ 複数タグ（配列）['friend', 'custom_tag_123']

  // 交流スコア（参考データ）
  interactionScore: number;
  lastInteractionAt: Timestamp;
  totalDmCount: number;
  totalCallDuration: number;

  // メタデータ
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 例

```json
{
  "userId": "user123",
  "targetId": "user456",
  "tags": ["friend", "custom_tag_abc"],  // フレンド + カスタムタグ
  "interactionScore": 75,
  "lastInteractionAt": "2025-10-06T10:00:00Z"
}
```

---

## ⚙️ 実装ロジック

### 1. タグ作成（Flutter側）

```dart
Future<void> createCustomTag({
  required String name,
  required String icon,
  required String color,
  required int priority,
}) async {
  final userId = currentUserId;
  final tagId = FirebaseFirestore.instance.collection('dummy').doc().id;

  await FirebaseFirestore.instance
      .doc('users/$userId/tags/$tagId')
      .set({
    'tagId': tagId,
    'name': name,
    'icon': icon,
    'color': color,
    'priority': priority,
    'isSystemTag': false,
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  });
}
```

### 2. フォロー時にタグ選択

```dart
Future<void> followUser(String targetId, List<String> tags) async {
  final userId = currentUserId;

  // 1. フォロー処理（既存）
  await followDatasource.followUser(userId, targetId);

  // 2. ラベル作成（複数タグ）
  await FirebaseFirestore.instance
      .doc('relationships/$userId/labels/$targetId')
      .set({
    'userId': userId,
    'targetId': targetId,
    'tags': tags.isEmpty ? ['following'] : tags,  // デフォルトは 'following'
    'interactionScore': 0,
    'lastInteractionAt': Timestamp.now(),
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  });
}
```

### 3. タグ追加・削除

```dart
Future<void> addTag(String targetId, String tagId) async {
  final userId = currentUserId;

  await FirebaseFirestore.instance
      .doc('relationships/$userId/labels/$targetId')
      .update({
    'tags': FieldValue.arrayUnion([tagId]),
    'updatedAt': Timestamp.now(),
  });
}

Future<void> removeTag(String targetId, String tagId) async {
  final userId = currentUserId;

  await FirebaseFirestore.instance
      .doc('relationships/$userId/labels/$targetId')
      .update({
    'tags': FieldValue.arrayRemove([tagId]),
    'updatedAt': Timestamp.now(),
  });
}
```

### 4. タグでフィルタ

```dart
Stream<List<UserAccount>> getUsersByTag(String tagId) {
  final userId = currentUserId;

  return FirebaseFirestore.instance
      .collection('relationships/$userId/labels')
      .where('tags', arrayContains: tagId)
      .snapshots()
      .asyncMap((snapshot) async {
    final targetIds = snapshot.docs.map((d) => d.data()['targetId']).toList();

    // ユーザー情報を取得
    final users = await Future.wait(
      targetIds.map((id) => getUserById(id))
    );

    return users;
  });
}
```

---

## 📊 Z世代への訴求ポイント

### 1. カスタマイズ性
- ✅ **自分だけのタグを作れる**
- ✅ アイコン、色を自由に設定
- ✅ Instagram の「ストーリーハイライト」的な楽しさ

### 2. 自己表現
- ✅ 「フレンド」ではなく「推し友」「バイト仲間」
- ✅ Z世代の言葉で表現できる

### 3. シンプルさ
- ✅ フォローは1タップ
- ✅ タグ追加も簡単（長押し or +ボタン）

### 4. プライバシー
- ✅ タグごとに公開範囲を設定可能（将来実装）
- ✅ 「家族」タグには見せない投稿など

### 5. 視覚的
- ✅ カラフルなタグバッジ
- ✅ アイコンで直感的に区別

---

## 📱 実装ステップ（20日間）

### Phase 1: システムタグ実装 (4日)
1. プリセットタグのUI実装
2. タグ選択メニュー
3. 複数タグ対応

### Phase 2: カスタムタグ作成 (5日)
1. タグ作成UI
2. アイコン・色選択
3. Firestore保存

### Phase 3: タグフィルタ (4日)
1. タブバーにタグ追加
2. タイムラインフィルタ
3. タグクラウドUI

### Phase 4: タグ管理 (3日)
1. タグ編集・削除
2. タグ並び替え
3. タグ統計

### Phase 5: データ分析 (4日)
1. タグごとの交流スコア
2. 人気タグランキング
3. ダッシュボード

---

## 📝 まとめ

### ✅ Z世代に響くポイント
1. **カスタマイズ性**: 自分だけのタグ
2. **自己表現**: Z世代の言葉で表現
3. **シンプル**: フォロー + タグ
4. **視覚的**: カラフル、アイコン
5. **プライバシー**: タグごとに制御

### 期待される効果
- **エンゲージメント向上**: タグ作成が楽しい
- **整理整頓**: フォロワーを自分好みに管理
- **データ活用**: タグごとの分析

### 次のアクション
1. Phase 1: システムタグ実装
2. Phase 2: カスタムタグ作成
3. Phase 3: タグフィルタ

---

## 変更履歴
- 2025-10-06: 初版作成（Z世代向けカスタムタグシステム設計）
