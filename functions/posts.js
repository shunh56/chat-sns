const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");
const db = admin.firestore();

//when reply created
exports.onReplyCreate = functions
  .region("asia-northeast1")
  .firestore.document("posts/{postId}/replies/{replyId}")
  .onCreate(async (snap, context) => {
    const postId = context.params.postId;
    await db
      .collection("posts")
      .doc(postId)
      .update({
        replyCount: FieldValue.increment(1),
      });
  });
