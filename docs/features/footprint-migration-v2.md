# Footprint機能 v2.0.0 移行ガイド

## 📋 概要

Footprint機能をネスト構造から親コレクション設計に移行しました。

### 変更点
- **Before**: `users/{userId}/footprinteds/{visitorId}`（ネスト構造）
- **After**: `footprints/{randomId}`（親コレクション）

### メリット
- ✅ データ量50%削減（2ドキュメント → 1ドキュメント）
- ✅ 書き込み回数50%削減
- ✅ クエリ効率向上
- ✅ 統計情報の正確性向上

---

## ⚠️ 必須対応（デプロイ前）

### 1. Firestoreインデックスの作成

**方法1: Firebase CLIでデプロイ（推奨）**
```bash
# プロジェクトルートから実行
firebase deploy --only firestore:indexes
```

**方法2: Firebase Consoleで手動作成**

以下の5つのインデックスを作成してください：

#### インデックス1（訪問者リスト）
- コレクション: `footprints`
- フィールド1: `visitedUserId` (Ascending)
- フィールド2: `visitedAt` (Descending)

#### インデックス2（未読カウント - 3フィールド）
- コレクション: `footprints`
- フィールド1: `visitedUserId` (Ascending)
- フィールド2: `visitedAt` (Descending)
- フィールド3: `isSeen` (Ascending)

#### インデックス3（未読カウント - 2フィールド）
- コレクション: `footprints`
- フィールド1: `visitedUserId` (Ascending)
- フィールド2: `isSeen` (Ascending)

#### インデックス4（削除用）
- コレクション: `footprints`
- フィールド1: `visitorId` (Ascending)
- フィールド2: `visitedUserId` (Ascending)

#### インデックス5（訪問先リスト）
- コレクション: `footprints`
- フィールド1: `visitorId` (Ascending)
- フィールド2: `visitedAt` (Descending)

---

### 2. 旧データの削除

**重要**: 旧データが残っていると、新しいアプリで読み込めずエラーになります。

#### 事前準備: Firebase認証
スクリプト実行前に、以下のいずれかの方法で認証してください：

**オプション1: gcloud CLI（推奨）**
```bash
gcloud auth application-default login
```

**オプション2: 環境変数**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"
```

#### ステップ1: DRY RUN（削除対象の確認）
```bash
cd functions
node cleanup_old_footprints.js --dry-run
```

#### ステップ2: 実行（旧データ削除）
```bash
cd functions
node cleanup_old_footprints.js
```

**注意**:
- このスクリプトはfunctionsディレクトリ内で実行してください
- `users/{userId}/footprinteds`と`users/{userId}/footprints`を完全に削除します
- 復元できません
- 必ずDRY RUNで確認してから実行してください

---

### 3. Firestore Security Rulesのデプロイ

```bash
# プロジェクトルートから実行
# firestore.rulesに以下を追加してデプロイ
firebase deploy --only firestore:rules
```

**追加するルール**:
```javascript
// footprint_rules.rulesの内容をfirestore.rulesにコピー
match /footprints/{footprintId} {
  allow read: if request.auth != null
              && (resource.data.visitorId == request.auth.uid
                  || resource.data.visitedUserId == request.auth.uid);

  allow create: if request.auth != null
                && request.resource.data.visitorId == request.auth.uid
                && request.resource.data.visitedUserId != request.auth.uid
                && request.resource.data.isSeen == false
                && request.resource.data.version == 2;

  allow update: if request.auth != null
                && resource.data.visitedUserId == request.auth.uid
                && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['isSeen'])
                && request.resource.data.isSeen == true;

  allow delete: if request.auth != null
                && resource.data.visitorId == request.auth.uid;
}
```

---

## 🔍 動作確認

### 1. インデックス作成の確認
Firebase Console → Firestore → インデックス タブで以下を確認：
- ✅ 5つのインデックスが「有効」になっている

### 2. 旧データ削除の確認
Firebase Console → Firestore → データ タブで以下を確認：
- ✅ `users/{userId}/footprinteds` サブコレクションが存在しない
- ✅ `users/{userId}/footprints` サブコレクションが存在しない

### 3. アプリでの動作確認
1. アプリをビルド: `flutter build apk` または `flutter run`
2. ユーザーAでログイン → ユーザーBのプロフィールを訪問
3. Firestoreで確認:
   - ✅ `footprints/{ランダムID}` が作成されている
   - ✅ `visitorId`, `visitedUserId`, `visitedAt`, `isSeen`, `version: 2`が存在
4. ユーザーBでログイン → 足あと画面を開く
   - ✅ ユーザーAが訪問者として表示される

---

## 📊 データ構造

### v2.0.0（新）
```
footprints/{randomId}
  ├── visitorId: "user123"       # 訪問者のID
  ├── visitedUserId: "user456"   # 訪問先のID
  ├── visitedAt: Timestamp       # 訪問日時
  ├── isSeen: false              # 既読フラグ
  └── version: 2                 # データバージョン
```

### v1.x（旧 - 削除対象）
```
users/{userId}/footprinteds/{visitorId}  ❌ 削除
users/{userId}/footprints/{targetId}     ❌ 削除
```

---

## ❓ トラブルシューティング

### エラー: "FAILED_PRECONDITION: The query requires an index"
→ Firestoreインデックスが未作成です。上記の手順1を実行してください。

### エラー: "type 'Null' is not a subtype of type 'String'"
→ 旧データが残っています。上記の手順2で旧データを削除してください。

### 足あとが表示されない
→ 以下を確認:
1. Firestoreインデックスが「有効」になっているか
2. Security Rulesがデプロイされているか
3. `footprints`コレクションにデータが作成されているか

---

## 📝 チェックリスト

デプロイ前に以下を確認してください：

- [ ] Firestoreインデックスを作成した（5つ）
- [ ] 旧データ削除スクリプトを実行した（DRY RUN → 本番）
- [ ] Firestore Security Rulesをデプロイした
- [ ] ローカル環境で動作確認した
- [ ] Firestoreコンソールでデータ構造を確認した

---

## 🚀 デプロイ手順

```bash
# 1. Firebase認証（初回のみ）
gcloud auth application-default login

# 2. インデックスデプロイ（プロジェクトルートから）
firebase deploy --only firestore:indexes

# 3. Security Rulesデプロイ（プロジェクトルートから）
firebase deploy --only firestore:rules

# 4. 旧データ削除（本番環境）
cd functions
# まずDRY RUNで確認
node cleanup_old_footprints.js --dry-run
# 問題なければ実行
node cleanup_old_footprints.js
cd ..

# 5. アプリデプロイ
flutter build apk --release
# または
flutter build ios --release
```

---

## 📌 重要な注意事項

1. **旧データは新しいアプリで読み込めません**
   - v1データには`visitorId`/`visitedUserId`フィールドがない
   - 必ず削除スクリプトで削除してください

2. **インデックス作成には時間がかかる場合があります**
   - データ量が多い場合、数分〜数十分かかることがあります
   - インデックスが「構築中」の間はクエリがエラーになります

3. **ロールバック不可**
   - 一度v2にアップデートしたら、v1には戻せません
   - 旧データを削除した後は復元できません

---

## 📞 サポート

問題が発生した場合は、以下の情報を含めて報告してください：
- エラーメッセージ
- Firestoreコンソールのスクリーンショット
- 実行したコマンド

---

作成日: 2025-10-06
バージョン: v2.0.0
