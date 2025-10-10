/**
 * 監視システムの一元管理設定
 *
 * すべての監視設定をここで管理することで、拡張性と保守性を向上
 */

const functions = require('firebase-functions/v1');

/**
 * 環境設定
 */
const ENVIRONMENT = process.env.ENVIRONMENT || functions.config().app?.environment || 'dev';
const PROJECT_ID = process.env.FIREBASE_PROJECT_ID || process.env.GCLOUD_PROJECT;

/**
 * Slack通知先の設定
 *
 * チャンネル構成:
 * - dev-reports:  Dev環境の定時レポート
 * - dev-alerts:   Dev環境のアラート（エラー、異常検知）
 * - prod-reports: Prod環境の定時レポート
 * - prod-alerts:  Prod環境のアラート（エラー、異常検知）
 */
const SLACK_CHANNELS = {
  dev: {
    reports: process.env.SLACK_DEV_REPORTS_URL || functions.config().slack?.dev_reports_url,
    alerts: process.env.SLACK_DEV_ALERTS_URL || functions.config().slack?.dev_alerts_url
  },
  prod: {
    reports: process.env.SLACK_PROD_REPORTS_URL || functions.config().slack?.prod_reports_url,
    alerts: process.env.SLACK_PROD_ALERTS_URL || functions.config().slack?.prod_alerts_url
  }
};

/**
 * アラートの優先度レベル
 */
const ALERT_LEVELS = {
  INFO: {
    name: 'info',
    color: '#36a64f',
    icon: ':information_source:',
    channels: ['reports']  // レポートチャンネルのみ
  },
  LOW: {
    name: 'low',
    color: '#0099ff',
    icon: ':large_blue_circle:',
    channels: ['alerts']
  },
  MEDIUM: {
    name: 'medium',
    color: '#ff9900',
    icon: ':warning:',
    channels: ['alerts']
  },
  HIGH: {
    name: 'high',
    color: '#ff0000',
    icon: ':x:',
    channels: ['alerts'],
    mention: '@channel'  // 本番環境でメンション
  },
  CRITICAL: {
    name: 'critical',
    color: '#8b0000',
    icon: ':rotating_light:',
    channels: ['alerts'],
    mention: '@channel'  // 本番環境でメンション
  }
};

/**
 * Firestore監視の設定
 */
const FIRESTORE_CONFIG = {
  // メトリクス収集のスケジュール（毎時0分）
  metricsSchedule: '0 * * * *',

  // 異常検知のスケジュール（15分ごと）
  anomalySchedule: '*/15 * * * *',

  // 監視対象コレクション
  collections: ['users', 'posts', 'footprints_v2', 'chat_rooms', 'direct_messages'],

  // 閾値設定
  thresholds: {
    transactionFailures1h: 10,    // 1時間に10回以上の失敗
    errors1h: 50,                  // 1時間に50回以上のエラー
    excessivePosting15m: 20,       // 15分間に20投稿以上
    documentReads1h: 10000,        // 1時間に10,000回以上の読み取り
    documentWrites1h: 5000         // 1時間に5,000回以上の書き込み
  },

  // 重要フィールド（変更を監視）
  criticalFields: {
    users: ['isBlocked', 'role', 'isDeleted'],
    posts: ['isDeleted', 'isBlocked', 'status']
  }
};

/**
 * Cloud Functions監視の設定
 */
const FUNCTIONS_CONFIG = {
  // メトリクス収集のスケジュール
  metricsSchedule: '0 * * * *',

  // 閾値設定
  thresholds: {
    errorRate1h: 5,                // エラー率5%以上
    executionTime99p: 10000,       // 99パーセンタイルが10秒以上
    memoryUsage: 80,               // メモリ使用率80%以上
    timeoutCount1h: 3,             // 1時間に3回以上のタイムアウト
    coldStartRatio: 30             // コールドスタート率30%以上
  },

  // 監視対象の関数（重要な関数のみ指定）
  criticalFunctions: [
    'pushNotification',
    'voip',
    'monitoring-collectFirestoreMetrics',
    'monitoring-detectAnomalousPatterns'
  ]
};

