/*const ALGOLIA_ID = "YOUR_ALGOLIA_APP_ID";
const ALGOLIA_ADMIN_KEY = "YOUR_ALGOLIA_ADMIN_KEY";
const ALGOLIA_INDEX_NAME = "posts";

const client = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);
const index = client.initIndex(ALGOLIA_INDEX_NAME);

exports.onPostCreated = functions.firestore
  .document("posts/{postId}")
  .onCreate((snap, context) => {
    const post = snap.data();
    post.objectID = context.params.postId;

    return index.saveObject(post);
  });

exports.onPostUpdated = functions.firestore
  .document("posts/{postId}")
  .onUpdate((change, context) => {
    const newData = change.after.data();
    newData.objectID = context.params.postId;

    return index.saveObject(newData);
  });

exports.onPostDeleted = functions.firestore
  .document("posts/{postId}")
  .onDelete((snap, context) => {
    return index.deleteObject(context.params.postId);
  });
 */
