import 'package:app/core/values.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activitiesDatasourceProvider = Provider(
  (ref) => ActivitiesDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class ActivitiesDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  ActivitiesDatasource(this._auth, this._firestore);

  final collectionName = "activites";

  Stream<QuerySnapshot<Map<String, dynamic>>> streamActivity() {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(collectionName)
        .orderBy("updatedAt", descending: true)
        .limit(1)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getRecentActivities() async {
    return await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(collectionName)
        .orderBy("updatedAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  Future<void> readActivities() async {
    final query = await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(collectionName)
        //.where("isSeen", isEqualTo: false)
        .get();
    for (var doc in query.docs) {
      doc.reference.update({
        "isSeen": true,
      });
    }
  }

  addLikeToPost(String userId, String postId) async {
    final id = "${postId}_postLike";
    final snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection(collectionName)
        .doc(id)
        .get();
    if (!snapshot.exists) {
      snapshot.reference.set({
        "id": id,
        "refId": postId,
        "actionType": "postLike",
        "userIds": [_auth.currentUser!.uid],
        "updatedAt": Timestamp.now(),
        "isSeen": false,
      });
    } else {
      snapshot.reference.update({
        "userIds": FieldValue.arrayUnion([_auth.currentUser!.uid]),
        "updatedAt": Timestamp.now(),
        "isSeen": false,
      });
    }
  }

  addCommentToPost(String userId, String postId) async {
    final id = "${postId}_postComment";
    final snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection(collectionName)
        .doc(id)
        .get();
    if (!snapshot.exists) {
      snapshot.reference.set({
        "id": id,
        "refId": postId,
        "actionType": "postComment",
        "userIds": [_auth.currentUser!.uid],
        "updatedAt": Timestamp.now(),
        "isSeen": false,
      });
    } else {
      snapshot.reference.update({
        "userIds": FieldValue.arrayUnion([_auth.currentUser!.uid]),
        "updatedAt": Timestamp.now(),
        "isSeen": false,
      });
    }
  }

  addLikeToCurrentStatusPost(String userId, String postId) async {
    final id = "${postId}_currentStatusPostLike";
    final snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection(collectionName)
        .doc(id)
        .get();
    if (!snapshot.exists) {
      snapshot.reference.set({
        "id": id,
        "refId": postId,
        "actionType": "currentStatusPostLike",
        "userIds": [_auth.currentUser!.uid],
        "updatedAt": Timestamp.now(),
        "isSeen": false,
      });
    } else {
      snapshot.reference.update({
        "userIds": FieldValue.arrayUnion([_auth.currentUser!.uid]),
        "updatedAt": Timestamp.now(),
        "isSeen": false,
      });
    }
  }
}
