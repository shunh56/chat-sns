/**
 * 定時レポート生成
 *
 * 日次/週次/月次のレポートを生成してSlackに送信
 */

const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { sendReport } = require('./notification_router');
const { REPORT_CONFIG } = require('./monitoring_config');

// Helper function to get Firestore instance
const getDb = () => admin.firestore();

/**
 * 3時間ごとのレポート生成
 * 0時、3時、6時、9時、12時、15時、18時、21時（JST）に実行
 */
exports.generateDailyReport = functions
  .region('asia-northeast1')
  .pubsub.schedule(REPORT_CONFIG.dailySchedule)
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      console.log('Generating 3-hour report...');

      const now = new Date();
      const threeHoursAgo = new Date(now.getTime() - 3 * 60 * 60 * 1000);

      // 各サービスのメトリクスを収集（過去3時間）
      const metrics = await collectMetricsForPeriod(threeHoursAgo, now);

      // 前回の3時間と比較
      const sixHoursAgo = new Date(now.getTime() - 6 * 60 * 60 * 1000);
      const previousMetrics = await collectMetricsForPeriod(sixHoursAgo, threeHoursAgo);
      const comparison = calculateComparison(metrics, previousMetrics);

      // サマリーを生成
      const summary = generate3HourSummary(metrics, comparison);

      // レポートフィールドを構築
      const reportFields = buildReportFields(metrics, comparison);

      // Slackに送信
      await sendReport({
        title: 'System Report (3-hour)',
        summary,
        metrics: reportFields,
        service: 'system',
        period: '3-hour'
      });

      console.log('3-hour report sent successfully');

    } catch (error) {
      console.error('Error generating daily report:', error);
      throw error;
    }
  });

/**
 * 週次レポート生成
 * 毎週月曜日午前9時（JST）に実行
 */
exports.generateWeeklyReport = functions
  .region('asia-northeast1')
  .pubsub.schedule(REPORT_CONFIG.weeklySchedule)
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      console.log('Generating weekly report...');

      const now = new Date();
      const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

      // 今週のメトリクスを収集
      const metrics = await collectMetricsForPeriod(oneWeekAgo, now);

      // 先週のメトリクスを収集
      const twoWeeksAgo = new Date(oneWeekAgo.getTime() - 7 * 24 * 60 * 60 * 1000);
      const previousMetrics = await collectMetricsForPeriod(twoWeeksAgo, oneWeekAgo);
      const comparison = calculateComparison(metrics, previousMetrics);

      // サマリーを生成
      const summary = generateWeeklySummary(metrics, comparison);

      // レポートフィールドを構築
      const reportFields = buildReportFields(metrics, comparison);

      // Slackに送信
      await sendReport({
        title: 'Weekly System Report',
        summary,
        metrics: reportFields,
        service: 'system',
        period: 'weekly'
      });

      console.log('Weekly report sent successfully');

    } catch (error) {
      console.error('Error generating weekly report:', error);
      throw error;
    }
  });

/**
 * 指定期間のメトリクスを収集
 */
async function collectMetricsForPeriod(startTime, endTime) {
  const metrics = {
    firestore: {},
    functions: {},
    auth: {},
    storage: {},
    costs: {}
  };

  try {
    // Firestoreメトリクス
    if (REPORT_CONFIG.includeMetrics.firestore) {
      metrics.firestore = await collectFirestoreMetrics(startTime, endTime);
    }

    // Functionsメトリクス（エラー数などを取得）
    if (REPORT_CONFIG.includeMetrics.functions) {
      metrics.functions = await collectFunctionsMetrics(startTime, endTime);
    }

    // Authメトリクス（新規ユーザー数などを取得）
    if (REPORT_CONFIG.includeMetrics.auth) {
      metrics.auth = await collectAuthMetrics(startTime, endTime);
    }

    // Storageメトリクス（アップロード数などを取得）
    if (REPORT_CONFIG.includeMetrics.storage) {
      metrics.storage = await collectStorageMetrics(startTime, endTime);
    }

  } catch (error) {
    console.error('Error collecting metrics:', error);
  }

  return metrics;
}

/**
 * Firestoreメトリクスを収集
 */
