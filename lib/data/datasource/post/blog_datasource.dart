import 'package:app/core/values.dart';
import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final blogDatasourceProvider = Provider(
  (ref) => BlogDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class BlogDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  BlogDatasource(this._auth, this._firestore);
  final collectionName = "post_blogs";

  Future<QuerySnapshot<Map<String, dynamic>>> getPosts() async {
    return await _firestore
        .collection(collectionName)
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

  Future<QuerySnapshot<Map<String, dynamic>>> getPostFromUserId(
      String userId) async {
    return await _firestore
        .collection(collectionName)
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get();
  }

  /* Future<DocumentSnapshot<Map<String, dynamic>>> _getPostById(
      String postId) async {
    return await _firestore.collection(collectionName).doc(postId).get();
  } */

  uploadPost(String title, List<dynamic> contents) async {
    final String id = const Uuid().v4();
    final Timestamp now = Timestamp.now();

    _firestore.collection(collectionName).doc(id).set({
      "title": title,
      "contents": contents,
      //
      "id": id,
      "userId": _auth.currentUser!.uid,
      "createdAt": now,
      "updatedAt": now,
      "likeCount": 0,
      "replyCount": 0,
      //
      "isDeletedByUser": false,
      "isDeletedByAdmin": false,
      "isDeletedByModerator": false,
    });

    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(collectionName)
        .doc(id)
        .set(
      {
        "id": id,
        "createdAt": Timestamp.now(),
      },
    );
  }
}
