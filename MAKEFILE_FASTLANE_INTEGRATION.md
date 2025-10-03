# Makefile + Fastlane 統合運用ガイド 🚀

## 現在の構成

### 環境分け
- **dev**: 開発環境（`dart_defines/dev.env`）
- **prod**: 本番環境（`dart_defines/prod.env`）
- **appstore**: App Store提出用（`dart_defines/appstore.env`）

## 📱 Makefile + Fastlane統合コマンド

### 開発環境向けビルド＆デプロイ

```bash
# iOS: 開発環境でTestFlightへ
cd ios && fastlane beta env:dev

# Android: 開発環境でInternal Testingへ
cd android && fastlane beta env:dev

# Firebase App Distribution（両プラットフォーム）
cd ios && fastlane firebase env:dev
cd android && fastlane firebase env:dev
```

### 本番環境向けビルド＆デプロイ

```bash
# iOS: 本番環境でTestFlightへ
cd ios && fastlane beta env:prod

# Android: 本番環境でInternal Testingへ
cd android && fastlane beta env:prod

# App Store提出用
cd ios && fastlane beta env:appstore
```

## 🔄 既存Makefileコマンドとの連携

### ローカル開発（既存通り）
```bash
# 開発環境でビルド&実行
make dev-release       # iOS
make dev-android-release  # Android

# 本番環境でビルド&実行
make prod-release      # iOS
make prod-android-release # Android
```

### CI/CD用ビルド（Fastlane経由）
```bash
# Makefileのビルドコマンドを内部で使用
# iOS: make build-dev → TestFlight
# Android: flavorとdart-defineを指定してビルド
```

## 📊 運用フロー比較

| タスク | 従来（Makefile） | 新規（Fastlane） | 使い分け |
|--------|----------------|-----------------|----------|
| ローカルデバッグ | `make dev-release` | - | Makefile使用 |
| ローカルビルド | `make build-dev` | - | Makefile使用 |
| TestFlight配布 | 手動アップロード | `fastlane beta env:dev` | Fastlane使用 |
| Play Store配布 | 手動アップロード | `fastlane beta env:prod` | Fastlane使用 |
| Firebase配布 | - | `fastlane firebase env:dev` | Fastlane使用 |

## 🎯 推奨運用パターン

### パターン1: 開発フロー
1. 開発者ローカル: `make dev-release`（高速確認）
2. PR作成: 自動テスト実行
3. developマージ: `fastlane firebase env:dev`（テスター配布）
4. mainマージ: `fastlane beta env:prod`（TestFlight/Internal Testing）

### パターン2: リリースフロー
1. ステージング確認: `fastlane beta env:dev`
2. 本番準備: `fastlane beta env:prod`
3. App Store提出: `fastlane beta env:appstore`

## 📝 Makefile拡張案（オプション）

既存のMakefileに以下を追加することで統合を強化：

```makefile
# Fastlane統合コマンド
.PHONY: deploy-dev deploy-prod deploy-appstore

# 開発環境へデプロイ（iOS/Android両方）
deploy-dev:
	@echo "Deploying dev to TestFlight and Internal Testing..."
	cd ios && bundle exec fastlane beta env:dev
	cd android && bundle exec fastlane beta env:dev

# 本番環境へデプロイ
deploy-prod:
	@echo "Deploying prod to TestFlight and Internal Testing..."
	cd ios && bundle exec fastlane beta env:prod
	cd android && bundle exec fastlane beta env:prod

# Firebase App Distributionへデプロイ
firebase-dev:
	@echo "Deploying to Firebase App Distribution (dev)..."
	cd ios && bundle exec fastlane firebase env:dev
	cd android && bundle exec fastlane firebase env:dev
```

## ⚙️ GitHub Actions統合

```yaml
# .github/workflows/deploy.yml での使用例
- name: Deploy to TestFlight (iOS)
  run: |
    cd ios
    bundle exec fastlane beta env:${{ github.ref == 'refs/heads/main' && 'prod' || 'dev' }}

- name: Deploy to Internal Testing (Android)
  run: |
    cd android
    bundle exec fastlane beta env:${{ github.ref == 'refs/heads/main' && 'prod' || 'dev' }}
```

## 🔑 環境変数管理

### GitHub Secretsに追加が必要
```bash
# 環境別のFirebase App ID
FIREBASE_APP_ID_IOS_DEV
FIREBASE_APP_ID_IOS_PROD
FIREBASE_APP_ID_ANDROID_DEV
FIREBASE_APP_ID_ANDROID_PROD

# その他の認証情報（共通）
APPLE_ID
TEAM_ID
GOOGLE_PLAY_JSON_KEY_PATH
```

## 移行スケジュール提案

1. **Phase 1（即時）**: Makefileは現状維持、Fastlaneを並行導入
2. **Phase 2（1週間後）**: Firebase App Distributionでテスター配布開始
3. **Phase 3（2週間後）**: TestFlight/Internal Testing自動化
4. **Phase 4（1ヶ月後）**: 完全自動化、手動アップロード廃止

この統合により、既存の開発フローを維持しつつ、段階的にCI/CD自動化を実現できます。