async function collectFirestoreMetrics(startTime, endTime) {
  try {
    // 各コレクションのドキュメント数
    const collections = ['users', 'posts', 'footprints_v2', 'chat_rooms', 'direct_messages'];
    const counts = {};

    for (const collectionName of collections) {
      const snapshot = await getDb().collection(collectionName)
        .where('createdAt', '>=', startTime)
        .where('createdAt', '<', endTime)
        .get();
      counts[collectionName] = snapshot.size;
    }

    // エラー数
    const errorsSnapshot = await getDb().collection('monitoring')
      .doc('errors')
      .collection('logs')
      .where('timestamp', '>=', startTime)
      .where('timestamp', '<', endTime)
      .get();

    // トランザクション失敗数
    const failuresSnapshot = await getDb().collection('monitoring')
      .doc('transactions')
      .collection('failures')
      .where('timestamp', '>=', startTime)
      .where('timestamp', '<', endTime)
      .get();

    return {
      documentCounts: counts,
      totalDocuments: Object.values(counts).reduce((a, b) => a + b, 0),
      errorCount: errorsSnapshot.size,
      transactionFailures: failuresSnapshot.size
    };

  } catch (error) {
    console.error('Error collecting Firestore metrics:', error);
    return {};
  }
}

/**
 * Cloud Functionsメトリクスを収集
 */
async function collectFunctionsMetrics(startTime, endTime) {
  try {
    // エラーログから関数のエラーを集計
    const errorsSnapshot = await getDb().collection('monitoring')
      .doc('errors')
      .collection('logs')
      .where('timestamp', '>=', startTime)
      .where('timestamp', '<', endTime)
      .where('source', '==', 'functions')
      .get();

    return {
      errorCount: errorsSnapshot.size
    };

  } catch (error) {
    console.error('Error collecting Functions metrics:', error);
    return {};
  }
}

/**
 * Authメトリクスを収集
 */
async function collectAuthMetrics(startTime, endTime) {
  try {
    // 新規ユーザー数
    const newUsersSnapshot = await getDb().collection('users')
      .where('createdAt', '>=', startTime)
      .where('createdAt', '<', endTime)
      .get();

    return {
      newUsers: newUsersSnapshot.size
    };

  } catch (error) {
    console.error('Error collecting Auth metrics:', error);
    return {};
  }
}

/**
 * Storageメトリクスを収集
 */
async function collectStorageMetrics(startTime, endTime) {
  try {
    // ストレージ関連のログがあれば集計
    // 実装はプロジェクトの要件に応じて調整

    return {
      uploads: 0,  // TODO: 実装
      downloads: 0  // TODO: 実装
    };

  } catch (error) {
    console.error('Error collecting Storage metrics:', error);
    return {};
  }
}

/**
 * メトリクスの比較を計算
 */
function calculateComparison(current, previous) {
  const comparison = {};

  // Firestore比較
  if (current.firestore && previous.firestore) {
    comparison.firestore = {
      totalDocuments: calculateChange(
        current.firestore.totalDocuments,
        previous.firestore.totalDocuments
      ),
      errorCount: calculateChange(
        current.firestore.errorCount,
        previous.firestore.errorCount
      ),
      transactionFailures: calculateChange(
        current.firestore.transactionFailures,
        previous.firestore.transactionFailures
      )
    };
  }

  // Auth比較
  if (current.auth && previous.auth) {
    comparison.auth = {
      newUsers: calculateChange(
        current.auth.newUsers,
        previous.auth.newUsers
      )
    };
  }

  return comparison;
}

/**
 * 変化率を計算
 */
function calculateChange(current, previous) {
  if (previous === 0) {
    return current > 0 ? '+100%' : '0%';
  }

  const change = ((current - previous) / previous) * 100;
  const sign = change >= 0 ? '+' : '';

  return {
    value: current,
    previousValue: previous,
    change: `${sign}${change.toFixed(1)}%`,
    changeValue: current - previous
  };
}

/**
 * 3時間ごとのサマリーを生成
 */
