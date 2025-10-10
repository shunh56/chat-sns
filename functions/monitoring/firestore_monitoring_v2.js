/**
 * Firestore監視（v2 - 新アーキテクチャ対応）
 *
 * Firestoreのトランザクション、エラー、メトリクスを監視
 * 通知は notification_router を経由して送信
 */

const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const {
  sendErrorAlert,
  sendMetricAlert,
  sendAnomalyAlert,
  sendCustomNotification
} = require('./notification_router');
const { FIRESTORE_CONFIG } = require('./monitoring_config');

// Helper function to get Firestore instance
const getDb = () => admin.firestore();

/**
 * Firestoreメトリクス収集
 * 毎時実行
 */
exports.collectFirestoreMetrics = functions
  .region('asia-northeast1')
  .pubsub.schedule(FIRESTORE_CONFIG.metricsSchedule)
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      console.log('Collecting Firestore metrics...');

      const now = new Date();
      const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);

      // 各コレクションのドキュメント数を取得
      const metrics = {};

      for (const collectionName of FIRESTORE_CONFIG.collections) {
        const snapshot = await getDb().collection(collectionName)
          .where('createdAt', '>=', oneHourAgo)
          .get();

        metrics[`${collectionName}_count_1h`] = snapshot.size;
      }

      // トランザクション失敗数を取得
      const transactionFailures = await getDb().collection('monitoring')
        .doc('transactions')
        .collection('failures')
        .where('timestamp', '>=', oneHourAgo)
        .get();

      metrics.transaction_failures_1h = transactionFailures.size;

      // エラー数を取得
      const errors = await getDb().collection('monitoring')
        .doc('errors')
        .collection('logs')
        .where('timestamp', '>=', oneHourAgo)
        .where('source', '==', 'firestore')
        .get();

      metrics.errors_1h = errors.size;

      // メトリクスを保存
      await getDb().collection('monitoring').doc('metrics').collection('firestore').add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        ...metrics
      });

      // 閾値チェック
      await checkMetricThresholds(metrics);

      console.log('Firestore metrics collected:', metrics);

    } catch (error) {
      console.error('Error collecting Firestore metrics:', error);

      await sendErrorAlert({
        service: 'firestore',
        errorType: 'METRICS_COLLECTION_ERROR',
        errorMessage: error.message,
        stackTrace: error.stack
      });
    }
  });

/**
 * 異常なパターンの検知
 * 15分ごとに実行
 */
exports.detectAnomalousPatterns = functions
  .region('asia-northeast1')
  .pubsub.schedule(FIRESTORE_CONFIG.anomalySchedule)
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      const now = new Date();
      const fifteenMinutesAgo = new Date(now.getTime() - 15 * 60 * 1000);

      // 各ユーザーの投稿数をカウント
      const postsSnapshot = await getDb().collection('posts')
        .where('createdAt', '>=', fifteenMinutesAgo)
        .get();

      const userPostCounts = {};
      postsSnapshot.forEach(doc => {
        const userId = doc.data().userId;
        userPostCounts[userId] = (userPostCounts[userId] || 0) + 1;
      });

      // 異常なアクティビティを検知
      const threshold = FIRESTORE_CONFIG.thresholds.excessivePosting15m;
      const anomalousUsers = Object.entries(userPostCounts)
        .filter(([userId, count]) => count > threshold);

      if (anomalousUsers.length > 0) {
        await sendAnomalyAlert({
          service: 'firestore',
          anomalyType: 'EXCESSIVE_POSTING',
          description: `Detected ${anomalousUsers.length} user(s) with excessive posting`,
          severity: 'MEDIUM',
          context: {
            'Users': anomalousUsers.map(([userId, count]) =>
              `${userId}: ${count} posts`
            ).join('\n'),
            'Threshold': `${threshold} posts/15min`,
            'Period': '15 minutes'
          }
        });

        // ログに記録
        for (const [userId, count] of anomalousUsers) {
          await getDb().collection('monitoring').doc('anomalies').collection('patterns').add({
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            type: 'EXCESSIVE_POSTING',
            userId,
            count,
            period: '15m'
          });
        }
      }

    } catch (error) {
      console.error('Error detecting anomalous patterns:', error);
    }
  });

/**
 * 重要なコレクションの変更を監視
 * 例: postsコレクション
 */
