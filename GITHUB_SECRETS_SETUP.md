# GitHub Secrets 設定ガイド 🔐

GitHub リポジトリの Settings → Secrets and variables → Actions から以下を設定

## 必要なSecrets一覧

### 🍎 iOS関連
- [ ] `IOS_CERTIFICATE_BASE64` - 開発証明書(.p12)をBase64エンコード
- [ ] `IOS_CERTIFICATE_PASSWORD` - 証明書のパスワード
- [ ] `APP_STORE_CONNECT_API_KEY_ID` - App Store Connect API キーID
- [ ] `APP_STORE_CONNECT_API_ISSUER_ID` - API発行者ID
- [ ] `APP_STORE_CONNECT_API_KEY_CONTENT` - APIキーの内容(.p8ファイル)

### 🤖 Android関連
- [ ] `ANDROID_KEYSTORE_BASE64` - keystore(.jks)をBase64エンコード
- [ ] `ANDROID_KEY_ALIAS` - キーエイリアス
- [ ] `ANDROID_KEY_PASSWORD` - キーパスワード
- [ ] `ANDROID_STORE_PASSWORD` - ストアパスワード
- [ ] `GOOGLE_PLAY_JSON_KEY_BASE64` - Service Account JSONをBase64エンコード

### 🔥 Firebase関連
- [ ] `FIREBASE_TOKEN` - Firebase CLIトークン
- [ ] `FIREBASE_APP_ID_IOS_DEV` - iOS開発環境App ID
- [ ] `FIREBASE_APP_ID_IOS_PROD` - iOS本番環境App ID
- [ ] `FIREBASE_APP_ID_ANDROID_DEV` - Android開発環境App ID
- [ ] `FIREBASE_APP_ID_ANDROID_PROD` - Android本番環境App ID

### 📢 通知関連
- [ ] `SLACK_WEBHOOK_URL` - Slack通知用Webhook URL

## 設定手順

### 1. iOS証明書のBase64エンコード
```bash
# .p12ファイルをBase64エンコード
base64 -i Certificates.p12 | pbcopy
# クリップボードにコピーされるので、GitHub Secretsに貼り付け
```

### 2. Android Keystoreのエンコード
```bash
# keystoreファイルをBase64エンコード
base64 -i app/key.jks | pbcopy
```

### 3. Google Play Service Account
1. Google Cloud Console → IAMとサービスアカウント
2. 新規作成 → JSONキーダウンロード
3. Base64エンコード:
```bash
base64 -i play-store-key.json | pbcopy
```

### 4. Firebase設定
```bash
# セットアップスクリプト実行
./scripts/setup_firebase.sh

# 表示されるトークンとApp IDをコピー
```

### 5. App Store Connect API
1. App Store Connect → ユーザーとアクセス → キー
2. 新規キー作成（Admin権限）
3. .p8ファイルダウンロード
4. キーIDとIssuer IDをメモ
5. .p8ファイルの内容をそのままSecretに設定

### 6. Slack Webhook
1. https://api.slack.com/apps
2. Create New App → Incoming Webhooks
3. Activate → Add New Webhook
4. チャンネル選択 → URLをコピー

## 検証方法

### ローカルで環境変数テスト
```bash
# 環境変数設定
export FIREBASE_APP_ID_IOS_DEV="your-app-id"
export FIREBASE_TOKEN="your-token"

# Fastlane実行
cd ios
fastlane firebase env:dev
```

### GitHub Actions手動実行
1. Actions タブ → Deploy to TestFlight & Firebase
2. Run workflow → developブランチ選択
3. ログ確認

## セキュリティ注意事項

⚠️ **重要**
- Secretsは一度設定すると内容を確認できません
- .p12、.jks、.jsonファイルは絶対にコミットしない
- .gitignoreに以下を追加:
```
*.p12
*.jks
*.p8
**/key.properties
**/play-store-key.json
```

## トラブルシューティング

### "Invalid certificate" エラー
- 証明書の期限確認
- パスワードの確認
- Base64エンコードが正しいか確認

### "App ID not found" エラー
- Firebase ConsoleでApp ID確認
- 環境（dev/prod）の指定確認

### "Authentication failed" エラー
- APIキーの権限確認
- Service Accountの権限確認