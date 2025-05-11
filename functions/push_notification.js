const functions = require("firebase-functions");
const admin = require("firebase-admin");

// 通知タイプ定義
const NOTIFICATION_TYPES = {
  DM: "dm",
  CALL: "call",
  LIKE: "like",
  COMMENT: "comment",
  FOLLOW: "follow",
  FRIEND_REQUEST: "friend_request",
  // 他の通知タイプ
};

// 統一された通知送信関数
exports.sendPushNotificationV2 = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    // ユーザー認証チェック
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be logged in to send notifications."
      );
    }

    const { notification } = data;

    // バリデーション
    if (!notification || !notification.type || !notification.sender) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Notification must contain type and sender information."
      );
    }

    // 単一受信者か複数受信者かを判断
    const isMulticast =
      notification.recipients && Array.isArray(notification.recipients);

    // メッセージ構築
    const baseMessage = createBaseMessage(notification);

    try {
      let response;

      if (isMulticast) {
        // 複数デバイス向け送信
        const tokens = notification.recipients
          .map((r) => r.fcmToken)
          .filter(Boolean);
        response = await sendMulticastNotification(tokens, baseMessage);
      } else if (notification.receiver && notification.receiver.fcmToken) {
        // 単一デバイス向け送信
        response = await sendSingleNotification(
          notification.receiver.fcmToken,
          baseMessage
        );
      } else {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Invalid recipient information"
        );
      }

      return {
        success: true,
        messageId: response,
      };
    } catch (error) {
      console.error("Error sending notification:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Error sending notification",
        error
      );
    }
  });

// 基本メッセージ構築関数
function createBaseMessage(notification) {
  const baseMessage = {
    notification: notification.content && {
      title: notification.content.title,
      body: notification.content.body,
    },
    data: {
      type: notification.type,
      senderId: notification.sender.userId,
      senderName: notification.sender.name,
      senderImageUrl: notification.sender.imageUrl,
      timestamp: notification.metadata?.timestamp || new Date().toISOString(),
      ...flattenPayload(notification.payload),
    },
    android: {
      priority: notification.metadata?.priority === "high" ? "high" : "normal",
      notification: {
        sound: "default",
        channelId: getChannelIdByType(notification.type),
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          category:
            notification.metadata?.category ||
            getApnsCategoryByType(notification.type),
          contentAvailable: 1,
        },
      },
      headers: getApnsHeadersByType(notification.type),
    },
  };

  return baseMessage;
}

// ペイロードをフラット化する関数（FCMはネストされたデータをサポートしないため）
function flattenPayload(payload) {
  if (!payload) return {};

  const result = {};
  Object.keys(payload).forEach((key) => {
    const value = payload[key];
    result[key] =
      typeof value === "object" ? JSON.stringify(value) : String(value);
  });

  return result;
}

// 単一デバイスへの送信
async function sendSingleNotification(token, message) {
  return await admin.messaging().send({
    token,
    ...message,
  });
}

// 複数デバイスへの送信
async function sendMulticastNotification(tokens, message) {
  const response = await admin.messaging().sendEachForMulticast({
    tokens,
    ...message,
  });

  // 無効なトークンを処理
  const failedTokens = response.responses.reduce((acc, resp, idx) => {
    if (!resp.success) {
      console.log(
        `Error code: ${resp.error.code}, message: ${resp.error.message}`
      );
      if (
        resp.error.code === "messaging/invalid-registration-token" ||
        resp.error.code === "messaging/registration-token-not-registered"
      ) {
        acc.push(tokens[idx]);
      }
    }
    return acc;
  }, []);

  if (failedTokens.length > 0) {
    console.log("List of invalid tokens: ", failedTokens);
    // データベースから無効なトークンを削除するロジックを追加
  }

  return response;
}

// 通知タイプに基づくAndroidチャンネルIDの取得
function getChannelIdByType(type) {
  switch (type) {
    case NOTIFICATION_TYPES.CALL:
      return "call_channel";
    case NOTIFICATION_TYPES.DM:
      return "message_channel";
    default:
      return "default_channel";
  }
}

// 通知タイプに基づくApnsカテゴリの取得
function getApnsCategoryByType(type) {
  switch (type) {
    case NOTIFICATION_TYPES.CALL:
      return "callCategory";
    case NOTIFICATION_TYPES.DM:
      return "messageCategory";
    default:
      return "defaultCategory";
  }
}

// 通知タイプに基づくApnsヘッダーの取得
function getApnsHeadersByType(type) {
  const baseHeaders = {
    "apns-priority": "5",
    "apns-topic": "com.blank.sns",
  };

  if (type === NOTIFICATION_TYPES.CALL) {
    return {
      ...baseHeaders,
      "apns-push-type": "background",
    };
  }

  return baseHeaders;
}

/*
exports.sendCallNotification = functions
  .region("asia-northeast1")
  .https.onCall(async (params, context) => {
    console.log(params);
    const { fcmToken, data } = params;
    if (!fcmToken) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "FCM token is required."
      );
    }

    const message = {
      token: fcmToken,

      data: {
        userId: data.userId,
        name: data.name,
        imageUrl: data.imageUrl,
        dateTime: data.dateTime,
        type: "call",
      },
      android: {
        priority: "high",
      },
      // Add APNS (Apple) config
      apns: {
        payload: {
          aps: {
            contentAvailable: true,
          },
        },
        headers: {
          "apns-push-type": "background",
          "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
          "apns-topic": "com.blank.sns", // bundle identifier
        },
      },
    };
    try {
      await admin.messaging().send(message);
      console.log("Notification sent successfully:", response);
      return {
        success: true,
        messageId: response,
      };
    } catch (error) {
      console.error("Error sending notification:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Error sending notification",
        error
      );
    }
  });

exports.sendPushNotification = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    console.log(data);
    const { fcmToken, notification } = data;

    if (!fcmToken) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "FCM token is required."
      );
    }

    if (!notification || !notification.title || !notification.body) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Notification must contain title and body."
      );
    }

    const message = {
      token: fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      android: {
        notification: {
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
      data: {
        action: "push_notification",
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log("Notification sent successfully:", response);
      return {
        success: true,
        messageId: response,
      };
    } catch (error) {
      console.error("Error sending notification:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Error sending notification",
        error
      );
    }
  });

exports.sendMulticast = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    console.log(data);
    const { fcmTokens, notification } = data;

    if (!Array.isArray(fcmTokens) || fcmTokens.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "FCM tokens must be a non-empty array."
      );
    }

    if (!notification || !notification.title || !notification.body) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Notification must contain title and body."
      );
    }
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      android: {
        notification: {
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };
    try {
      const response = await admin.messaging().sendEachForMulticast({
        tokens: tokens,
        ...message,
      });
      console.log(`${response.successCount} messages were sent successfully`);

      const failedTokens = response.responses.reduce((acc, resp, idx) => {
        if (!resp.success) {
          console.log(
            `Error code: ${resp.error.code}, message: ${resp.error.message}`
          );
          if (
            resp.error.code === "messaging/invalid-registration-token" ||
            resp.error.code === "messaging/registration-token-not-registered"
          ) {
            acc.push(tokens[idx]);
          }
        }
        return acc;
      }, []);

      if (failedTokens.length > 0) {
        console.log("List of invalid tokens: ", failedTokens);
        // TODO: Implement logic to remove invalid tokens from the database
      }
    } catch (error) {
      console.error(`Error sending notifications for event ${eventId}:`, error);
    }
  });

  */
