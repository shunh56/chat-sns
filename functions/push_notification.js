const functions = require("firebase-functions");
const admin = require("firebase-admin");

//CloudFunctionsに送る関数
/*
exports.sendPushNotification = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    const title = data.title;
    const body = data.body;
    const token = data.token;

    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        action: "push_notification",
        // title: title,
        // body: body,
      },
      token: token,
    };

    try {
      await admin.messaging().send(message);
      return { success: true, message: "Notification sent successfully" };
    } catch (error) {
      console.error("Error sending notification:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to send notification"
      ); 
    }
}); */
/*exports.sendPushNotification = functions
  .region("asia-northeast1")
  .https.onCall(async (params, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be logged in to send VoIP push."
      );
    }
    const { token, title, body, metaData } = params;
    console.log("messageData : ", params);
    const message = {
      token,
      data: {
        type: "haha",
        name: metaData,
      },
      //notification: { title, body },
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
          "apns-topic": "com.shunh.exampleApp", // bundle identifier
        },
      },
    };
    try {
      await admin.messaging().send(message);
      return { success: true, message: "Notification sent successfully" };
    } catch (e) {
      console.error("Error sending notification:", e);
      return { success: false, message: e.toString() };
    }
  });

exports.sendCall = functions
  .region("asia-northeast1")
  .https.onCall(async (params, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be logged in to send VoIP push."
      );
    }
    const { token, userId, name, imageUrl, dateTime } = params;
    console.log("messageData : ", params);
    const message = {
      token,
      //notification: { title, body },
      data: {
        userId: userId,
        name: name,
        imageUrl: imageUrl,
        dateTime: dateTime,
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
          "apns-topic": "com.shunh.exampleApp", // bundle identifier
        },
      },
    };
    try {
      await admin.messaging().send(message);
      return { success: true, message: "Notification sent successfully" };
    } catch (e) {
      console.error("Error sending notification:", e);
      return { success: false, message: e.toString() };
    }
  });
˝ */

async function sendNotifications(tokens, message) {
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
}
exports.sendNotification = functions
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
    return sendNotifications(fcmTokens, message);

    const messages = fcmTokens.map((token) => ({
      token,
      notification: {
        title: notification.title,
        body: notification.body,
      },
    }));

    try {
      const response = await admin.messaging().sendAll(messages);
      console.log("Notifications sent successfully:", response);
      return {
        success: true,
        sentCount: response.successCount,
        failedCount: response.failureCount,
      };
    } catch (error) {
      console.error("Error sending notifications:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Error sending notifications",
        error
      );
    }
  });
