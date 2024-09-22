import 'package:app/presentation/providers/notifier/image/image_uploader_notifier.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

final postDatasourceProvider = Provider(
  (ref) => PostDatasource(
    ref,
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class PostDatasource {
  final Ref _ref;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  PostDatasource(this._ref, this._auth, this._firestore);
  final collectionName = "posts";

  Future<QuerySnapshot<Map<String, dynamic>>> getPosts() async {
    return await _firestore
        .collection(collectionName)
        .orderBy("createdAt", descending: true)
        .limit(30)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchPublicPosts() async {
    return await _firestore
        .collection(collectionName)
        .where("isPublic", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .limit(30)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchPopularPosts() async {
    return await _firestore
        .collection(collectionName)
        .orderBy("likeCount", descending: true)
        .limit(30)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostFromUserId(
      String userId) async {
    return await _firestore
        .collection(collectionName)
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPostReplies(String postId) {
    return _firestore
        .collection(collectionName)
        .doc(postId)
        .collection("replies")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getPostById(
      String postId) async {
    return await _firestore.collection(collectionName).doc(postId).get();
  }

  uploadPost(PostState state) async {
    final String id = const Uuid().v4();
    final Timestamp now = Timestamp.now();

    List<double> aspectRatios = [];
    List<Future<String>> futures = [];
    for (var file in state.images) {
      final originalImage = img.decodeImage((file).readAsBytesSync());
      int? width = originalImage?.width;
      int? height = originalImage?.height;
      aspectRatios.add((height! / width!) * 100.roundToDouble() / 100);
      futures
          .add(_ref.read(imageUploaderNotifierProvider).uploadIconImage(file));
    }
    List<String> mediaUrls = await Future.wait(futures);

    _firestore.collection(collectionName).doc(id).set({
      "id": id,
      "createdAt": now,
      "userId": _auth.currentUser!.uid,
      "text": state.text,
      "mediaUrls": mediaUrls,
      "aspectRatios": aspectRatios,
      "likeCount": 0,
      "replyCount": 0,
      "isDeletedByUser": false,
      "isDeletedByAdmin": false,
      "isDeletedByModerator": false,
      "isPublic": state.isPublic,
    });
  }

  incrementLikeCount(String id, int count) {
    _firestore.collection(collectionName).doc(id).update(
      {
        "updatedAt": Timestamp.now(),
        "likeCount": FieldValue.increment(count),
      },
    );
  }

  addReply(String id, String text) {
    String replyId = const Uuid().v4();
    _firestore
        .collection(collectionName)
        .doc(id)
        .collection("replies")
        .doc(replyId)
        .set(
      {
        "id": replyId,
        "createdAt": Timestamp.now(),
        "text": text,
        "userId": _auth.currentUser!.uid,
        "likeCount": 0,
      },
    );
  }

  incrementLikeCountToReply(String postId, String replyId, int count) {
    _firestore
        .collection(collectionName)
        .doc(postId)
        .collection("replies")
        .doc(replyId)
        .update(
      {
        "updatedAt": Timestamp.now(),
        "likeCount": FieldValue.increment(count),
      },
    );
  }

}
