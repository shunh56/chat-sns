# Makefile 仕様・運用手順書

## 概要

このMakefileは、Flutter アプリケーションの開発・ビルド・デプロイを効率化するためのタスクランナーです。
iOS/Android の両プラットフォームに対応し、開発環境・本番環境・App Store環境の3つの環境を管理します。

## 前提条件

### 必要なツール
- Flutter SDK (最新版推奨)
- Firebase CLI
- Xcode (iOS開発用)
- Android Studio (Android開発用)
- make コマンド

### プロジェクト構成
```
app/
├── dart_defines/
│   ├── dev.env        # 開発環境設定
│   ├── prod.env       # 本番環境設定
│   └── appstore.env   # App Store環境設定
├── ios/
├── android/
└── Makefile
```

## 命名規則

### 基本パターン
- **実行コマンド**: `run-{環境}-{プラットフォーム}-{ビルドモード}`
- **ビルドコマンド**: `build-{プラットフォーム}-{環境}`
- **Firebaseコマンド**: `firebase-{アクション}-{環境}`

### 環境名
- `dev`: 開発環境
- `prod`: 本番環境
- `appstore`: App Store環境

### プラットフォーム名
- `ios`: iOS (省略可能、デフォルト)
- `android`: Android

### ビルドモード
- `debug`: デバッグモード
- `profile`: プロファイルモード
- `release`: リリースモード

## 使用方法

### 1. ヘルプの表示

```bash
# Flutter アプリコマンドのヘルプ
make help

# Firebase コマンドのヘルプ
make firebase-help
```

### 2. 初期セットアップ

```bash
# プロジェクトの初期セットアップ
make setup
```

このコマンドは以下を実行します：
- Flutter パッケージの取得
- build_runner の実行
- iOS設定ファイルの準備

### 3. プロジェクトのクリーンアップ

```bash
# プロジェクトのクリーン・再セットアップ
make clean
```

## Flutter アプリケーション開発

### iOS での実行

#### 開発環境
```bash
make run-dev-debug      # デバッグモード
make run-dev-profile    # プロファイルモード
make run-dev-release    # リリースモード
```

#### 本番環境
```bash
make run-prod-debug     # デバッグモード
make run-prod-profile   # プロファイルモード
make run-prod-release   # リリースモード
```

#### App Store環境
```bash
make run-appstore-debug   # デバッグモード
make run-appstore-profile # プロファイルモード
make run-appstore-release # リリースモード
```

### Android での実行

#### 開発環境
```bash
make run-android-dev-debug      # デバッグモード
make run-android-dev-profile    # プロファイルモード
make run-android-dev-release    # リリースモード
make run-android-dev-release-verbose  # リリースモード(詳細ログ)
```

#### 本番環境
```bash
make run-android-prod-debug     # デバッグモード
make run-android-prod-profile   # プロファイルモード
make run-android-prod-release   # リリースモード
```

### アプリケーションのビルド

#### iOS ビルド
```bash
make build-ios-dev        # 開発環境用 IPA
make build-ios-prod       # 本番環境用 IPA
make build-ios-appstore   # App Store用 IPA
```

#### Android ビルド
```bash
make build-android-dev    # 開発環境用 App Bundle
make build-android-prod   # 本番環境用 App Bundle
```

## Firebase Functions 管理

### 環境の切り替え

```bash
make firebase-use-dev     # 開発環境に切り替え
make firebase-use-prod    # 本番環境に切り替え
```

### 全Functions のデプロイ

```bash
make firebase-deploy-dev   # 開発環境にデプロイ
make firebase-deploy-prod  # 本番環境にデプロイ
```

### 特定の Function のデプロイ

```bash
make firebase-deploy-dev-function FUNCTION=funcName   # 開発環境
make firebase-deploy-prod-function FUNCTION=funcName  # 本番環境
```

### ローカル開発

```bash
make firebase-serve  # Firebase エミュレーターを起動
```

## 下位互換性

旧来のコマンド名も引き続き使用できます：

```bash
# 旧コマンド → 新コマンド
make dev              # → make run-dev-debug
make prod             # → make run-prod-debug
make deploy-dev       # → make firebase-deploy-dev
make deploy-prod      # → make firebase-deploy-prod
```

## 環境設定ファイル

### dart_defines/dev.env
開発環境用の設定ファイル
- API エンドポイント
- デバッグフラグ
- 開発用キー

### dart_defines/prod.env
本番環境用の設定ファイル
- 本番API エンドポイント
- 本番用キー
- パフォーマンス設定

### dart_defines/appstore.env
App Store 申請用の設定ファイル
- App Store 固有の設定
- リリース用最適化

## トラブルシューティング

### よくある問題

1. **iOS ビルドエラー**
   ```bash
   make clean  # クリーン後再試行
   ```

2. **Android flavor エラー**
   - android/app/build.gradle でflavor設定を確認

3. **Firebase 認証エラー**
   ```bash
   firebase login  # 再ログイン
   ```

4. **dart_defines ファイルが見つからない**
   - ファイルパスと存在を確認
   - 必要に応じてサンプルファイルを作成

### デバッグ用コマンド

```bash
# 詳細ログ付き実行
make run-android-dev-release-verbose

# Flutter プロジェクトの状態確認
flutter doctor

# Firebase プロジェクトの確認
firebase projects:list
```

## セキュリティ注意事項

1. **環境設定ファイル**
   - `dart_defines/*.env` ファイルには機密情報が含まれる可能性があります
   - `.gitignore` で適切に除外されていることを確認してください

2. **Firebase 認証情報**
   - Firebase CLI の認証情報は適切に管理してください
   - 本番環境への誤デプロイを防ぐため、環境を常に確認してください

## 保守・更新

### 新しい環境の追加

1. `dart_defines/` に新しい環境設定ファイルを追加
2. Makefile に新しい変数とターゲットを追加
3. ヘルプテキストを更新

### コマンドの追加

1. 命名規則に従ってターゲット名を決定
2. `.PHONY` 宣言を追加
3. ヘルプテキストを更新
4. 必要に応じて下位互換性のためのエイリアスを追加

## 変更履歴

- **v2.0.0**: 命名規則の統一、構造化、ヘルプ機能の追加
- **v1.0.0**: 初版リリース