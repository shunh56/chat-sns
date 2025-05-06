import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsDatasourceProvider = Provider(
  (ref) => FriendsDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class FriendsDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FriendsDatasource(
    this._auth,
    this._firestore,
  );
  final collectionName = "friends";
  final deletes = "deletes";

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamFriends() {
    return _firestore
        .collection(collectionName)
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchFriendIds(
      String userId) async {
    return _firestore.collection(collectionName).doc(userId).get();
  }

  addFriend(String userId) {
    final batch = _firestore.batch();
    final myRef =
        _firestore.collection(collectionName).doc(_auth.currentUser!.uid);
    final userRef = _firestore.collection(collectionName).doc(userId);
    batch.update(myRef, {
      "data": FieldValue.arrayUnion([userId])
    });
    batch.update(userRef, {
      "data": FieldValue.arrayUnion([_auth.currentUser!.uid])
    });
    try {
      batch.commit();
    } catch (e) {
      throw Exception("フレンド追加に失敗しました。");
    }
  }

  deleteFriend(String userId) {
    final batch = _firestore.batch();
    final myRef =
        _firestore.collection(collectionName).doc(_auth.currentUser!.uid);
    final userRef = _firestore.collection(collectionName).doc(userId);
    batch.update(myRef, {
      "data": FieldValue.arrayRemove([userId])
    });
    batch.update(userRef, {
      "data": FieldValue.arrayRemove([_auth.currentUser!.uid])
    });
    try {
      batch.commit();
    } catch (e) {
      throw Exception("フレンド削除に失敗しました。");
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchDeletes() async {
    final timestamp =
        Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7)));
    return await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(deletes)
        .where("createdAt", isGreaterThanOrEqualTo: timestamp)
        .get();
  }

  void deleteUser(String userId) {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(deletes)
        .doc(userId)
        .set(
      {
        "userId": userId,
        "createdAt": Timestamp.now(),
      },
      SetOptions(merge: true),
    );
  }
}
