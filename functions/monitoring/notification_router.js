/**
 * 通知ルーティング管理
 *
 * アラートレベルと通知タイプに応じて適切なSlackチャンネルに通知を送信
 */

const {
  ENVIRONMENT,
  getNotificationChannel,
  getAlertLevelConfig,
  getMention
} = require('./monitoring_config');

/**
 * 統合通知送信
 *
 * @param {Object} params
 * @param {string} params.title - 通知タイトル
 * @param {string} params.message - 通知メッセージ
 * @param {string} params.alertLevel - アラートレベル (INFO/LOW/MEDIUM/HIGH/CRITICAL)
 * @param {string} params.service - サービス名 (firestore/functions/auth/storage)
 * @param {Object} params.fields - 追加フィールド
 * @param {string} params.channelType - 通知タイプ (reports/alerts) ※オプション
 */
async function sendNotification({
  title,
  message,
  alertLevel = 'INFO',
  service = 'system',
  fields = {},
  channelType = null
}) {
  try {
    // アラートレベルの設定を取得
    const levelConfig = getAlertLevelConfig(alertLevel);

    // 通知先チャンネルを取得
    const webhookUrl = getNotificationChannel(alertLevel, channelType);

    if (!webhookUrl) {
      console.warn(`No webhook URL configured for ${ENVIRONMENT} environment, ${channelType || levelConfig.channels[0]} channel`);
      return;
    }

    // メンションを取得（本番環境のCRITICAL/HIGHのみ）
    const mention = getMention(alertLevel);

    // メッセージ本文にメンションを追加
    const finalMessage = mention ? `${mention}\n${message}` : message;

    // Slack Blockフォーマット
    const blocks = buildSlackBlocks({
      title,
      message: finalMessage,
      levelConfig,
      service,
      fields
    });

    const payload = {
      blocks,
      attachments: [
        {
          color: levelConfig.color,
          footer: `Firebase Monitoring | ${service}`,
          ts: Math.floor(Date.now() / 1000)
        }
      ]
    };

    // Slackに送信
    const response = await fetch(webhookUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new Error(`Slack API error: ${response.statusText}`);
    }

    console.log(`Notification sent successfully: ${title} [${alertLevel}]`);

  } catch (error) {
    console.error('Failed to send notification:', error);
    // 通知失敗はシステムを止めないようにエラーを投げない
  }
}

/**
 * Slack Blocks構築
 */
function buildSlackBlocks({ title, message, levelConfig, service, fields }) {
  const blocks = [
    {
      type: 'header',
      text: {
        type: 'plain_text',
        text: `${levelConfig.icon} ${title}`,
        emoji: true
      }
    },
    {
      type: 'section',
      fields: [
        {
          type: 'mrkdwn',
          text: `*Environment:*\n${ENVIRONMENT.toUpperCase()}`
        },
        {
          type: 'mrkdwn',
          text: `*Service:*\n${service.toUpperCase()}`
        },
        {
          type: 'mrkdwn',
          text: `*Level:*\n${levelConfig.name.toUpperCase()}`
        },
        {
          type: 'mrkdwn',
          text: `*Time:*\n<!date^${Math.floor(Date.now() / 1000)}^{date_short_pretty} {time}|${new Date().toISOString()}>`
        }
      ]
    },
    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: message
      }
    }
  ];

  // 追加フィールドがあれば追加
  if (Object.keys(fields).length > 0) {
    const fieldBlocks = Object.entries(fields)
      .filter(([_, value]) => value != null)  // null/undefinedを除外
      .map(([key, value]) => ({
        type: 'mrkdwn',
        text: `*${key}:*\n${formatFieldValue(value)}`
      }));

    if (fieldBlocks.length > 0) {
      // Slackの制限: 1セクションあたり最大10フィールド
      for (let i = 0; i < fieldBlocks.length; i += 10) {
        blocks.push({
          type: 'section',
          fields: fieldBlocks.slice(i, i + 10)
        });
      }
    }
  }

  blocks.push({
    type: 'divider'
  });

  return blocks;
}

/**
 * フィールド値のフォーマット
 */
function formatFieldValue(value) {
  if (typeof value === 'object') {
    return `\`\`\`${JSON.stringify(value, null, 2)}\`\`\``;
  }
  return String(value);
}

/**
 * エラーアラート通知
 */
async function sendErrorAlert({ service, errorType, errorMessage, stackTrace, context = {} }) {
  return sendNotification({
    title: `${service} Error`,
    message: errorMessage,
    alertLevel: 'HIGH',
    service,
    fields: {
      'Error Type': errorType,
      'Stack Trace': stackTrace ? `\`\`\`${stackTrace.substring(0, 500)}...\`\`\`` : 'N/A',
      ...context
    },
    channelType: 'alerts'
  });
}

/**
 * メトリクスアラート通知
 */
async function sendMetricAlert({ service, metric, currentValue, threshold, comparison, context = {} }) {
  // 閾値超過の程度に応じてアラートレベルを決定
  const ratio = currentValue / threshold;
  let alertLevel = 'MEDIUM';

  if (ratio >= 2) {
    alertLevel = 'CRITICAL';
  } else if (ratio >= 1.5) {
    alertLevel = 'HIGH';
  }

  return sendNotification({
    title: `${service} Metric Alert`,
    message: `Metric *${metric}* has exceeded threshold`,
    alertLevel,
    service,
    fields: {
      'Current Value': currentValue.toString(),
      'Threshold': threshold.toString(),
      'Comparison': comparison,
      'Ratio': `${Math.round(ratio * 100)}%`,
      ...context
    },
    channelType: 'alerts'
  });
}

/**
 * 異常検知アラート通知
 */
async function sendAnomalyAlert({ service, anomalyType, description, severity = 'MEDIUM', context = {} }) {
  return sendNotification({
    title: `${service} Anomaly Detected`,
    message: description,
    alertLevel: severity,
    service,
    fields: {
      'Anomaly Type': anomalyType,
      ...context
    },
    channelType: 'alerts'
  });
}

/**
 * 定時レポート通知
 */
async function sendReport({ title, summary, metrics, service = 'system', period = 'daily' }) {
  return sendNotification({
    title: `${period.charAt(0).toUpperCase() + period.slice(1)} Report: ${title}`,
    message: summary,
    alertLevel: 'INFO',
    service,
    fields: metrics,
    channelType: 'reports'
  });
}

/**
 * カスタム通知
 */
async function sendCustomNotification({ title, message, alertLevel, service, fields, channelType }) {
  return sendNotification({
    title,
    message,
    alertLevel,
    service,
    fields,
    channelType
  });
}

/**
 * 複数チャンネルへの同時通知
 */
async function broadcastNotification({ title, message, alertLevel, service, fields }) {
  const levelConfig = getAlertLevelConfig(alertLevel);

  // アラートレベルに応じた全チャンネルに送信
  const promises = levelConfig.channels.map(channelType =>
    sendNotification({
      title,
      message,
      alertLevel,
      service,
      fields,
      channelType
    })
  );

  await Promise.all(promises);
}

module.exports = {
  sendNotification,
  sendErrorAlert,
  sendMetricAlert,
  sendAnomalyAlert,
  sendReport,
  sendCustomNotification,
  broadcastNotification
};
