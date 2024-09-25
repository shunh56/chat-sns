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
exports.sendPushNotification = functions
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
