/**
 * Firebase Authentication監視
 *
 * ユーザー認証、新規登録、ログイン失敗などを監視
 */

const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { sendAnomalyAlert, sendMetricAlert } = require('./notification_router');
const { AUTH_CONFIG } = require('./monitoring_config');

// Helper function to get Firestore instance
const getDb = () => admin.firestore();

/**
 * Authメトリクス収集
 * 毎時実行
 */
exports.collectAuthMetrics = functions
  .region('asia-northeast1')
  .pubsub.schedule(AUTH_CONFIG.metricsSchedule)
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      const now = new Date();
      const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);

      // 新規ユーザー数
      const newUsersSnapshot = await getDb().collection('users')
        .where('createdAt', '>=', oneHourAgo)
        .get();

      const newUsersCount = newUsersSnapshot.size;

      // 退会ユーザー数（isDeletedフィールドを使用）
      const deletedUsersSnapshot = await getDb().collection('users')
        .where('deletedAt', '>=', oneHourAgo)
        .get();

      const deletedUsersCount = deletedUsersSnapshot.size;

      // メトリクスを保存
      await getDb().collection('monitoring').doc('metrics').collection('auth').add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        newUsers: newUsersCount,
        deletedUsers: deletedUsersCount,
        period: '1h'
      });

      // 異常検知: 新規登録が多すぎる
      if (newUsersCount > AUTH_CONFIG.thresholds.newUsers1h) {
        await sendAnomalyAlert({
          service: 'auth',
          anomalyType: 'EXCESSIVE_REGISTRATIONS',
          description: `Unusually high number of new user registrations: ${newUsersCount} in 1 hour`,
          severity: 'MEDIUM',
          context: {
            'New Users': newUsersCount.toString(),
            'Threshold': AUTH_CONFIG.thresholds.newUsers1h.toString(),
            'Period': '1 hour'
          }
        });
      }

      // 異常検知: 退会が多すぎる
      if (deletedUsersCount > AUTH_CONFIG.thresholds.accountDeletions1h) {
        await sendAnomalyAlert({
          service: 'auth',
          anomalyType: 'EXCESSIVE_DELETIONS',
          description: `Unusually high number of account deletions: ${deletedUsersCount} in 1 hour`,
          severity: 'HIGH',
          context: {
            'Deleted Users': deletedUsersCount.toString(),
            'Threshold': AUTH_CONFIG.thresholds.accountDeletions1h.toString(),
            'Period': '1 hour'
          }
        });
      }

      console.log('Auth metrics collected:', { newUsersCount, deletedUsersCount });

    } catch (error) {
      console.error('Error collecting Auth metrics:', error);
    }
  });

/**
 * 新規ユーザー作成を監視
 */
exports.monitorUserCreation = functions
  .region('asia-northeast1')
  .firestore.document('users/{userId}')
  .onCreate(async (snap, context) => {
    try {
      const userId = context.params.userId;
      const userData = snap.data();

      // ユーザー作成ログを記録（オプション）
      console.log(`New user created: ${userId}`);

      // 短時間に同じIPから大量登録などの検知ロジックをここに追加可能

    } catch (error) {
      console.error('Error monitoring user creation:', error);
    }
  });

/**
 * ユーザー削除を監視
 */
exports.monitorUserDeletion = functions
  .region('asia-northeast1')
  .firestore.document('users/{userId}')
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      const userId = context.params.userId;

      // isDeletedフィールドの変更を監視
      if (!before.isDeleted && after.isDeleted) {
        await getDb().collection('monitoring').doc('operations').collection('user_deletions').add({
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          userId,
          userData: {
            email: after.email,
            createdAt: after.createdAt
          }
        });

        console.log(`User deleted: ${userId}`);
      }

    } catch (error) {
      console.error('Error monitoring user deletion:', error);
    }
  });

// Cloud Functions are already exported above with exports.functionName
