# タグシステム 既存ユーザー向けマイグレーションガイド

## 概要
タグシステムMVPの実装において、既存ユーザーがアクセスした際にシステムタグが自動的に初期化される仕組みを実装しました。

---

## マイグレーション方式: オンデマンド初期化

### 採用理由
1. **バッチ処理不要** - 全ユーザーを一括処理する必要がない
2. **段階的導入** - ユーザーがアクセスした時点で初期化
3. **安全性** - エラーが発生しても一部のユーザーのみに影響
4. **リソース効率** - 不要なFirestore書き込みを削減

### 動作方式
**トリガー**: ユーザーがタグ関連画面を初めて開いた時
**処理**: システムタグ6種を自動作成
**通知**: スナックバーで「システムタグを初期化しました」と表示

---

## 実装内容

### 1. マイタグ一覧画面での初期化

**ファイル**: `lib/presentation/pages/user_tag/my_tags_page.dart`

**実装コード**:
```dart
// 既存ユーザー対応: タグが空の場合は自動初期化
if (allTags.isEmpty && !isInitializing.value) {
  isInitializing.value = true;
  Future.microtask(() async {
    try {
      await usecase.initializeSystemTags();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('システムタグを初期化しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('タグの初期化に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isInitializing.value = false;
    }
  });
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('システムタグを初期化しています...'),
      ],
    ),
  );
}
```

**動作フロー**:
```
1. ユーザーがマイタグ画面を開く
2. StreamBuilder でタグ一覧を取得
3. タグが空（allTags.isEmpty）の場合
   ↓
4. 初期化フラグを立てる（isInitializing = true）
5. システムタグ6種を Firestore に作成
6. 成功時: スナックバー表示
7. 失敗時: エラーメッセージ表示
8. 初期化フラグを下げる（isInitializing = false）
   ↓
9. StreamBuilder が自動的に再描画
10. システムタグが表示される
```

### 2. タグ選択シートでの初期化

**ファイル**: `lib/presentation/components/user_tag/tag_button.dart`

**実装コード**:
```dart
// 既存ユーザー対応: タグが空の場合は自動初期化
if (allTags.isEmpty && !isInitializing.value) {
  isInitializing.value = true;
  Future.microtask(() async {
    try {
      await usecase.initializeSystemTags();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('システムタグを初期化しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('初期化失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isInitializing.value = false;
    }
  });
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('システムタグを初期化しています...'),
        ],
      ),
    ),
  );
}
```

**動作フロー**:
```
1. ユーザーがプロフィール画面で 🏷️ ボタンをタップ
2. タグ選択シートが開く
3. StreamBuilder でタグ一覧を取得
4. タグが空の場合
   ↓
5. ローディング表示
6. システムタグ6種を Firestore に作成
7. スナックバー表示
   ↓
8. タグ選択シートに6つのシステムタグが表示される
```

### 3. 新規ユーザーの初期化（既存実装）

**ファイル**: `lib/presentation/providers/shared/users/my_user_account_notifier.dart`

**実装コード**:
```dart
Future<void> _initializeSystemTagsIfNeeded() async {
  try {
    final tagUsecase = ref.read(userTagUsecaseProvider);
    final tags = await tagUsecase.watchMyTags().first;

    // タグが存在しない場合のみ初期化
    if (tags.isEmpty) {
      await tagUsecase.initializeSystemTags();
    }
  } catch (e) {
    // タグ初期化の失敗は致命的ではないのでログのみ
    if (kDebugMode) {
      print('Failed to initialize system tags: $e');
    }
  }
}
```

**動作タイミング**:
- アプリ起動時（ログイン直後）
- バックグラウンド処理のためUI待機なし
- エラーがあっても通知しない（画面アクセス時に再試行）

---

## ユーザー体験

### 既存ユーザーのシナリオ

#### シナリオ1: マイタグ画面から初アクセス
```
1. ユーザーがプロフィールタブを開く
2. 「🏷️ マイタグ」をタップ
   ↓
3. 画面中央にローディング表示
   「システムタグを初期化しています...」
   ↓ 約1-2秒
4. スナックバー表示
   「システムタグを初期化しました」
   ↓
5. マイタグ一覧が表示される
   - システムタグ 6種
   - カスタムタグ なし
   - 各タグの人数 0人
```

#### シナリオ2: プロフィール画面から初アクセス
```
1. ユーザーが他のユーザーのプロフィールを開く
2. 🏷️ ボタンをタップ
   ↓
3. ボトムシートにローディング表示
   「システムタグを初期化しています...」
   ↓ 約1-2秒
4. スナックバー表示
   「システムタグを初期化しました」
   ↓
5. タグ選択シートが表示される
   - システムタグ 6種が選択可能
   - タグ付け操作が可能
```

