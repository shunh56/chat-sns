# Slack チャンネル命名規則・管理ガイド

## 📋 チャンネル命名規則

### 基本ルール

```
#firebase-{environment}-{type}
```

- **environment**: `dev` | `prod`
- **type**: `reports` | `alerts`

### チャンネル一覧

| チャンネル名 | 用途 | 通知頻度 | 重要度 |
|------------|------|---------|--------|
| `#firebase-dev-reports` | Dev環境の定時レポート | 日次・週次 | 📊 情報 |
| `#firebase-dev-alerts` | Dev環境のアラート・エラー | リアルタイム | ⚠️ 注意 |
| `#firebase-prod-reports` | Prod環境の定時レポート | 日次・週次 | 📊 情報 |
| `#firebase-prod-alerts` | Prod環境のアラート・エラー | リアルタイム | 🚨 重要 |

## 🎯 チャンネル別の通知内容

### Reports チャンネル (`#firebase-{env}-reports`)

**定時レポート専用**

- **日次レポート** (毎日 9:00 JST)
  - 前日のシステム概要
  - 新規ドキュメント数（Firestore）
  - 新規ユーザー数（Auth）
  - エラー数・トランザクション失敗数
  - 前日比較

- **週次レポート** (毎週月曜 9:00 JST)
  - 先週のシステム概要
  - 週間トレンド分析
  - 先週比較

**通知レベル**: INFO のみ

### Alerts チャンネル (`#firebase-{env}-alerts`)

**リアルタイムアラート・エラー専用**

#### Firestore
- トランザクション失敗（閾値: 10回/時間）
- エラー発生（閾値: 50回/時間）
- 異常な投稿パターン（閾値: 20投稿/15分）
- 重要フィールドの変更（isDeleted, isBlocked, status, role）

#### Cloud Functions
- 関数実行エラー（閾値: 5回/時間）
- タイムアウト
- メモリ不足

#### Authentication
- 大量の新規登録（閾値: 50人/時間）
- 大量の退会（閾値: 10人/時間）
- 不審なログイン試行

#### Storage
- 大容量アップロード（100MB以上）
- アップロード失敗多発（閾値: 50回/時間）

**通知レベル**: LOW / MEDIUM / HIGH / CRITICAL

**メンション**:
- Prod環境で HIGH / CRITICAL の場合のみ `@channel` メンション付き

## 🔔 通知設定

### Slack通知設定の推奨

#### Reports チャンネル
```
通知: すべてのメッセージ
サウンド: オフ
モバイル: オフ
```
理由: 定時レポートなので、読み逃しても問題ない

#### Dev Alerts チャンネル
```
通知: すべてのメッセージ
サウンド: オン（営業時間内のみ）
モバイル: オフ
```
理由: Dev環境なので、開発時間中のみ気づけば良い

#### Prod Alerts チャンネル
```
通知: すべてのメッセージ + @channel
サウンド: オン（24時間）
モバイル: オン
```
理由: 本番環境の異常は即座に対応が必要

## 👥 チャンネルメンバー管理

### Reports チャンネル
**推奨メンバー**:
- エンジニア全員
- プロダクトマネージャー
- データアナリスト

**用途**: 日々のメトリクスを確認し、トレンドを把握

### Alerts チャンネル
**推奨メンバー**:
- バックエンドエンジニア
- インフラ担当者
- オンコールエンジニア

**用途**: リアルタイムで問題に対応

## 📊 チャンネル作成手順

### 1. Slackワークスペースでチャンネル作成

```
1. Slack画面左側の「チャンネル」横の「+」をクリック
2. 「チャンネルを作成する」を選択
3. 以下の情報を入力:
   - チャンネル名: firebase-dev-reports
   - 説明: Firebase Dev環境の定時レポート（日次・週次）
   - プライベート: いいえ（パブリックチャンネル）
4. 「作成」をクリック
```

同様に以下のチャンネルも作成:
- `#firebase-dev-alerts` - Firebase Dev環境のアラート・エラー通知
- `#firebase-prod-reports` - Firebase Prod環境の定時レポート（日次・週次）
- `#firebase-prod-alerts` - Firebase Prod環境のアラート・エラー通知

