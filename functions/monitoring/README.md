# Firebase Monitoring & Alerting System v2

**拡張性・管理性重視の新アーキテクチャ**

Firebase dev/prod環境の包括的な監視とアラート機能を提供します。
Firestore、Cloud Functions、Authentication、Storageの全サービスを統合監視し、定時レポートとリアルタイムアラートを適切なSlackチャンネルに送信します。

## 🎯 設計方針

### 1. Slackチャンネル構成
**環境別 × 通知タイプ別の4チャンネル構成**で、通知が整理され管理しやすくなっています。

```
Dev環境:
  #firebase-dev-reports  → 定時レポート（日次/週次）
  #firebase-dev-alerts   → リアルタイムアラート・エラー

Prod環境:
  #firebase-prod-reports → 定時レポート（日次/週次）
  #firebase-prod-alerts  → リアルタイムアラート・エラー
```

### 2. 拡張性の高いモジュール構造
```
monitoring/
├── monitoring_config.js        # 一元管理された設定
├── notification_router.js      # 通知ルーティング
├── report_generator.js         # 定時レポート生成
├── firestore_monitoring_v2.js  # Firestore監視
├── functions_monitoring.js     # Cloud Functions監視
├── auth_monitoring.js          # Authentication監視
├── storage_monitoring.js       # Storage監視
└── metrics_dashboard.js        # メトリクスAPI
```

### 3. 優先度ベースのアラート
5段階のアラートレベルで重要度を管理:
- **CRITICAL**: 即座に対応が必要（本番のみ@channelメンション）
- **HIGH**: 早急に対応が必要（本番のみ@channelメンション）
- **MEDIUM**: 注意が必要
- **LOW**: 情報提供
- **INFO**: 定時レポート

## 📊 監視機能

### 1. Firestore監視
- **メトリクス収集**: 毎時
  - ドキュメント作成数（users, posts, footprints_v2, chat_rooms, direct_messages）
  - トランザクション失敗数
  - エラー数
- **異常検知**: 15分ごと
  - 短時間の大量投稿（15分間に20投稿以上）
- **リアルタイム監視**:
  - 重要フィールド変更（isDeleted, isBlocked, status, role）

### 2. Cloud Functions監視
- **メトリクス収集**: 毎時
  - 関数エラー数
- **リアルタイム監視**:
  - 関数実行エラーの検知

### 3. Authentication監視
- **メトリクス収集**: 毎時
  - 新規ユーザー数
  - 退会ユーザー数
- **異常検知**:
  - 大量の新規登録（1時間に50人以上）
  - 大量の退会（1時間に10人以上）
- **リアルタイム監視**:
  - ユーザー作成/削除イベント

### 4. Storage監視
- **メトリクス収集**: 毎時
  - アップロード数・合計サイズ
  - アップロード失敗数
- **リアルタイム監視**:
  - ファイルアップロード/削除
  - 大きなファイルのアップロード（100MB以上）

### 5. 定時レポート
- **日次レポート**: 毎日 9:00 (JST)
  - 前日比較付きの総合レポート
- **週次レポート**: 毎週月曜 9:00 (JST)
  - 先週比較付きの総合レポート

## 🚀 セットアップ

### 1. Slackチャンネルの作成

以下のチャンネルを作成してください:

**Dev環境:**
```
#firebase-dev-reports
#firebase-dev-alerts
```

**Prod環境:**
```
#firebase-prod-reports
#firebase-prod-alerts
```

### 2. Slack Incoming Webhooksの設定

