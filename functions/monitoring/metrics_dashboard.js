/**
 * メトリクスダッシュボードAPI
 *
 * HTTPエンドポイントを提供してメトリクスを取得
 */

const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

// Helper function to get Firestore instance
const getDb = () => admin.firestore();

/**
 * メトリクスダッシュボードのデータを取得
 *
 * GET /metrics/dashboard?period=24h
 */
exports.getMetricsDashboard = functions
  .region('asia-northeast1')
  .https.onRequest(async (req, res) => {
    // CORS設定
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'GET') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    try {
      const period = req.query.period || '24h';
      const now = new Date();
      let startTime;

      // 期間の計算
      switch (period) {
        case '1h':
          startTime = new Date(now.getTime() - 60 * 60 * 1000);
          break;
        case '6h':
          startTime = new Date(now.getTime() - 6 * 60 * 60 * 1000);
          break;
        case '24h':
          startTime = new Date(now.getTime() - 24 * 60 * 60 * 1000);
          break;
        case '7d':
          startTime = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
          break;
        case '30d':
          startTime = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
          break;
        default:
          startTime = new Date(now.getTime() - 24 * 60 * 60 * 1000);
      }

      // メトリクスを取得
      const metricsSnapshot = await getDb().collection('monitoring')
        .doc('metrics')
        .collection('hourly')
        .where('timestamp', '>=', startTime)
        .orderBy('timestamp', 'desc')
        .get();

      const metrics = [];
      metricsSnapshot.forEach(doc => {
        metrics.push({
          id: doc.id,
          ...doc.data(),
          timestamp: doc.data().timestamp?.toDate()
        });
      });

      // エラー数を取得
      const errorsSnapshot = await getDb().collection('monitoring')
        .doc('errors')
        .collection('logs')
        .where('timestamp', '>=', startTime)
        .get();

      const errorsByType = {};
      errorsSnapshot.forEach(doc => {
        const data = doc.data();
        const type = data.type || 'UNKNOWN';
        errorsByType[type] = (errorsByType[type] || 0) + 1;
      });

      // トランザクション失敗数を取得
      const transactionFailuresSnapshot = await getDb().collection('monitoring')
        .doc('transactions')
        .collection('failures')
        .where('timestamp', '>=', startTime)
        .get();

      const failuresByCollection = {};
      transactionFailuresSnapshot.forEach(doc => {
        const data = doc.data();
        const collection = data.collection || 'UNKNOWN';
        failuresByCollection[collection] = (failuresByCollection[collection] || 0) + 1;
      });

      // 異常パターン数を取得
      const anomaliesSnapshot = await getDb().collection('monitoring')
        .doc('anomalies')
        .collection('patterns')
        .where('timestamp', '>=', startTime)
        .get();

      const dashboard = {
        period,
        generatedAt: now.toISOString(),
        metrics: {
          hourly: metrics,
          summary: calculateSummary(metrics)
        },
        errors: {
          total: errorsSnapshot.size,
          byType: errorsByType
        },
        transactionFailures: {
          total: transactionFailuresSnapshot.size,
          byCollection: failuresByCollection
        },
        anomalies: {
          total: anomaliesSnapshot.size
        }
      };

      res.status(200).json(dashboard);

    } catch (error) {
      console.error('Error getting metrics dashboard:', error);
      res.status(500).json({
        error: 'Internal Server Error',
        message: error.message
      });
    }
  });

/**
 * リアルタイムアラート履歴を取得
 *
 * GET /metrics/alerts?limit=50
 */