/**
 * Authentication監視の設定
 */
const AUTH_CONFIG = {
  // メトリクス収集のスケジュール
  metricsSchedule: '0 * * * *',

  // 閾値設定
  thresholds: {
    failedLogins1h: 100,           // 1時間に100回以上のログイン失敗
    newUsers1h: 50,                // 1時間に50人以上の新規登録（異常検知）
    accountDeletions1h: 10,        // 1時間に10人以上の退会
    suspiciousActivity: 5          // 短時間に5回以上のログイン試行
  }
};

/**
 * Storage監視の設定
 */
const STORAGE_CONFIG = {
  // メトリクス収集のスケジュール
  metricsSchedule: '0 * * * *',

  // 閾値設定
  thresholds: {
    uploadSize1h: 1024 * 1024 * 1024,  // 1時間に1GB以上のアップロード
    downloads1h: 10000,                 // 1時間に10,000回以上のダウンロード
    uploadFailures1h: 50,               // 1時間に50回以上のアップロード失敗
    storageUsage: 80                    // ストレージ使用率80%以上（GB単位で設定）
  },

  // 監視対象バケット
  buckets: [
    'user_profiles',
    'post_images',
    'chat_attachments'
  ]
};

/**
 * 定時レポートの設定
 */
const REPORT_CONFIG = {
  // 3時間ごとのレポート: 0時、3時、6時、9時、12時、15時、18時、21時（JST）
  dailySchedule: '0 */3 * * *',

  // 週次レポート: 毎週月曜日午前9時（JST）
  weeklySchedule: '0 9 * * 1',

  // 月次レポート: 毎月1日午前9時（JST）
  monthlySchedule: '0 9 1 * *',

  // レポートに含める項目
  includeMetrics: {
    firestore: true,
    functions: true,
    auth: true,
    storage: true,
    costs: true  // コスト情報も含める
  },

  // 比較期間
  comparisonPeriods: {
    daily: 'previous_day',
    weekly: 'previous_week',
    monthly: 'previous_month'
  }
};

/**
 * データ保持期間の設定
 */
const DATA_RETENTION = {
  metrics: 90,        // メトリクスは90日間保持
  errors: 30,         // エラーログは30日間保持
  anomalies: 60,      // 異常パターンは60日間保持
  reports: 365        // レポートは1年間保持
};

/**
 * 通知先を取得
 */
function getNotificationChannel(alertLevel = 'INFO', channelType = null) {
  const env = ENVIRONMENT;
  const level = ALERT_LEVELS[alertLevel] || ALERT_LEVELS.INFO;

  // チャンネルタイプが指定されていない場合は、アラートレベルから決定
  const type = channelType || level.channels[0];

  return SLACK_CHANNELS[env]?.[type];
}

/**
 * アラートレベル情報を取得
 */
function getAlertLevelConfig(level) {
  return ALERT_LEVELS[level] || ALERT_LEVELS.INFO;
}

/**
 * 環境に応じたメンションを取得
 */
function getMention(alertLevel) {
  const level = ALERT_LEVELS[alertLevel];

  // Prod環境でCRITICAL/HIGHの場合のみメンション
  if (ENVIRONMENT === 'prod' && level?.mention) {
    return level.mention;
  }

  return null;
}

/**
 * すべての設定をエクスポート
 */
module.exports = {
  // 環境情報
  ENVIRONMENT,
  PROJECT_ID,

  // Slack設定
  SLACK_CHANNELS,
  ALERT_LEVELS,

  // サービス別設定
  FIRESTORE_CONFIG,
  FUNCTIONS_CONFIG,
  AUTH_CONFIG,
  STORAGE_CONFIG,
  REPORT_CONFIG,

  // データ保持期間
  DATA_RETENTION,

  // ヘルパー関数
  getNotificationChannel,
  getAlertLevelConfig,
  getMention
};
