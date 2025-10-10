# 🌿 ブランチ戦略・開発運用手順書

## ブランチ構成
```
main (本番環境)
├── develop (開発統合環境)
└── feature/* (機能開発ブランチ)
```

## 📋 開発フロー

### 1. 新機能開発
```bash
# 1. developブランチから作業開始
git checkout develop
git pull origin develop

# 2. 機能ブランチ作成
git checkout -b feature/音声通話品質向上
# または
git checkout -b feature/user-profile-enhancement

# 3. 開発・コミット
git add .
git commit -m "feat: 音声通話の品質向上機能を追加"
# コミットメッセージ例:
# feat: 新機能追加
# fix: バグ修正
# docs: ドキュメント更新
# style: コードフォーマット
# refactor: リファクタリング
```

### 2. Pull Request作成
```bash
# 4. リモートにプッシュ
git push origin feature/音声通話品質向上

# 5. GitHub上でPR作成
# feature/音声通話品質向上 → develop
```

### 3. 自動チェック
- ✅ `flutter analyze` - 静的解析
- ✅ `dart format` - コードフォーマット
- ✅ `flutter test` - ユニットテスト
- ✅ カバレッジレポート生成

### 4. developへのマージ
```bash
# PR承認後、自動的に以下が実行される:
# - TestFlight配布 (iOS)
# - Internal Testing配布 (Android)
# - Firebase App Distributionでテスター配布
```

### 5. 本番リリース
```bash
# 6. developからmainへのPR作成
# develop → main

# 7. mainブランチマージ後:
# - 自動バージョンアップ (patch)
# - 本番環境デプロイ (手動承認)
# - App Store/Google Playリリース準備
```

## 🎯 バージョン管理

### 自動バージョンアップ
- **mainマージ時**: 自動でpatchバージョンアップ (1.2.1 → 1.2.2)

### 手動バージョン指定
```bash
# コミットメッセージにタグを追加:
git commit -m "新しい音声機能を追加 [minor]"  # 1.2.1 → 1.3.0
git commit -m "UI大幅リニューアル [major]"    # 1.2.1 → 2.0.0
git commit -m "ドキュメント更新 [skip version]" # バージョンアップなし
```

## 📱 環境とデプロイ

| ブランチ | 環境 | トリガー | 配布先 |
|---------|------|----------|--------|
| `feature/*` | - | PR作成 | レビュー時のみテスト実行 |
| `develop` | 開発環境 | PRマージ | TestFlight + Internal Testing |
| `main` | 本番環境 | PRマージ | 本番環境 (手動承認) |

## 🚀 実際の開発例

### 例1: バグ修正
```bash
git checkout develop
git pull origin develop
git checkout -b feature/fix-login-crash

# 修正作業
git add .
git commit -m "fix: ログイン時のクラッシュを修正"
git push origin feature/fix-login-crash

# GitHub上でPR: feature/fix-login-crash → develop
# マージ後、自動でTestFlightに配布される
```

### 例2: 新機能開発
```bash
git checkout develop
git pull origin develop
git checkout -b feature/voice-chat-rooms

# 開発作業
git add .
git commit -m "feat: 音声チャットルーム機能を追加"
git push origin feature/voice-chat-rooms

# PR → develop → テスト → main → 本番リリース
```

### 例3: 緊急修正 (Hotfix)
```bash
# 緊急の場合はmainから直接
git checkout main
git pull origin main
git checkout -b hotfix/critical-security-fix

# 修正
git commit -m "fix: 重要なセキュリティ修正 [patch]"
git push origin hotfix/critical-security-fix

# PR: hotfix/critical-security-fix → main
# 即座に本番適用、その後developにもマージ
```

## 📋 PR作成時のチェックリスト

- [ ] コードレビュー依頼者を設定
- [ ] 機能説明・変更内容を記載
- [ ] スクリーンショット添付（UI変更の場合）
- [ ] テスト実行確認
- [ ] 関連するIssueをリンク

## 🔧 ローカル開発環境セットアップ

```bash
# 1. リポジトリクローン
git clone <repository-url>
cd app

# 2. Flutter依存関係取得
flutter pub get

# 3. テスト実行
flutter test

# 4. 静的解析
flutter analyze

# 5. フォーマットチェック
dart format --set-exit-if-changed .
```

## 📞 トラブルシューティング

### テスト失敗時
```bash
# 詳細なテストレポート確認
flutter test --reporter expanded

# 特定のテストのみ実行
flutter test test/unit/string_extension_test.dart
```

### CI/CDエラー時
- GitHub Actionsタブで詳細ログ確認
- ローカルで同じコマンドを実行してデバッグ
- 必要に応じて `[skip ci]` でCI/CDスキップ

## 🎬 CI/CDパイプライン概要

### GitHub Actions
1. **ci.yml**: PRとプッシュ時のテスト・解析
2. **version-bump.yml**: mainマージ時の自動バージョンアップ
3. **deploy.yml**: (次ステップで作成) 自動デプロイ

### コマンドショートカット

```bash
# バージョン手動更新
./scripts/bump_version.sh patch  # 1.2.1 → 1.2.2
./scripts/bump_version.sh minor  # 1.2.1 → 1.3.0
./scripts/bump_version.sh major  # 1.2.1 → 2.0.0
```

---

このドキュメントは開発チームの拡大に合わせて随時更新していきます。
質問や改善案がある場合は、Issueを作成してください。