1. [Slack API](https://api.slack.com/messaging/webhooks) にアクセス
2. 各チャンネル用のIncoming Webhookを作成（計4つ）
3. Webhook URLをメモ

### 3. 自動セットアップ（推奨）

```bash
cd functions/monitoring

# Dev環境
./setup.sh dev

# Prod環境
./setup.sh prod
```

スクリプトが以下を自動で実行します:
- Firebaseプロジェクトの選択
- Slack Webhook URLの設定
- Firebase Functions Configの設定
- Cloud Functionsのデプロイ（オプション）

### 4. 手動セットアップ

```bash
# 1. Firebase Functions Configを設定
firebase use chat-sns-project  # Dev環境の場合

firebase functions:config:set \
  slack.dev_reports_url="https://hooks.slack.com/..." \
  slack.dev_alerts_url="https://hooks.slack.com/..." \
  app.environment="dev"

# 2. デプロイ
firebase deploy --only functions:monitoring
```

## ⚙️ 設定のカスタマイズ

### 閾値の調整

`monitoring_config.js` で閾値を調整できます:

```javascript
// Firestore
thresholds: {
  transactionFailures1h: 10,    // トランザクション失敗
  errors1h: 50,                  // エラー数
  excessivePosting15m: 20,       // 短時間の投稿数
}

// Functions
thresholds: {
  errorRate1h: 5,                // エラー率
  executionTime99p: 10000,       // 実行時間
}

// Auth
thresholds: {
  failedLogins1h: 100,           // ログイン失敗
  newUsers1h: 50,                // 新規登録
  accountDeletions1h: 10,        // 退会数
}

// Storage
thresholds: {
  uploadSize1h: 1073741824,      // 1GB
  uploadFailures1h: 50,          // アップロード失敗
}
```

### 監視対象コレクションの変更

```javascript
// monitoring_config.js
collections: [
  'users',
  'posts',
  'footprints_v2',
  'chat_rooms',
  'direct_messages',
  // 追加のコレクション
]
```

### レポートスケジュールの変更

```javascript
// monitoring_config.js
REPORT_CONFIG: {
  dailySchedule: '0 9 * * *',    // 毎日9時
  weeklySchedule: '0 9 * * 1',   // 毎週月曜9時
  monthlySchedule: '0 9 1 * *',  // 毎月1日9時
}
```

## 💡 使用例

### 既存コードへの統合

#### トランザクション失敗のログ記録

```javascript
const { logTransactionFailure } = require('./monitoring/firestore_monitoring_v2');

try {
  await db.runTransaction(async (transaction) => {
    // トランザクション処理
  });
} catch (error) {
  // エラーをログに記録してSlackに通知
  await logTransactionFailure({
    operation: 'updateUserProfile',
    collection: 'users',
    documentId: userId,
    error: error
  });
  throw error;
}
```

#### Function実行エラーのログ記録

```javascript
const { logFunctionError } = require('./monitoring/functions_monitoring');

exports.myFunction = functions.https.onRequest(async (req, res) => {
  try {
    // 処理
  } catch (error) {
    await logFunctionError({
      functionName: 'myFunction',
      error,
      context: { userId, action: 'someAction' }
    });
    throw error;
  }
});
```

#### カスタムアラート送信

```javascript
const { sendCustomNotification } = require('./monitoring/notification_router');

// 重要なイベントを通知
await sendCustomNotification({
  title: 'Important Event',
  message: 'User performed a critical action',
  alertLevel: 'HIGH',
  service: 'firestore',
  fields: {
    'User ID': userId,
    'Action': 'account_deletion',
    'Reason': reason
  },
  channelType: 'alerts'
});
```

#### ストレージアップロード失敗のログ記録

```javascript
const { logUploadFailure } = require('./monitoring/storage_monitoring');

try {
  await uploadFile(file);
} catch (error) {
  await logUploadFailure({
    filePath: file.path,
    error,
    userId,
    context: { fileSize: file.size }
  });
  throw error;
}
```

## 📡 メトリクスダッシュボードAPI

HTTPエンドポイントでメトリクスを取得できます。

### エンドポイント

```bash
# ダッシュボードデータ取得
GET https://asia-northeast1-{PROJECT_ID}.cloudfunctions.net/monitoring-getMetricsDashboard?period=24h

# パラメータ:
# - period: 1h, 6h, 24h, 7d, 30d

# アラート履歴取得
GET https://asia-northeast1-{PROJECT_ID}.cloudfunctions.net/monitoring-getAlerts?limit=50

# ヘルスチェック
GET https://asia-northeast1-{PROJECT_ID}.cloudfunctions.net/monitoring-healthCheck
```

### 使用例

```bash
# Dev環境の24時間分のメトリクス
curl https://asia-northeast1-chat-sns-project.cloudfunctions.net/monitoring-getMetricsDashboard?period=24h

# 最新のアラート50件
curl https://asia-northeast1-chat-sns-project.cloudfunctions.net/monitoring-getAlerts?limit=50

# ヘルスチェック
curl https://asia-northeast1-chat-sns-project.cloudfunctions.net/monitoring-healthCheck
```

## 🗂️ Firestoreデータ構造

監視機能が使用するコレクション:

```
monitoring/
  ├── metrics/
  │   ├── firestore/      # Firestoreメトリクス
  │   ├── functions/      # Functionsメトリクス
  │   ├── auth/          # Authメトリクス
  │   └── storage/       # Storageメトリクス
  ├── errors/
  │   └── logs/          # エラーログ
  ├── transactions/
  │   └── failures/      # トランザクション失敗
  ├── operations/
  │   ├── deletes/       # 削除操作
  │   └── user_deletions/# ユーザー削除
  ├── anomalies/
  │   └── patterns/      # 異常パターン
  └── storage/
      ├── uploads/       # アップロードログ
      ├── failed_uploads/# アップロード失敗
      └── deletions/     # ファイル削除
```

## 🔒 Firestoreセキュリティルール

`firestore.rules`に以下を追加してください:

```javascript
// 監視コレクション
match /monitoring/{document=**} {
  // Cloud Functionsからの書き込みのみ許可
  allow write: if false;

  // 管理者のみ読み取り可能
  allow read: if request.auth != null &&
                 get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

## 📈 コスト概算

月額コストの目安（エラー発生頻度により変動）:

- **Cloud Functions呼び出し**: 無料枠内
  - メトリクス収集: 24回/日 × 4サービス = 96回/日
  - 異常検知: 96回/日（15分ごと）
  - レポート: 8回/日（日次+週次）

- **Firestore書き込み**: 約5,000回/月 → $0.25
- **Cloud Scheduler**: $0.10/ジョブ/月 × 10ジョブ → $1.00
- **Slack API**: 無料

**合計**: 月額 $1-3 程度

## 🔧 トラブルシューティング

### Slack通知が送信されない

```bash
# 設定を確認
firebase functions:config:get

# ログを確認
firebase functions:log --only monitoring

# テスト通知を送信
node monitoring/test_examples.js
```

### メトリクスが収集されない

```bash
# Cloud Schedulerのジョブを確認
gcloud scheduler jobs list --project=chat-sns-project

# Firestoreの権限を確認
# Cloud FunctionsのサービスアカウントにFirestore書き込み権限があるか確認
```

### ローカルでテスト

```bash
cd functions
npm run serve  # Firebase Emulator起動

# 別のターミナルで
firebase functions:shell
> monitoring.healthCheck({}, {})
```

## 📚 アーキテクチャ

### コンポーネント図

```
┌─────────────────────────────────────────────┐
│         Firebase Services                   │
│  ┌─────────┬──────────┬──────┬──────────┐  │
│  │Firestore│ Functions│ Auth │ Storage  │  │
│  └────┬────┴────┬─────┴──┬───┴────┬─────┘  │
└───────┼─────────┼────────┼────────┼─────────┘
        │         │        │        │
        ▼         ▼        ▼        ▼
┌─────────────────────────────────────────────┐
│      Monitoring Modules                     │
│  ┌──────────┬──────────┬─────┬───────────┐ │
│  │Firestore │Functions │Auth │Storage    │ │
│  │Monitoring│Monitoring│Mon. │Monitoring │ │
│  └─────┬────┴─────┬────┴──┬──┴─────┬─────┘ │
└────────┼──────────┼───────┼────────┼────────┘
         │          │       │        │
         └──────────┴───────┴────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │ Notification Router  │
         │  (Alert Level判定)   │
         └──────────┬───────────┘
                    │
         ┌──────────┴───────────┐
         │                      │
         ▼                      ▼
    ┌─────────┐          ┌─────────┐
    │ Reports │          │ Alerts  │
    │ Channel │          │ Channel │
    └─────────┘          └─────────┘
```

### データフロー

```
1. イベント発生 → 2. 監視モジュール → 3. 通知ルーター → 4. Slack
                     ↓
                5. Firestore保存
```

## 🔄 今後の拡張

新しいサービスを追加する場合:

1. `monitoring/{service}_monitoring.js` を作成
2. `monitoring_config.js` に設定を追加
3. `index.js` でエクスポート
4. `report_generator.js` にメトリクス収集を追加

例: Cloud Storageのバケット使用量監視を追加する場合

```javascript
// 1. storage_monitoring.jsを更新
exports.collectBucketUsage = functions...

// 2. monitoring_config.jsに設定追加
STORAGE_CONFIG: {
  thresholds: {
    bucketUsage: 100 * 1024 * 1024 * 1024 // 100GB
  }
}

// 3. index.jsでエクスポート
exports.monitoring = {
  ...
  collectBucketUsage: storageMonitoring.collectBucketUsage
}
```

## 📞 サポート

問題が発生した場合:
1. `functions/monitoring/README_V2.md` を確認
2. Firebase Functions のログを確認: `firebase functions:log --only monitoring`
3. Slack通知の設定を確認: `firebase functions:config:get`

---

**バージョン**: 2.0
**最終更新**: 2025-10-10