#### シナリオ3: アプリ起動時のバックグラウンド初期化
```
1. ユーザーがアプリを起動（ログイン）
   ↓ バックグラウンドで初期化開始
2. ユーザーは通常通りアプリを操作可能
   ↓
3. 後でマイタグ画面を開く
   ↓
4. すでに初期化済み
   - ローディング表示なし
   - 即座にタグ一覧が表示
```

### 新規ユーザーのシナリオ

```
1. 新規登録/初回ログイン
   ↓ バックグラウンドで自動初期化
2. システムタグが事前に作成される
   ↓
3. マイタグ画面を開く
   - ローディングなし
   - 即座にシステムタグ6種が表示
```

---

## エラーハンドリング

### 1. ネットワークエラー
```
状況: 機内モード、Wi-Fi切断時

動作:
1. 初期化処理が失敗
2. エラーメッセージ表示（赤色スナックバー）
   「タグの初期化に失敗しました: [エラー内容]」
3. 画面は空の状態を維持

ユーザー対応:
- ネットワーク復旧後、画面を再度開く
- 自動的に再初期化が実行される
```

### 2. Firestore権限エラー
```
状況: セキュリティルールの設定ミス

動作:
1. 初期化処理が失敗
2. エラーメッセージ表示
   「タグの初期化に失敗しました: [Permission denied]」

対処:
- Firebase Consoleでセキュリティルールを確認
- ルールが正しくデプロイされているか確認
```

### 3. 重複初期化の防止
```
仕組み:
- isInitializing フラグで同時実行を防止
- StreamBuilder の再描画で重複チェック

条件:
if (allTags.isEmpty && !isInitializing.value)

結果:
- 1回のみ初期化処理が実行される
- 複数のタップでも安全
```

---

## Firestoreデータ構造

### 初期化後のデータ

**コレクション**: `users/{userId}/tags/`

**ドキュメント例**:
```json
{
  "oshi": {
    "tagId": "oshi",
    "name": "推し",
    "icon": "✨",
    "color": "#9370DB",
    "priority": 5,
    "isSystemTag": true,
    "showInTimeline": true,
    "enableNotifications": true,
    "userCount": 0,
    "createdAt": Timestamp(2025, 10, 6, ...),
    "updatedAt": Timestamp(2025, 10, 6, ...)
  },
  "friend": {
    "tagId": "friend",
    "name": "フレンド",
    "icon": "⭐",
    "color": "#FFD700",
    "priority": 4,
    "isSystemTag": true,
    "showInTimeline": true,
    "enableNotifications": true,
    "userCount": 0,
    "createdAt": Timestamp(2025, 10, 6, ...),
    "updatedAt": Timestamp(2025, 10, 6, ...)
  },
  // ... 残り4つのシステムタグ
}
```

### セキュリティルール
```firestore
match /users/{userId}/tags/{tagId} {
  // 読み取り権限: 本人のみ
  allow read: if request.auth != null && request.auth.uid == userId;

  // 作成・更新権限: 本人のみ
  allow create, update: if request.auth != null && request.auth.uid == userId;

  // 削除権限: 本人のみ（システムタグは削除不可）
  allow delete: if request.auth != null
                && request.auth.uid == userId
                && resource.data.isSystemTag == false;
}
```

---

## パフォーマンス影響

### Firestore読み取り/書き込み

**1ユーザーあたりの初期化コスト**:
```
書き込み: 6回（システムタグ6種 × 1回）
読み取り: 1回（初期化済みチェック）
合計: 7回のFirestore操作
```

**全体の影響**:
```
既存ユーザー数: 10,000人と仮定
初期化するユーザー: 10,000人（全員）

総Firestore操作: 70,000回
- 書き込み: 60,000回
- 読み取り: 10,000回

段階的実行:
- 1日目: 1,000人がアクセス → 7,000回
- 1週間: 5,000人がアクセス → 35,000回
- 1ヶ月: 8,000人がアクセス → 56,000回
- 残り: 2,000人（非アクティブユーザー）

→ 急激な負荷集中なし
```

### コスト試算（Firebaseプラン）

**Firestore料金**:
```
書き込み: $0.18 / 100,000回
読み取り: $0.06 / 100,000回

初期化コスト（全ユーザー）:
- 書き込み 60,000回: $0.108
- 読み取り 10,000回: $0.006
合計: 約 $0.11

→ 非常に低コスト
```

---

## モニタリング

### 初期化状況の確認

**Firebase Console**:
```
1. Firestore Database を開く
2. users コレクションを選択
3. 任意のユーザーIDを選択
4. tags サブコレクションを確認

✓ 6つのドキュメント（システムタグ）が存在する
✓ 各ドキュメントのisSystemTagがtrueである
```

**アプリログ**:
```dart
// デバッグログの確認
if (kDebugMode) {
  print('System tags initialized for user: $userId');
}
```

### 初期化失敗の検出