exports.monitorPostsChanges = functions
  .region('asia-northeast1')
  .firestore.document('posts/{postId}')
  .onWrite(async (change, context) => {
    try {
      const postId = context.params.postId;
      const before = change.before.exists ? change.before.data() : null;
      const after = change.after.exists ? change.after.data() : null;

      // 削除の場合
      if (before && !after) {
        await getDb().collection('monitoring').doc('operations').collection('deletes').add({
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          collection: 'posts',
          documentId: postId,
          data: before
        });
        return;
      }

      // 重要なフィールドの変更を監視
      if (before && after) {
        const criticalFields = FIRESTORE_CONFIG.criticalFields.posts;

        for (const field of criticalFields) {
          if (before[field] !== after[field]) {
            await sendCustomNotification({
              title: 'Critical Field Changed',
              message: `Field *${field}* changed in posts/${postId}`,
              alertLevel: 'MEDIUM',
              service: 'firestore',
              fields: {
                'Collection': 'posts',
                'Document ID': postId,
                'Field': field,
                'Old Value': String(before[field]),
                'New Value': String(after[field])
              },
              channelType: 'alerts'
            });
          }
        }
      }

    } catch (error) {
      console.error('Error monitoring posts changes:', error);
    }
  });

/**
 * ユーザーコレクションの変更を監視
 */
exports.monitorUsersChanges = functions
  .region('asia-northeast1')
  .firestore.document('users/{userId}')
  .onWrite(async (change, context) => {
    try {
      const userId = context.params.userId;
      const before = change.before.exists ? change.before.data() : null;
      const after = change.after.exists ? change.after.data() : null;

      // 重要なフィールドの変更を監視
      if (before && after) {
        const criticalFields = FIRESTORE_CONFIG.criticalFields.users;

        for (const field of criticalFields) {
          if (before[field] !== after[field]) {
            await sendCustomNotification({
              title: 'User Critical Field Changed',
              message: `Field *${field}* changed for user ${userId}`,
              alertLevel: 'HIGH',
              service: 'firestore',
              fields: {
                'Collection': 'users',
                'User ID': userId,
                'Field': field,
                'Old Value': String(before[field]),
                'New Value': String(after[field])
              },
              channelType: 'alerts'
            });
          }
        }
      }

    } catch (error) {
      console.error('Error monitoring users changes:', error);
    }
  });

/**
 * メトリクスの閾値チェック
 */
async function checkMetricThresholds(metrics) {
  const thresholds = FIRESTORE_CONFIG.thresholds;

  // トランザクション失敗数チェック
  if (metrics.transaction_failures_1h > thresholds.transactionFailures1h) {
    await sendMetricAlert({
      service: 'firestore',
      metric: 'transaction_failures_1h',
      currentValue: metrics.transaction_failures_1h,
      threshold: thresholds.transactionFailures1h,
      comparison: `${metrics.transaction_failures_1h} > ${thresholds.transactionFailures1h}`,
      context: {
        'Period': '1 hour'
      }
    });
  }

  // エラー数チェック
  if (metrics.errors_1h > thresholds.errors1h) {
    await sendMetricAlert({
      service: 'firestore',
      metric: 'errors_1h',
      currentValue: metrics.errors_1h,
      threshold: thresholds.errors1h,
      comparison: `${metrics.errors_1h} > ${thresholds.errors1h}`,
      context: {
        'Period': '1 hour'
      }
    });
  }
}

/**
 * トランザクション失敗をログに記録
 * アプリケーションコードから呼び出して使用
 */
async function logTransactionFailure({ operation, collection, documentId, error }) {
  try {
    const errorMessage = error.message || error.toString();

    // ログをFirestoreに保存
    await getDb().collection('monitoring').doc('transactions').collection('failures').add({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      operation,
      collection,
      documentId,
      error: errorMessage,
      errorCode: error.code || 'UNKNOWN'
    });

    // アラート送信
    await sendErrorAlert({
      service: 'firestore',
      errorType: 'TRANSACTION_FAILURE',
      errorMessage: `Transaction failed: ${operation} on ${collection}/${documentId}`,
      stackTrace: error.stack || '',
      context: {
        'Operation': operation,
        'Collection': collection,
        'Document ID': documentId || 'N/A'
      }
    });

  } catch (err) {
    console.error('Error logging transaction failure:', err);
  }
}

// Export helper functions separately (Cloud Functions are already exported above with exports.functionName)
exports.logTransactionFailure = logTransactionFailure;
exports.checkMetricThresholds = checkMetricThresholds;
