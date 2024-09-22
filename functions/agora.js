const agora = require("agora-access-token");
const functions = require("firebase-functions");

// Firebase Cloud Functionのエントリポイント
exports.generateAgoraToken = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    console.log("fetching for agora access token");
    // ユーザーの認証
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication is required."
      );
    }

    // パラメータの取得
    const channelName = data.channelName;
    const uid = data.uid;

    // Agora App ID
    const agoraAppId = "828592cf9c2b4a31b5e083a7090a19ad";
    // Agora App Certificate
    const agoraAppCertificate = "02a11341218a44cc8c9dafbdc614eb5e";

    // トークンの有効期限 (秒単位)
    const expirationTimeInSeconds = 3600;

    try {
      // Agoraトークンの生成
      const token = agora.RtcTokenBuilder.buildTokenWithUid(
        agoraAppId,
        agoraAppCertificate,
        channelName,
        uid,
        agora.RtcRole.PUBLISHER,
        Math.floor(Date.now() / 1000) + expirationTimeInSeconds
      );
      return { token };
    } catch (e) {
      console.log("access token error: ", e);
    }
  });
