# アーカイブディレクトリ

このディレクトリには、現在使用されていないが将来的に参考にする可能性があるファイルが保管されています。

## 構造

```
_archived/
├── core/                  # 未使用のコアファイル
├── data/                  # 未使用のデータ層
│   └── repository/posts/  # 未使用のpost関連リポジトリ
├── domain/                # 未使用のドメイン層
│   └── entity/posts/      # 未使用のpost関連エンティティ
├── presentation/          # 未使用のプレゼンテーション層
│   ├── community/         # 旧コミュニティ機能関連
│   └── pages/posts/       # 未使用のpost関連ページ
├── config/                # 未使用の設定ファイル
├── scripts/               # ユーティリティスクリプト
└── docs/                  # 関連ドキュメント
```

## 移動履歴

### 2024-10-02
- `lib/presentation/UNUSED/` → `_archived/presentation/community/`
- `lib/data/repository/posts/UNUSED/` → `_archived/data/repository/posts/`
- `lib/domain/entity/posts/UNUSED/` → `_archived/domain/entity/posts/`
- `lib/presentation/pages/posts/_not_used/` → `_archived/presentation/pages/posts/`
- `firebase_json_fix.dart` → `_archived/scripts/`

### 追加アーカイブ (2024-10-02)
#### コミュニティ機能関連
- `lib/data/repository/community_repository.dart` → `_archived/data/repository/`
- `lib/domain/usecases/comunity_usecase.dart` → `_archived/domain/usecases/`
- `lib/data/datasource/comunity_datasouce.dart` → `_archived/data/datasource/`
- `lib/presentation/providers/community.dart` → `_archived/presentation/providers/`
- `lib/presentation/providers/community_message_notifier.dart` → `_archived/presentation/providers/`

#### トピック機能関連
- `lib/data/repository/topics_repository.dart` → `_archived/data/repository/`
- `lib/domain/usecases/topics_usecase.dart` → `_archived/domain/usecases/`
- `lib/data/datasource/topics_datasource.dart` → `_archived/data/datasource/`
- `lib/presentation/providers/topics.dart` → `_archived/presentation/providers/`

#### 未使用投稿機能関連
- `lib/domain/usecases/posts/current_status_post_usecase.dart` → `_archived/domain/usecases/`
- `lib/domain/usecases/posts/blog_usecase.dart` → `_archived/domain/usecases/`
- `lib/domain/usecases/posts/algolia_post_usecase.dart` → `_archived/domain/usecases/`

## 注意事項

- このディレクトリのファイルは現在のプロジェクトでは使用されていません
- 削除せずに保管しているのは、将来的な機能復活や参考のためです
- 新しい機能開発時に類似の実装を探す際の参考にしてください