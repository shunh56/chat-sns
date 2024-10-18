import 'package:app/core/values.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final currentStatusPostDatasourceProvider = Provider(
  (ref) => CurrentStatusPostDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class CurrentStatusPostDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CurrentStatusPostDatasource(this._auth, this._firestore);
  final collectionName = "currentStatusPosts";

  Future<DocumentSnapshot<Map<String, dynamic>>> getPost(String id) async {
    return await _firestore.collection(collectionName).doc(id).get();
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getUsersNewestPost(
      String userId) async {
    final twentyFourHoursAgo =
        Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)));
    final q = await _firestore
        .collection("users")
        .doc(userId)
        .collection(collectionName)
        .where("createdAt", isGreaterThan: twentyFourHoursAgo)
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    List<Future<DocumentSnapshot<Map<String, dynamic>>>> futures = [];
    List<DocumentSnapshot<Map<String, dynamic>>> list = [];
    for (var doc in q.docs) {
      futures.add(getPost(doc.id));
    }
    await Future.wait(futures);
    for (var element in futures) {
      list.add(await element);
    }
    return list;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUsersPosts(
      String userId) async {
    final twentyFourHoursAgo =
        Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)));
    return await _firestore
        .collection("users")
        .doc(userId)
        .collection(collectionName)
        .where("createdAt", isGreaterThan: twentyFourHoursAgo)
        .orderBy("createdAt", descending: true)
        .limit(20)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostFromUserIds(
      List<String> userIds) async {
    return await _firestore
        .collection(collectionName)
        .where("userId", whereIn: userIds)
        .orderBy("createdAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  addPost(Map<String, dynamic> before, Map<String, dynamic> after) {
    final String id = const Uuid().v4();
    _firestore.collection(collectionName).doc(id).set(
      {
        "id": id,
        "userId": _auth.currentUser!.uid,
        "createdAt": Timestamp.now(),
        "updatedAt": Timestamp.now(),
        "before": before,
        "after": after,
        "likeCount": 0,
        "replyCount": 0,
      },
    );
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