### 2. Incoming Webhook の設定

各チャンネルに対してIncoming Webhookを設定:

```
1. https://api.slack.com/apps にアクセス
2. アプリを選択（または新規作成）
3. 「Incoming Webhooks」をクリック
4. 「Activate Incoming Webhooks」をオンにする
5. 「Add New Webhook to Workspace」をクリック
6. 投稿先チャンネルを選択（例: #firebase-dev-reports）
7. Webhook URLをコピー
```

計4つのWebhook URLを取得してメモ:
- Dev Reports Webhook URL
- Dev Alerts Webhook URL
- Prod Reports Webhook URL
- Prod Alerts Webhook URL

### 3. Firebase Functions Configに設定

```bash
# Dev環境
firebase use chat-sns-project
firebase functions:config:set \
  slack.dev_reports_url="https://hooks.slack.com/services/XXX/YYY/ZZZ" \
  slack.dev_alerts_url="https://hooks.slack.com/services/AAA/BBB/CCC" \
  app.environment="dev"

# Prod環境
firebase use blank-project-prod
firebase functions:config:set \
  slack.prod_reports_url="https://hooks.slack.com/services/DDD/EEE/FFF" \
  slack.prod_alerts_url="https://hooks.slack.com/services/GGG/HHH/III" \
  app.environment="prod"
```

または `monitoring/setup.sh` を使用:
```bash
cd functions/monitoring
./setup.sh dev
./setup.sh prod
```

## 🔄 将来の拡張

新しい通知タイプを追加する場合:

### 例: パフォーマンスアラート専用チャンネル

```
#firebase-{env}-performance
```

1. `monitoring_config.js` に新しいチャンネルタイプを追加:
```javascript
SLACK_CHANNELS: {
  dev: {
    reports: '...',
    alerts: '...',
    performance: process.env.SLACK_DEV_PERFORMANCE_URL
  },
  prod: {
    reports: '...',
    alerts: '...',
    performance: process.env.SLACK_PROD_PERFORMANCE_URL
  }
}
```

2. `notification_router.js` でルーティング追加
3. Firebase Functions Configに設定追加

## 📌 チャンネルピン留めメッセージ

各チャンネルに以下のメッセージをピン留めすることを推奨:

### Reports チャンネル

```
📊 Firebase {ENV}環境 定時レポート

【レポート配信時間】
• 日次: 毎日 9:00 (JST)
• 週次: 毎週月曜 9:00 (JST)

【レポート内容】
• Firestore: ドキュメント作成数、エラー数
• Auth: 新規ユーザー数、退会数
• Functions: エラー数
• Storage: アップロード数、容量

📚 詳細: functions/monitoring/README_V2.md
```

### Alerts チャンネル

```
🚨 Firebase {ENV}環境 アラート通知

【アラートレベル】
🔴 CRITICAL: 即座に対応が必要
🟠 HIGH: 早急に対応が必要
🟡 MEDIUM: 注意が必要
🔵 LOW: 情報提供

【Prod環境のみ】
HIGH/CRITICALアラートは @channel メンション付き

📚 詳細: functions/monitoring/README_V2.md
🔧 トラブルシューティング: firebase functions:log --only monitoring
```

## ✅ チェックリスト

セットアップ完了後、以下を確認:

- [ ] 4つのSlackチャンネルが作成されている
- [ ] 各チャンネルに適切なメンバーが追加されている
- [ ] 4つのIncoming Webhookが設定されている
- [ ] Firebase Functions ConfigにWebhook URLが設定されている
- [ ] 各チャンネルにピン留めメッセージが投稿されている
- [ ] Reports チャンネルの通知設定が適切に設定されている
- [ ] Alerts チャンネルの通知設定が適切に設定されている
- [ ] テスト通知が正常に送信されることを確認

テスト通知の送信:
```bash
curl https://asia-northeast1-{PROJECT_ID}.cloudfunctions.net/monitoring-healthCheck
```

---

**最終更新**: 2025-10-10
**バージョン**: 1.0
