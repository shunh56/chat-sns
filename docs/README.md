# プロジェクトドキュメント

このディレクトリには、プロジェクトの各種ドキュメントが整理されています。

## 📁 ディレクトリ構成

```
docs/
├── README.md               # このファイル
├── features/              # 機能仕様
├── architecture/          # アーキテクチャ・設計
├── deployment/            # デプロイ・CI/CD
├── testing/               # テスト
├── development/           # 開発ガイド
└── planning/              # 企画・分析
```

---

## 🎯 機能仕様 (features/)

機能ごとの詳細仕様・テスト手順書

- [チャットリクエスト機能](./features/chat-request.md) - チャットリクエストの仕様とテスト手順
- [タグシステム最終版](./features/tagging-system-final.md) - タグシステムの最終仕様
- [タグシステムMVP実装](./features/tagging-system-mvp.md) - タグシステムMVP実装計画
- [タグシステムマイグレーション](./features/tagging-system-migration.md) - タグシステム移行ガイド
- [タグシステムユースケース](./features/tagging-system-usecase.md) - タグシステムのユースケースとUI
- [足あと機能v2マイグレーション](./features/footprint-migration-v2.md) - 足あと機能v2移行計画
- [足あと機能仕様](./footprint_specification.md) - 足あと機能の仕様
- [デバイス管理機能](./features/device-management.md) - デバイス管理実装

---

## 🏗 アーキテクチャ・設計 (architecture/)

システム設計・アーキテクチャ関連

- [アーキテクチャレビュー](./architecture/ARCHITECTURE_REVIEW.md) - システムアーキテクチャのレビュー
- [リファクタリング計画](./architecture/REFACTORING_PLAN.md) - コードリファクタリング計画
- [リレーションシステム再設計](./architecture/RELATIONSHIP_SYSTEM_REDESIGN.md) - リレーションシステムの再設計

---

## 🚀 デプロイ・CI/CD (deployment/)

デプロイメント・CI/CD関連

- [Fastlaneセットアップ](./deployment/FASTLANE_SETUP.md) - Fastlaneの導入と設定
- [iOS署名トラブルシューティング](./deployment/IOS_SIGNING_TROUBLESHOOTING.md) - iOS署名の問題解決
- [CI/CD改善計画](./deployment/CI_CD_IMPROVEMENTS.md) - CI/CDパイプラインの改善
- [Makefile-Fastlane連携](./deployment/MAKEFILE_FASTLANE_INTEGRATION.md) - MakefileとFastlaneの統合

---

## 🧪 テスト (testing/)

テスト計画・テストシナリオ

- [タグシステムテストシナリオ](./testing/TAG_SYSTEM_TEST_SCENARIOS.md) - タグシステムのテストケース

---

## 💻 開発ガイド (development/)

開発時のガイドライン

- [ブランチ戦略](./development/BRANCH_STRATEGY.md) - Gitブランチの運用方針

---

## 📋 企画・分析 (planning/)

プロダクト企画・ユーザー分析

- [ユーザーストーリーフロー](./planning/USER_STORY_FLOWS.md) - ユーザーストーリーのフロー図
- [Gen Zユーザー分析](./planning/USER_STORY_ANALYSIS_GEN_Z.md) - Gen Z世代のユーザー分析

---

## 🔗 その他のドキュメント

### プロジェクト概要
- [concept-md.md](./concept-md.md) - プロジェクトコンセプト
- [features-md.md](./features-md.md) - 機能一覧
- [mvp-plan-md.md](./mvp-plan-md.md) - MVP計画

### 技術仕様
- [database-md.md](./database-md.md) - データベース設計
- [api-spec-md.md](./api-spec-md.md) - API仕様

### デザイン
- [ui-ux-md.md](./ui-ux-md.md) - UI/UXデザイン
- [personas-md.md](./personas-md.md) - ペルソナ定義

### その他
- [marketing-md.md](./marketing-md.md) - マーケティング戦略
- [migration-md.md](./migration-md.md) - マイグレーション計画
- [makefile-specification.md](./makefile-specification.md) - Makefile仕様
- [CHANGELOG.md](./CHANGELOG.md) - 変更履歴

---

## 📝 ドキュメント作成ガイドライン

### 新しいドキュメントを追加する場合

1. 適切なカテゴリ（features/architecture/deployment/testing/development/planning）を選択
2. わかりやすいファイル名を付ける（例: `feature-name.md`）
3. 以下のテンプレートを使用

```markdown
# [機能名/ドキュメント名]

## 概要
簡潔な説明

## 詳細
詳しい内容

## 関連ドキュメント
- [関連ドキュメント](./path/to/doc.md)

## 更新履歴
| 日付 | バージョン | 変更内容 |
|------|-----------|---------|
| YYYY-MM-DD | 1.0.0 | 初版作成 |
```

4. このREADME.mdの該当セクションにリンクを追加

---

## 🔍 ドキュメントを探す

### 機能について知りたい
→ `features/` ディレクトリを確認

### 技術仕様を確認したい
→ `architecture/` または各種仕様書（database-md.md, api-spec-md.mdなど）を確認

### デプロイ方法を知りたい
→ `deployment/` ディレクトリを確認

### テスト方法を知りたい
→ `testing/` または各機能のテスト手順書を確認

---

## 📞 お問い合わせ

ドキュメントに関する質問や追加要望がある場合は、プロジェクトチームまでご連絡ください。

---

最終更新: 2025-XX-XX
