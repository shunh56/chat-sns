# CI/CD改善提案

## 現在の状況（2025年9月26日）

### App IDs準備状況
- ✅ `com.blank.sns` (現在使用中)
- ✅ `com.blank.sns.dev` (未使用)
- ✅ `com.blank.sns.prod` (未使用)

### 現在のCI/CD構成
```
develop → com.blank.sns + Firebase App Distribution
main → com.blank.sns + TestFlight
```

## 推奨改善案：環境別App ID対応

### 理想的な構成
```
develop → com.blank.sns.dev + Firebase App Distribution
main → com.blank.sns.prod + TestFlight/App Store
```

### メリット
1. **完全な環境分離**：dev/prod間でデータ混在がない
2. **安全性向上**：本番環境への誤ったデプロイリスクを削減
3. **テスト環境の独立性**：開発版と本番版を同時インストール可能
4. **Firebase Analytics分離**：dev/prod環境でのデータ分析が独立

### 実装に必要な作業

#### 1. App ID設定の更新
- `ios/Runner.xcodeproj`のBundle Identifierを環境別に設定
- 各環境用のExportOptions.plistを作成

#### 2. Firebase設定の追加
- `com.blank.sns.dev`用のFirebaseプロジェクト設定
- `com.blank.sns.prod`用のFirebaseプロジェクト設定
- 環境別のFirebase App IDをSecretsに追加

#### 3. CI/CD設定更新
- Fastfileで環境別App ID処理
- GitHub Actionsワークフローの環境分岐追加

#### 4. 新しいSecretsの追加
```
FIREBASE_APP_ID_IOS_DEV_SPECIFIC (com.blank.sns.dev用)
FIREBASE_APP_ID_IOS_PROD_SPECIFIC (com.blank.sns.prod用)
FIREBASE_APP_ID_ANDROID_DEV_SPECIFIC
FIREBASE_APP_ID_ANDROID_PROD_SPECIFIC
```

## 実装タイミング
**優先度：中（基本CI/CD動作後に実装）**

1. ✅ 現在のCI/CDを完全動作させる
2. 🔄 環境別App IDへの移行（この改善案を実装）
3. 🔄 本格的な本番リリース準備

## 参考リンク
- Apple Developer Portal: App IDs管理
- Firebase Console: プロジェクト設定
- GitHub Actions: 環境変数とSecrets管理

---
*最終更新: 2025年9月26日*
*次回レビュー: 基本CI/CD動作確認後*