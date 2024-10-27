import 'package:app/core/values.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final postDatasourceProvider = Provider(
  (ref) => PostDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class PostDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  PostDatasource(this._auth, this._firestore);
  final collectionName = "posts";

  Future<DocumentSnapshot<Map<String, dynamic>>> getPost(
      String postId) async {
    return await _firestore.collection(collectionName).doc(postId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPosts() async {
    return await _firestore
        .collection(collectionName)
        .orderBy("createdAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchPublicPosts() async {
    return await _firestore
        .collection(collectionName)
        .where("isPublic", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchPopularPosts() async {
    return await _firestore
        .collection(collectionName)
        .orderBy("likeCount", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostFromUserIds(
      List<String> userIds,
      {bool onlyPublic = false}) async {
    if (onlyPublic) {
      return await _firestore
          .collection(collectionName)
          .where("isPublic", isEqualTo: true)
          .where("userId", whereIn: userIds)
          .orderBy("createdAt", descending: true)
          .limit(QUERY_LIMIT)
          .get();
    } else {
      return await _firestore
          .collection(collectionName)
          .where("userId", whereIn: userIds)
          .orderBy("createdAt", descending: true)
          .limit(QUERY_LIMIT)
          .get();
    }
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
        .limit(QUERY_LIMIT)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getPostById(
      String postId) async {
    return await _firestore.collection(collectionName).doc(postId).get();
  }

  uploadPost(Map<String, dynamic> json) async {
    _firestore.collection(collectionName).doc(json["id"]).set(json);
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