exports.getAlerts = functions
  .region('asia-northeast1')
  .https.onRequest(async (req, res) => {
    // CORS設定
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'GET') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    try {
      const limit = parseInt(req.query.limit) || 50;

      // 各種アラートを取得
      const [errors, transactionFailures, anomalies] = await Promise.all([
        db.collection('monitoring').doc('errors').collection('logs')
          .orderBy('timestamp', 'desc')
          .limit(limit)
          .get(),
        db.collection('monitoring').doc('transactions').collection('failures')
          .orderBy('timestamp', 'desc')
          .limit(limit)
          .get(),
        db.collection('monitoring').doc('anomalies').collection('patterns')
          .orderBy('timestamp', 'desc')
          .limit(limit)
          .get()
      ]);

      const alerts = [];

      // エラーアラート
      errors.forEach(doc => {
        const data = doc.data();
        alerts.push({
          id: doc.id,
          type: 'ERROR',
          severity: 'high',
          timestamp: data.timestamp?.toDate(),
          message: data.message,
          details: data
        });
      });

      // トランザクション失敗アラート
      transactionFailures.forEach(doc => {
        const data = doc.data();
        alerts.push({
          id: doc.id,
          type: 'TRANSACTION_FAILURE',
          severity: 'medium',
          timestamp: data.timestamp?.toDate(),
          message: `Transaction failed: ${data.operation} on ${data.collection}`,
          details: data
        });
      });

      // 異常パターンアラート
      anomalies.forEach(doc => {
        const data = doc.data();
        alerts.push({
          id: doc.id,
          type: 'ANOMALY',
          severity: 'medium',
          timestamp: data.timestamp?.toDate(),
          message: `Anomalous pattern detected: ${data.type}`,
          details: data
        });
      });

      // タイムスタンプでソート
      alerts.sort((a, b) => b.timestamp - a.timestamp);

      res.status(200).json({
        alerts: alerts.slice(0, limit),
        total: alerts.length
      });

    } catch (error) {
      console.error('Error getting alerts:', error);
      res.status(500).json({
        error: 'Internal Server Error',
        message: error.message
      });
    }
  });

/**
 * ヘルスチェックエンドポイント
 *
 * GET /metrics/health
 */
exports.healthCheck = functions
  .region('asia-northeast1')
  .https.onRequest(async (req, res) => {
    try {
      const now = new Date();
      const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);

      // 直近のエラー数を確認
      const recentErrors = await getDb().collection('monitoring')
        .doc('errors')
        .collection('logs')
        .where('timestamp', '>=', fiveMinutesAgo)
        .get();

      // 直近のトランザクション失敗を確認
      const recentFailures = await getDb().collection('monitoring')
        .doc('transactions')
        .collection('failures')
        .where('timestamp', '>=', fiveMinutesAgo)
        .get();

      const health = {
        status: 'healthy',
        timestamp: now.toISOString(),
        checks: {
          errors: {
            count: recentErrors.size,
            status: recentErrors.size < 10 ? 'ok' : 'warning'
          },
          transactionFailures: {
            count: recentFailures.size,
            status: recentFailures.size < 5 ? 'ok' : 'warning'
          }
        }
      };

      // 全体のヘルスステータスを判定
      if (recentErrors.size >= 50 || recentFailures.size >= 20) {
        health.status = 'critical';
      } else if (recentErrors.size >= 10 || recentFailures.size >= 5) {
        health.status = 'degraded';
      }

      const statusCode = health.status === 'healthy' ? 200 : 503;
      res.status(statusCode).json(health);

    } catch (error) {
      console.error('Error in health check:', error);
      res.status(500).json({
        status: 'error',
        message: error.message
      });
    }
  });

/**
 * メトリクスの集計を計算
 */
function calculateSummary(metrics) {
  if (metrics.length === 0) {
    return {
      avgTransactionFailures: 0,
      avgErrors: 0,
      totalDocuments: 0
    };
  }

  let totalFailures = 0;
  let totalErrors = 0;
  let totalDocuments = 0;

  metrics.forEach(metric => {
    totalFailures += metric.transaction_failures_1h || 0;
    totalErrors += metric.errors_1h || 0;
    totalDocuments += (metric.users_count_1h || 0) +
                     (metric.posts_count_1h || 0) +
                     (metric.footprints_v2_count_1h || 0);
  });

  return {
    avgTransactionFailures: Math.round(totalFailures / metrics.length),
    avgErrors: Math.round(totalErrors / metrics.length),
    totalDocuments,
    dataPoints: metrics.length
  };
}
