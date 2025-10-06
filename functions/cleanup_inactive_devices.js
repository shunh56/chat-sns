const functions = require("firebase-functions");
const admin = require("firebase-admin");

/**
 * 非アクティブなデバイスを定期的にクリーンアップする
 *
 * スケジュール: 毎日午前2時 (JST)
 * 対象: 30日以上非アクティブなデバイス
 *
 * 処理内容:
 * 1. 全ユーザーの devices サブコレクションをチェック
 * 2. lastActiveAt が30日以上前のデバイスを削除
 * 3. ユーザードキュメントの activeDevices キャッシュを更新
 */
exports.cleanupInactiveDevices = functions
  .region("asia-northeast1")
  .pubsub.schedule("0 2 * * *") // 毎日午前2時 (UTC) = 午前11時 (JST)
  .timeZone("Asia/Tokyo")
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(now.toDate().getTime() - 30 * 24 * 60 * 60 * 1000)
    );

    console.log(`Starting device cleanup at ${now.toDate()}`);
    console.log(`Deleting devices inactive since ${thirtyDaysAgo.toDate()}`);

    let totalProcessedUsers = 0;
    let totalDeletedDevices = 0;
    let totalErrors = 0;

    try {
      // 全ユーザーを取得 (バッチ処理)
      const usersSnapshot = await admin.firestore().collection("users").get();

      console.log(`Processing ${usersSnapshot.size} users`);

      // ユーザーごとに処理
      for (const userDoc of usersSnapshot.docs) {
        try {
          const userId = userDoc.id;
          const deletedCount = await cleanupUserDevices(
            userId,
            thirtyDaysAgo
          );

          if (deletedCount > 0) {
            totalDeletedDevices += deletedCount;
            console.log(
              `User ${userId}: Deleted ${deletedCount} inactive devices`
            );
          }

          totalProcessedUsers++;
        } catch (userError) {
          console.error(
            `Error processing user ${userDoc.id}:`,
            userError
          );
          totalErrors++;
        }
      }

      console.log(`
Cleanup completed:
- Processed users: ${totalProcessedUsers}
- Deleted devices: ${totalDeletedDevices}
- Errors: ${totalErrors}
      `);

      return {
        success: true,
        processedUsers: totalProcessedUsers,
        deletedDevices: totalDeletedDevices,
        errors: totalErrors,
      };
    } catch (error) {
      console.error("Fatal error during device cleanup:", error);
      throw error;
    }
  });

/**
 * 特定ユーザーの非アクティブデバイスをクリーンアップ
 * @param {string} userId - ユーザーID
 * @param {admin.firestore.Timestamp} threshold - しきい値タイムスタンプ
 * @returns {Promise<number>} 削除したデバイス数
 */
async function cleanupUserDevices(userId, threshold) {
  const batch = admin.firestore().batch();
  let deletedCount = 0;

  try {
    // 非アクティブなデバイスを取得
    const inactiveDevicesSnapshot = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("devices")
      .where("lastActiveAt", "<", threshold)
      .get();

    if (inactiveDevicesSnapshot.empty) {
      return 0;
    }

    // バッチで削除
    inactiveDevicesSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
      deletedCount++;
    });

    // アクティブなデバイスを取得してキャッシュを更新
    const activeDevicesSnapshot = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("devices")
      .where("isActive", "==", true)
      .where("lastActiveAt", ">=", threshold)
      .get();

    // activeDevices キャッシュを更新
    const activeDevicesSummaries = activeDevicesSnapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        deviceId: doc.id,
        platform: data.platform || "android",
        fcmToken: data.fcmToken || null,
        voipToken: data.voipToken || null,
        lastActiveAt: data.lastActiveAt,
      };
    });

    const userRef = admin.firestore().collection("users").doc(userId);
    batch.update(userRef, {
      activeDevices: activeDevicesSummaries,
      devicesUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // バッチをコミット
    await batch.commit();

    return deletedCount;
  } catch (error) {
    console.error(`Error cleaning up devices for user ${userId}:`, error);
    throw error;
  }
}

/**
 * 手動でデバイスクリーンアップを実行する HTTP トリガー関数
 * 管理者用
 */
exports.manualCleanupDevices = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    // 認証チェック
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be logged in to execute cleanup"
      );
    }

    // 管理者チェック (必要に応じて実装)
    const adminIds = [
      "Bp9DWVP8PGXEZmcdx5LZrqL5apw2",
      "AJNL9L1qGVhlDAmiqFaH7nikSOX2",
    ];

    if (!adminIds.includes(context.auth.uid)) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can execute manual cleanup"
      );
    }

    const daysInactive = data.daysInactive || 30;
    const now = admin.firestore.Timestamp.now();
    const threshold = admin.firestore.Timestamp.fromDate(
      new Date(now.toDate().getTime() - daysInactive * 24 * 60 * 60 * 1000)
    );

    console.log(`Manual cleanup triggered by ${context.auth.uid}`);
    console.log(`Threshold: ${daysInactive} days (${threshold.toDate()})`);

    let totalProcessedUsers = 0;
    let totalDeletedDevices = 0;
    let totalErrors = 0;

    try {
      const usersSnapshot = await admin.firestore().collection("users").get();

      for (const userDoc of usersSnapshot.docs) {
        try {
          const deletedCount = await cleanupUserDevices(
            userDoc.id,
            threshold
          );
          totalDeletedDevices += deletedCount;
          totalProcessedUsers++;
        } catch (error) {
          console.error(`Error processing user ${userDoc.id}:`, error);
          totalErrors++;
        }
      }

      return {
        success: true,
        processedUsers: totalProcessedUsers,
        deletedDevices: totalDeletedDevices,
        errors: totalErrors,
        daysInactive: daysInactive,
      };
    } catch (error) {
      console.error("Error during manual cleanup:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Cleanup failed",
        error
      );
    }
  });

/**
 * 特定ユーザーのデバイスをクリーンアップする HTTP トリガー関数
 * ユーザー自身が実行可能
 */
exports.cleanupMyDevices = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    // 認証チェック
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be logged in"
      );
    }

    const userId = context.auth.uid;
    const daysInactive = data.daysInactive || 30;

    const now = admin.firestore.Timestamp.now();
    const threshold = admin.firestore.Timestamp.fromDate(
      new Date(now.toDate().getTime() - daysInactive * 24 * 60 * 60 * 1000)
    );

    try {
      const deletedCount = await cleanupUserDevices(userId, threshold);

      return {
        success: true,
        deletedDevices: deletedCount,
        daysInactive: daysInactive,
      };
    } catch (error) {
      console.error(`Error cleaning up devices for user ${userId}:`, error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to cleanup devices",
        error
      );
    }
  });