function generate3HourSummary(metrics, comparison) {
  const now = new Date();
  const timeRange = `${now.getHours() - 3}:00 - ${now.getHours()}:00`;
  const lines = [`*過去3時間のシステム概要* (${timeRange})\n`];

  // Firestore
  if (metrics.firestore) {
    const change = comparison.firestore?.totalDocuments?.change || '0%';
    lines.push(`📊 *Firestore*: ${metrics.firestore.totalDocuments}件の新規ドキュメント (前回比 ${change})`);

    if (metrics.firestore.errorCount > 0) {
      lines.push(`⚠️ エラー: ${metrics.firestore.errorCount}件`);
    }
  }

  // Auth
  if (metrics.auth && metrics.auth.newUsers > 0) {
    const change = comparison.auth?.newUsers?.change || '0%';
    lines.push(`👥 *新規ユーザー*: ${metrics.auth.newUsers}人 (前回比 ${change})`);
  }

  return lines.join('\n');
}

/**
 * 日次サマリーを生成
 */
function generateDailySummary(metrics, comparison) {
  const lines = ['*昨日のシステム概要*\n'];

  // Firestore
  if (metrics.firestore) {
    const change = comparison.firestore?.totalDocuments?.change || '0%';
    lines.push(`📊 *Firestore*: ${metrics.firestore.totalDocuments}件の新規ドキュメント (${change})`);

    if (metrics.firestore.errorCount > 0) {
      lines.push(`⚠️ エラー: ${metrics.firestore.errorCount}件`);
    }
  }

  // Auth
  if (metrics.auth && metrics.auth.newUsers > 0) {
    const change = comparison.auth?.newUsers?.change || '0%';
    lines.push(`👥 *新規ユーザー*: ${metrics.auth.newUsers}人 (${change})`);
  }

  return lines.join('\n');
}

/**
 * 週次サマリーを生成
 */
function generateWeeklySummary(metrics, comparison) {
  const lines = ['*先週のシステム概要*\n'];

  // Firestore
  if (metrics.firestore) {
    const change = comparison.firestore?.totalDocuments?.change || '0%';
    lines.push(`📊 *Firestore*: ${metrics.firestore.totalDocuments}件の新規ドキュメント (先週比 ${change})`);

    if (metrics.firestore.errorCount > 0) {
      lines.push(`⚠️ エラー: ${metrics.firestore.errorCount}件`);
    }
  }

  // Auth
  if (metrics.auth && metrics.auth.newUsers > 0) {
    const change = comparison.auth?.newUsers?.change || '0%';
    lines.push(`👥 *新規ユーザー*: ${metrics.auth.newUsers}人 (先週比 ${change})`);
  }

  return lines.join('\n');
}

/**
 * レポートフィールドを構築
 */
function buildReportFields(metrics, comparison) {
  const fields = {};

  // Firestore詳細
  if (metrics.firestore) {
    const fs = metrics.firestore;

    fields['Firestore - Total Docs'] = `${fs.totalDocuments || 0}`;

    if (fs.documentCounts) {
      Object.entries(fs.documentCounts).forEach(([collection, count]) => {
        if (count > 0) {
          fields[`  └ ${collection}`] = count.toString();
        }
      });
    }

    fields['Firestore - Errors'] = `${fs.errorCount || 0}`;
    fields['Firestore - TX Failures'] = `${fs.transactionFailures || 0}`;
  }

  // Auth詳細
  if (metrics.auth) {
    fields['Auth - New Users'] = `${metrics.auth.newUsers || 0}`;
  }

  // Functions詳細
  if (metrics.functions) {
    fields['Functions - Errors'] = `${metrics.functions.errorCount || 0}`;
  }

  return fields;
}

// Export helper functions separately (Cloud Functions are already exported above with exports.functionName)
exports.collectMetricsForPeriod = collectMetricsForPeriod;
exports.collectFirestoreMetrics = collectFirestoreMetrics;
exports.collectFunctionsMetrics = collectFunctionsMetrics;
exports.collectAuthMetrics = collectAuthMetrics;
exports.collectStorageMetrics = collectStorageMetrics;
exports.calculateComparison = calculateComparison;
exports.generate3HourSummary = generate3HourSummary;
exports.generateDailySummary = generateDailySummary;
exports.generateWeeklySummary = generateWeeklySummary;
