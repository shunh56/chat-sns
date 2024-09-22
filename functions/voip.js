const functions = require("firebase-functions");
const { ApnsClient, Notification } = require("apns2");
const fs = require("fs");

// Initialize APNs client
const client = new ApnsClient({
  team: "CDQBCQRWL9", //"LAXS5N48FU", // Your Apple Developer Team ID
  keyId: "4TLPYQK7ZY", // Your APNs Key ID
  signingKey: Buffer.from(functions.config().voip.apn_key, "base64"), //functions.config().voip.signing_key,
  //signingKey: fs.readFileSync("./AuthKey_4TLPYQK7ZY.p8"), // Path to your .p8 key file
  defaultTopic: "com.shunh.exampleApp.voip", // Your app's bundle ID with .voip suffix for VoIP notifications
  requestTimeout: 0, // Optional, default: 0 (no timeout)
  keepAlive: true, // Optional, default: 5000
  host: "api.sandbox.push.apple.com", // Use 'api.push.apple.com' for production
  //host:"api.push.apple.com'"
});

// Function to send the notification
const sendNotification = async (data) => {
  const { tokens, name } = data;
  const notificationPayload = {
    aps: {
      alert: {
        name: name,
      },
      sound: "default",
      "content-available": 1, // Indicates a VoIP notification
    },
    type: "voip",
  };
  try {
    for (let token of tokens) {
      const notification = new Notification(token, notificationPayload);
      const res = await client.send(notification);
      console.log("result : ", res);
    }
    return { status: "success" };
  } catch (e) {
    console.error("error sending voip : ", e);
    return { status: "error", error: e };
  }
};

exports.send = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be logged in to send VoIP push."
      );
    }
    const res = await sendNotification(data);
    return res;
  });
