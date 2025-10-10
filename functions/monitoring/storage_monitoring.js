/**
 * Firebase Storage監視
 *
 * ファイルアップロード、ダウンロード、ストレージ使用量を監視
 */

const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { sendMetricAlert, sendAnomalyAlert } = require('./notification_router');
const { STORAGE_CONFIG } = require('./monitoring_config');

// Helper function to get Firestore instance
const getDb = () => admin.firestore();

/**
 * Storageメトリクス収集
 * 毎時実行
 */
exports.collectStorageMetrics = functions
  .region('asia-northeast1')
  .pubsub.schedule(STORAGE_CONFIG.metricsSchedule)
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      const now = new Date();
      const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);

      // ストレージ操作のログから集計
      const uploadsSnapshot = await getDb().collection('monitoring')
        .doc('storage')
        .collection('uploads')
        .where('timestamp', '>=', oneHourAgo)
        .get();

      const uploadCount = uploadsSnapshot.size;

      // アップロード失敗数
      const failedUploadsSnapshot = await getDb().collection('monitoring')
        .doc('storage')
        .collection('failed_uploads')
        .where('timestamp', '>=', oneHourAgo)
        .get();

      const failedUploadCount = failedUploadsSnapshot.size;

      // 合計アップロードサイズ
      let totalUploadSize = 0;
      uploadsSnapshot.forEach(doc => {
        totalUploadSize += doc.data().size || 0;
      });

      // メトリクスを保存
      await getDb().collection('monitoring').doc('metrics').collection('storage').add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        uploadCount,
        failedUploadCount,
        totalUploadSize,
        period: '1h'
      });

      // 閾値チェック: アップロードサイズ
      if (totalUploadSize > STORAGE_CONFIG.thresholds.uploadSize1h) {
        await sendMetricAlert({
          service: 'storage',
          metric: 'upload_size_1h',
          currentValue: totalUploadSize,
          threshold: STORAGE_CONFIG.thresholds.uploadSize1h,
          comparison: `${formatBytes(totalUploadSize)} > ${formatBytes(STORAGE_CONFIG.thresholds.uploadSize1h)}`,
          context: {
            'Upload Count': uploadCount.toString(),
            'Period': '1 hour'
          }
        });
      }

      // 閾値チェック: アップロード失敗
      if (failedUploadCount > STORAGE_CONFIG.thresholds.uploadFailures1h) {
        await sendAnomalyAlert({
          service: 'storage',
          anomalyType: 'EXCESSIVE_UPLOAD_FAILURES',
          description: `High number of upload failures: ${failedUploadCount} in 1 hour`,
          severity: 'MEDIUM',
          context: {
            'Failed Uploads': failedUploadCount.toString(),
            'Threshold': STORAGE_CONFIG.thresholds.uploadFailures1h.toString(),
            'Period': '1 hour'
          }
        });
      }

      console.log('Storage metrics collected:', {
        uploadCount,
        failedUploadCount,
        totalUploadSize: formatBytes(totalUploadSize)
      });

    } catch (error) {
      console.error('Error collecting Storage metrics:', error);
    }
  });

/**
 * ファイルアップロードを監視
 * Storage Triggersを使用
 */
exports.monitorFileUpload = functions
  .region('asia-northeast1')
  .storage.object()
  .onFinalize(async (object) => {
    try {
      const filePath = object.name;
      const fileSize = parseInt(object.size) || 0;
      const contentType = object.contentType;

      // アップロードログを記録
      await getDb().collection('monitoring').doc('storage').collection('uploads').add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        filePath,
        size: fileSize,
        contentType,
        bucket: object.bucket
      });

      // 大きなファイルのアップロードを検知（例: 100MB以上）
      const largeFileThreshold = 100 * 1024 * 1024;  // 100MB
      if (fileSize > largeFileThreshold) {
        await sendAnomalyAlert({
          service: 'storage',
          anomalyType: 'LARGE_FILE_UPLOAD',
          description: `Large file uploaded: ${formatBytes(fileSize)}`,
          severity: 'LOW',
          context: {
            'File Path': filePath,
            'File Size': formatBytes(fileSize),
            'Content Type': contentType || 'unknown'
          }
        });
      }

    } catch (error) {
      console.error('Error monitoring file upload:', error);
    }
  });

/**
 * ファイル削除を監視
 */
exports.monitorFileDelete = functions
  .region('asia-northeast1')
  .storage.object()
  .onDelete(async (object) => {
    try {
      const filePath = object.name;

      // 削除ログを記録
      await getDb().collection('monitoring').doc('storage').collection('deletions').add({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        filePath,
        bucket: object.bucket
      });

      console.log(`File deleted: ${filePath}`);

    } catch (error) {
      console.error('Error monitoring file deletion:', error);
    }
  });

/**
 * アップロード失敗をログに記録
 * アプリケーションコードから呼び出し
 */
async function logUploadFailure({ filePath, error, userId, context = {} }) {
  try {
    await getDb().collection('monitoring').doc('storage').collection('failed_uploads').add({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      filePath,
      userId,
      error: error.message,
      context
    });

  } catch (err) {
    console.error('Error logging upload failure:', err);
  }
}

/**
 * バイト数をフォーマット
 */
function formatBytes(bytes) {
  if (bytes === 0) return '0 Bytes';

  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i];
}

// Export helper functions separately (Cloud Functions are already exported above with exports.functionName)
exports.logUploadFailure = logUploadFailure;
exports.formatBytes = formatBytes;
