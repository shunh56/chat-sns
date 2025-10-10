/**
 * Cloud Functions監視
 *
 * Cloud Functionsのエラー、パフォーマンス、実行状況を監視
 */

const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { sendErrorAlert, sendMetricAlert } = require('./notification_router');
const { FUNCTIONS_CONFIG } = require('./monitoring_config');

// Helper function to get Firestore instance
const getDb = () => admin.firestore();

/**
 * Cloud Functionsメトリクス収集
 * 毎時実行
 */
exports.collectFunctionsMetrics = functions
  .region('asia-northeast1')
  .pubsub.schedule(FUNCTIONS_CONFIG.metricsSchedule)
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      const now = new Date();
      const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);

      // Functions関連のエラーを収集
      const errorsSnapshot = await getDb().collection('monitoring')
        .doc('errors')
        .collection('logs')
        .where('timestamp', '>=', oneHourAgo)
        .where('source', '==', 'functions')
        .get();

      const errorCount = errorsSnapshot.size;

      // メトリクスを保存
      await getDb().collection('monitoring').doc('metrics').collection('functions').add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        errorCount,
        period: '1h'
      });

      // 閾値チェック
      if (errorCount > FUNCTIONS_CONFIG.thresholds.errorRate1h) {
        await sendMetricAlert({
          service: 'functions',
          metric: 'error_count_1h',
          currentValue: errorCount,
          threshold: FUNCTIONS_CONFIG.thresholds.errorRate1h,
          comparison: `${errorCount} > ${FUNCTIONS_CONFIG.thresholds.errorRate1h}`,
          context: {
            'Period': '1 hour',
            'Function': 'All functions'
          }
        });
      }

      console.log('Functions metrics collected:', { errorCount });

    } catch (error) {
      console.error('Error collecting Functions metrics:', error);

      await sendErrorAlert({
        service: 'functions',
        errorType: 'METRICS_COLLECTION_ERROR',
        errorMessage: error.message,
        stackTrace: error.stack
      });
    }
  });

/**
 * Function実行エラーをログに記録
 * 各Functionから呼び出して使用
 */
async function logFunctionError({ functionName, error, context = {} }) {
  try {
    await getDb().collection('monitoring').doc('errors').collection('logs').add({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      source: 'functions',
      functionName,
      type: error.name || 'UnknownError',
      message: error.message,
      stack: error.stack,
      context
    });

    // エラーアラートを送信
    await sendErrorAlert({
      service: 'functions',
      errorType: error.name || 'UnknownError',
      errorMessage: `Function ${functionName} error: ${error.message}`,
      stackTrace: error.stack,
      context: {
        'Function': functionName,
        ...context
      }
    });

  } catch (err) {
    console.error('Error logging function error:', err);
  }
}

// Export helper function separately (Cloud Functions are already exported above with exports.functionName)
exports.logFunctionError = logFunctionError;
