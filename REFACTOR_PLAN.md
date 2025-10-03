# 大幅リファクタプラン

## 現状分析
プロジェクト内に多数の未使用ファイルが散在している状況。既に一部は`UNUSED`、`_not_used`フォルダに整理されているが、統一されていない。

## 提案する整理構造

### 1. 未使用ファイル統一ディレクトリ
```
app/
├── _archived/                 # 未使用ファイルの統一保管場所
│   ├── core/                  # 未使用のコアファイル
│   ├── data/                  # 未使用のデータ層
│   ├── domain/                # 未使用のドメイン層
│   ├── presentation/          # 未使用のプレゼンテーション層
│   ├── config/                # 未使用の設定ファイル
│   └── docs/                  # 関連ドキュメント
└── lib/                       # アクティブなコード
```

### 2. 移動対象ファイル

#### a) 既存のUNUSEDフォルダ
- `lib/presentation/UNUSED/` → `_archived/presentation/community/`
- `lib/data/repository/posts/UNUSED/` → `_archived/data/repository/posts/`
- `lib/domain/entity/posts/UNUSED/` → `_archived/domain/entity/posts/`
- `lib/presentation/pages/posts/_not_used/` → `_archived/presentation/pages/posts/`

#### b) 明らかに未使用と思われるファイル
- `firebase_json_fix.dart` → `_archived/scripts/`
- 重複している設定ファイル
- テスト用のスクリーンファイル

#### c) 環境固有ファイルの整理
- `ios/appstore.xcconfig`
- `ios/dev.xcconfig`
- `ios/prod.xcconfig`
これらは使用中だが、環境設定として整理

### 3. 整理後の利点
- アクティブなコードと非アクティブなコードの明確な分離
- プロジェクトの見通しが良くなる
- 将来的な機能復活時の参考として保持
- IDEでの検索・ナビゲーションが高速化

### 4. 実行手順
1. `_archived`ディレクトリ作成
2. 既存UNUSEDフォルダの移動
3. 個別未使用ファイルの特定と移動
4. `pubspec.yaml`の依存関係クリーンアップ
5. import文の整理
6. `.gitignore`の更新（必要に応じて）

## 実行結果 (2024-10-02)

### ✅ 完了項目
1. `_archived`ディレクトリ作成 ✅
2. 既存UNUSEDフォルダの移動 ✅
   - 95ファイルをアーカイブ
3. 破損したimportの修正 ✅
   - コメントアウトまたは代替実装
4. `analysis_options.yaml`で`_archived`を解析対象から除外 ✅
5. Flutter analyzeエラー数を292から30に削減 ✅

### 📊 成果
- **アーカイブされたファイル数**: 95ファイル
- **削減されたFlutter解析エラー**: 262個 (90%削減)
- **整理されたディレクトリ**:
  - コミュニティ機能関連
  - トピック機能関連
  - 未使用投稿機能関連
  - その他UNUSED項目

### 📁 新しいプロジェクト構造
```
app/
├── _archived/          # 🗂️ 未使用ファイル保管庫
│   ├── data/           # データ層
│   ├── domain/         # ドメイン層
│   ├── presentation/   # プレゼンテーション層
│   ├── scripts/        # ユーティリティ
│   └── README.md       # アーカイブ履歴
├── lib/                # 🎯 アクティブなコード
└── REFACTOR_PLAN.md    # このファイル
```

## 注意事項
- 移動前にgitで現在の状態をコミット
- 各ファイルが本当に未使用かの確認
- 依存関係の破綻がないかテスト実行
- チーム内での合意形成

## 今後の提案
- 定期的なアーカイブレビュー
- 新機能開発時の参考資料として活用
- 不要になったアーカイブファイルの削除検討