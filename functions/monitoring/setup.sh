#!/bin/bash

# Firebase Monitoring セットアップスクリプト (v2)
# 使い方: ./setup.sh [dev|prod]

set -e

ENVIRONMENT=${1:-dev}

echo "========================================"
echo "Firebase Monitoring Setup (v2)"
echo "Environment: $ENVIRONMENT"
echo "========================================"
echo ""

# 環境に応じたプロジェクトIDを設定
if [ "$ENVIRONMENT" = "dev" ]; then
  PROJECT_ID="chat-sns-project"
elif [ "$ENVIRONMENT" = "prod" ]; then
  PROJECT_ID="blank-project-prod"
else
  echo "Error: Invalid environment. Use 'dev' or 'prod'"
  exit 1
fi

echo "Project ID: $PROJECT_ID"
echo ""

# Firebase プロジェクトを選択
echo "1️⃣  Setting Firebase project..."
firebase use $PROJECT_ID
echo "✅ Project set to $PROJECT_ID"
echo ""

# Slack Webhook URLの入力（チャンネル別）
echo "2️⃣  Configure Slack Webhook URLs"
echo ""
echo "推奨チャンネル構成:"
echo "  - #firebase-${ENVIRONMENT}-reports : 定時レポート（日次/週次）"
echo "  - #firebase-${ENVIRONMENT}-alerts  : アラート・エラー通知"
echo ""

read -p "Reports channel Webhook URL (Enter to skip): " REPORTS_WEBHOOK_URL
read -p "Alerts channel Webhook URL (Enter to skip): " ALERTS_WEBHOOK_URL

if [ -n "$REPORTS_WEBHOOK_URL" ] || [ -n "$ALERTS_WEBHOOK_URL" ]; then
  echo "Setting Firebase Functions config..."

  CONFIG_CMD="firebase functions:config:set app.environment=\"$ENVIRONMENT\""

  if [ -n "$REPORTS_WEBHOOK_URL" ]; then
    CONFIG_CMD="$CONFIG_CMD slack.${ENVIRONMENT}_reports_url=\"$REPORTS_WEBHOOK_URL\""
  fi

  if [ -n "$ALERTS_WEBHOOK_URL" ]; then
    CONFIG_CMD="$CONFIG_CMD slack.${ENVIRONMENT}_alerts_url=\"$ALERTS_WEBHOOK_URL\""
  fi

  eval $CONFIG_CMD
  echo "✅ Config set successfully"
else
  echo "⚠️  Skipped Slack webhook configuration"
  echo "You can set it later with:"
  echo "  firebase functions:config:set \\"
  echo "    slack.${ENVIRONMENT}_reports_url=\"YOUR_REPORTS_WEBHOOK\" \\"
  echo "    slack.${ENVIRONMENT}_alerts_url=\"YOUR_ALERTS_WEBHOOK\" \\"
  echo "    app.environment=\"$ENVIRONMENT\""
fi
echo ""

# Firestoreインデックスの確認
echo "3️⃣  Firestore setup..."
echo "The following collections will be used for monitoring:"
echo "  - monitoring/metrics/{firestore,functions,auth,storage}"
echo "  - monitoring/errors/logs"
echo "  - monitoring/transactions/failures"
echo "  - monitoring/operations/{deletes,user_deletions}"
echo "  - monitoring/anomalies/patterns"
echo "  - monitoring/storage/{uploads,failed_uploads,deletions}"
echo ""
echo "⚠️  Make sure to update Firestore security rules to allow writes from Cloud Functions"
echo ""

# Cloud Functionsのデプロイ確認
echo "4️⃣  Deploy Cloud Functions?"
read -p "Deploy monitoring functions now? (y/N): " DEPLOY_CONFIRM

if [ "$DEPLOY_CONFIRM" = "y" ] || [ "$DEPLOY_CONFIRM" = "Y" ]; then
  echo "Deploying monitoring functions..."
  cd ..
  firebase deploy --only functions:monitoring --project=$PROJECT_ID
  echo "✅ Functions deployed successfully"
else
  echo "⚠️  Skipped deployment"
  echo "You can deploy later with:"
  echo "  firebase deploy --only functions:monitoring"
fi
echo ""

# セットアップ完了
echo "========================================"
echo "✨ Setup Complete!"
echo "========================================"
echo ""
echo "📋 監視機能の概要:"
echo ""
echo "【定時レポート】"
echo "  - 日次レポート: 毎日 9:00 (JST)"
echo "  - 週次レポート: 毎週月曜 9:00 (JST)"
echo "  ※ #firebase-${ENVIRONMENT}-reports チャンネルに送信"
echo ""
echo "【監視対象】"
echo "  - Firestore: メトリクス収集（毎時）、異常検知（15分毎）"
echo "  - Functions: エラー監視（毎時）"
echo "  - Auth: ユーザー登録・退会監視（毎時）"
echo "  - Storage: ファイル操作監視（毎時）"
echo "  ※ アラートは #firebase-${ENVIRONMENT}-alerts チャンネルに送信"
echo ""
echo "Next steps:"
echo ""
echo "1. Slackチャンネルを作成（未作成の場合）"
echo "   - #firebase-${ENVIRONMENT}-reports"
echo "   - #firebase-${ENVIRONMENT}-alerts"
echo ""
echo "2. Test the monitoring functions:"
echo "   curl https://asia-northeast1-$PROJECT_ID.cloudfunctions.net/monitoring-healthCheck"
echo ""
echo "3. View function logs:"
echo "   firebase functions:log --only monitoring"
echo ""
echo "4. Monitor metrics in Firebase Console:"
echo "   https://console.firebase.google.com/project/$PROJECT_ID/functions/list"
echo ""
echo "詳細は functions/monitoring/README.md を参照してください"
echo ""
