# Fastlane セットアップガイド

## 🚀 初期設定

### 1. Fastlaneインストール

```bash
# iOS
cd ios
bundle install

# Android
cd android
bundle install
```

### 2. 必要な環境変数（GitHub Secrets）

#### iOS用
- `APPLE_ID`: Apple Developer アカウントのメールアドレス
- `TEAM_ID`: Developer Portal Team ID
- `ITC_TEAM_ID`: App Store Connect Team ID
- `MATCH_GIT_URL`: 証明書保存用のプライベートGitリポジトリURL
- `MATCH_PASSWORD`: Match暗号化パスワード
- `FIREBASE_APP_ID_IOS`: Firebase iOS App ID

#### Android用
- `GOOGLE_PLAY_JSON_KEY_PATH`: Google Play Service Account JSONキーのパス
- `ANDROID_KEYSTORE_BASE64`: Keystoreファイル（Base64エンコード）
- `ANDROID_KEY_ALIAS`: Keystore alias
- `ANDROID_KEY_PASSWORD`: Keystore パスワード
- `ANDROID_STORE_PASSWORD`: Keystore ストアパスワード
- `FIREBASE_APP_ID_ANDROID`: Firebase Android App ID

## 📱 iOS証明書設定（Match）

### 初回セットアップ

1. **プライベートGitリポジトリ作成**
   - 例: `https://github.com/yourusername/certificates`

2. **Matchfile作成**
```bash
cd ios
fastlane match init
```

3. **証明書生成**
```bash
# 開発用
fastlane match development

# AdHoc（Firebase配布用）
fastlane match adhoc

# App Store用
fastlane match appstore
```

## 🤖 Android署名設定

### Keystoreファイル生成

```bash
cd android/app
keytool -genkey -v -keystore key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias key
```

### key.properties作成

```bash
cat > android/key.properties << EOF
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=key
storeFile=key.jks
EOF
```

### build.gradle設定確認

`android/app/build.gradle`に以下があることを確認:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## 🔑 Google Play Console設定

1. **Service Account作成**
   - Google Cloud Console → IAMとサービスアカウント
   - 新しいサービスアカウント作成
   - JSONキーをダウンロード

2. **Google Play Console権限付与**
   - 設定 → API アクセス
   - サービスアカウントをリンク
   - 適切な権限を付与

## 🧪 ローカルテスト

### iOS TestFlightテスト
```bash
cd ios
fastlane beta
```

### Android Internal Testingテスト
```bash
cd android
fastlane beta
```

### Firebase App Distribution（両プラットフォーム）
```bash
# iOS
cd ios
fastlane firebase

# Android
cd android
fastlane firebase
```

## ⚠️ トラブルシューティング

### iOS: "No code signing identity found"
```bash
fastlane match nuke development
fastlane match nuke distribution
fastlane match development --force
fastlane match appstore --force
```

### Android: "Failed to read key from keystore"
- key.propertiesのパスを確認
- keystoreファイルの存在確認
- パスワードの確認

### Firebase: "App ID not found"
- Firebase ConsoleでApp IDを確認
- 環境変数が正しく設定されているか確認

## 🔄 CI/CD統合

GitHub Actionsとの統合は次のステップで設定します。
このドキュメントは必要に応じて更新してください。