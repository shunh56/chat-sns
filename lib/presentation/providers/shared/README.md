# Shared Providers

アプリケーション全体で共有されるプロバイダを管理するディレクトリです。

## 📁 ディレクトリ構造

```
shared/
├── auth/                  # 認証関連
│   └── auth_notifier.dart
├── users/                 # ユーザー関連
│   ├── my_user_account_notifier.dart
│   └── all_users_notifier.dart
├── app/                   # アプリ全体設定
│   ├── session_provider.dart
│   ├── app_providers.dart
│   └── heart_animation_notifier.dart
└── notifications/         # 通知関連
    └── dm_notification_provider.dart
```

## 🎯 配置基準

### ✅ 共有プロバイダに配置すべきもの

- **認証状態**: ログイン/ログアウト状態
- **ユーザー情報**: 現在のユーザーアカウント
- **アプリ設定**: テーマ、言語、セッション管理
- **グローバル通知**: DM通知、プッシュ通知
- **横断的機能**: アニメーション、分析

### ❌ 共有プロバイダに配置すべきでないもの

- **画面固有のUI状態**: タブインデックス、フォーム状態
- **ページ専用データ**: 特定の画面でのみ使用するリスト
- **一時的な状態**: モーダルの開閉状態

## 🔄 移行ルール

### 新しいプロバイダを作成する際

1. **複数画面で使用されるか？** → shared/に配置
2. **画面固有の状態か？** → pages/[画面名]/providers/に配置

### 既存プロバイダを移動する際

1. 使用箇所を全て確認
2. インポートパスを一括更新
3. 静的解析でエラーがないことを確認

## 📋 使用例

```dart
// 認証状態の監視
final authState = ref.watch(authNotifierProvider);

// ユーザー情報の取得
final user = ref.watch(myAccountNotifierProvider);

// セッション管理
ref.read(sessionStateProvider.notifier).startSession();
```

## ⚠️ 注意事項

- プロバイダの移動時は必ずインポートパスを更新
- 循環依存を避ける
- テストコードのインポートパスも忘れずに更新