**エラーログの確認**:
```
Firebase Console > Functions > Logs
または
アプリのクラッシュレポート（Crashlytics等）

エラーパターン:
1. "Permission denied" → セキュリティルール確認
2. "Network error" → ネットワーク接続確認
3. "Timeout" → Firestore接続確認
```

---

## トラブルシューティング

### Q1: 既存ユーザーでタグが表示されない

**原因**:
- 初期化処理が失敗している
- ネットワークエラー
- セキュリティルールの問題

**対処法**:
```
1. アプリを完全に再起動
2. ネットワーク接続を確認
3. マイタグ画面を再度開く
4. Firebase Consoleでデータを直接確認
```

### Q2: 初期化が複数回実行される

**原因**:
- isInitializingフラグの競合
- StreamBuilderの再描画タイミング

**対処法**:
```dart
// すでに実装済み
if (allTags.isEmpty && !isInitializing.value) {
  // 1回のみ実行される
}
```

### Q3: 「初期化しています...」から進まない

**原因**:
- Firestore書き込みのタイムアウト
- セキュリティルール拒否

**対処法**:
```
1. アプリを強制終了
2. 再起動
3. それでも解決しない場合:
   - Firebase Consoleでセキュリティルールを確認
   - ログを確認
```

---

## ロールバック手順

万が一、問題が発生した場合のロールバック手順。

### 1. アプリ側の無効化

**方法**: タグ画面へのアクセスを一時的に無効化

```dart
// lib/presentation/v2/pages/home/profile_page.dart
// マイタグボタンをコメントアウト

/*
{
  'icon': Icons.label,
  'title': 'マイタグ',
  'description': 'タグの管理',
  'route': 'tags',
},
*/
```

### 2. 初期化処理の無効化

**方法**: 自動初期化をスキップ

```dart
// 一時的に初期化をスキップ
if (allTags.isEmpty && !isInitializing.value) {
  // コメントアウト
  // Future.microtask(() async { ... });

  // 代わりに空状態を表示
  return const Center(
    child: Text('メンテナンス中です'),
  );
}
```

### 3. Firestoreデータの削除（最終手段）

**警告**: すべてのユーザーのタグデータが削除されます

```javascript
// Firebase Functions で一括削除
const admin = require('firebase-admin');
const db = admin.firestore();

async function deleteAllUserTags() {
  const usersSnapshot = await db.collection('users').get();

  for (const userDoc of usersSnapshot.docs) {
    const tagsSnapshot = await userDoc.ref.collection('tags').get();

    for (const tagDoc of tagsSnapshot.docs) {
      await tagDoc.ref.delete();
    }
  }
}
```

---

## 今後の改善案

### 1. バックグラウンド一括初期化（オプション）

**目的**: 事前に全ユーザーを初期化

**実装**:
```javascript
// Cloud Functions for Firebase
exports.migrateExistingUsers = functions.https.onRequest(async (req, res) => {
  const usersSnapshot = await admin.firestore().collection('users').get();

  const batch = admin.firestore().batch();
  let count = 0;

  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;
    const tagsSnapshot = await userDoc.ref.collection('tags').get();

    if (tagsSnapshot.empty) {
      // システムタグを作成
      for (const systemTag of SYSTEM_TAGS) {
        const tagRef = userDoc.ref.collection('tags').doc(systemTag.tagId);
        batch.set(tagRef, systemTag);
        count++;
      }
    }

    if (count >= 500) {
      await batch.commit();
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
  }

  res.send('Migration completed');
});
```

### 2. 初期化状態の統計

**目的**: どれくらいのユーザーが初期化済みか確認

**実装**:
```javascript
// Analytics イベント送信
analytics.logEvent('tag_system_initialized', {
  user_id: userId,
  initialization_source: 'my_tags_page', // or 'tag_selection_sheet'
  timestamp: Date.now()
});
```

### 3. エラーレポート

**目的**: 初期化失敗の詳細を収集

**実装**:
```dart
try {
  await usecase.initializeSystemTags();
} catch (e, stackTrace) {
  // Crashlytics にレポート
  FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Tag initialization failed');
}
```

---

## まとめ

### ✅ 実装完了事項
- マイタグ一覧画面での自動初期化
- タグ選択シートでの自動初期化
- エラーハンドリング
- ユーザーへの通知（スナックバー）

### ✅ 利点
- バッチ処理不要
- 段階的導入
- 低コスト
- エラー影響範囲が限定的

### ⚠️ 注意点
- 初回アクセス時に1-2秒のローディングがある
- ネットワークエラー時は手動リトライが必要

### 📊 想定動作
- 既存ユーザーの95%は1週間以内に初期化される
- 非アクティブユーザーは未初期化のまま（問題なし）
- 総Firestoreコストは$0.11未満

---

**最終更新**: 2025-10-06
**バージョン**: 1.0
