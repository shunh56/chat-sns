const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");
const db = admin.firestore();

//when reply created
exports.onReplyCreate = functions
  .region("asia-northeast1")
  .firestore.document("currentStatusPosts/{postId}/replies/{replyId}")
  .onCreate(async (snap, context) => {
    const postId = context.params.postId;
    await db
      .collection("currentStatusPosts")
      .doc(postId)
      .update({
        replyCount: FieldValue.increment(1),
      });
  });
