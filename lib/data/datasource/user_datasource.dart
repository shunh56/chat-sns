import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userDatasourceProvider = Provider(
  (ref) => UserDatasource(
    ref.watch(authProvider),
    ref.read(firestoreProvider),
  ),
);

class UserDatasource {
  final int qLimit = 20;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserDatasource(this._auth, this._firestore);

  final collectionName = "users";

  Future<QuerySnapshot<Map<String, dynamic>>> getOnlineUsers() async {
    return _firestore
        .collection(collectionName)
        .where("isOnline", isEqualTo: true)
        .orderBy("lastOpenedAt", descending: true)
        .limit(qLimit)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getRecentUsers() async {
    /* final floor = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 30))); */
    return _firestore
        .collection(collectionName)
        //.where("lastOpenedAt", isGreaterThan: floor)
        .orderBy("lastOpenedAt", descending: true)
        .limit(qLimit)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getNewUsers(
      {Timestamp? createdAt}) async {
    if (createdAt != null) {
      return _firestore
          .collection(collectionName)
          .where("username", isNotEqualTo: "null")
          .where("createdAt", isLessThan: createdAt)
          .orderBy("createdAt", descending: true)
          .limit(qLimit)
          .get();
    } else {
      return _firestore
          .collection(collectionName)
          .where("username", isNotEqualTo: "null")
          .orderBy("createdAt", descending: true)
          .limit(qLimit)
          .get();
    }
  }

  // usernameのチェック用
  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchUserByUsername(
      String username) async {
    try {
      final q = await _firestore
          .collection("users")
          .where("username", isEqualTo: username)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        return q.docs.first;
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      DebugPrint('FirebaseException: $e');
      return null;
    } catch (e) {
      DebugPrint('Exception: $e');
      return null;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchUserByUserId(
      String userId) async {
    try {
      return await _firestore.collection("users").doc(userId).get();
    } on FirebaseException catch (e) {
      DebugPrint('FirebaseException: $e');
      return null;
    } catch (e) {
      DebugPrint('FetchUserByUserId Exception: $e');
      return null;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> searchUserByName(
      String name) async {
    return _firestore
        .collection("users")
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThanOrEqualTo: '$name\uf8ff')
        .limit(qLimit)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> searchUserByUsername(
      String username) async {
    return _firestore
        .collection("users")
        .where('username', isGreaterThanOrEqualTo: username)
        .where('username', isLessThanOrEqualTo: '$username\uf8ff')
        .limit(qLimit)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> searchUserByTag(
      String tagId, bool oneOnly) async {
    if (oneOnly) {
      return _firestore
          .collection("users")
          .where("profile.tags", arrayContains: tagId)
          .limit(2)
          .get();
    }
    return _firestore
        .collection("users")
        .where("profile.tags", arrayContains: tagId)
        .limit(qLimit)
        .get();
  }

  updateJson(Map<String, dynamic> json) async {
    await _firestore.collection("users").doc(json["userId"]).delete();
    _firestore.collection("users").doc(json["userId"]).set(json);
  }

  createUser(Map<String, dynamic> json) {
    final batch = _firestore.batch();

    final userRef = _firestore.collection("users").doc(_auth.currentUser!.uid);
    final friendsRef =
        _firestore.collection("friends").doc(_auth.currentUser!.uid);
    final relationref =
        _firestore.collection("relations").doc(_auth.currentUser!.uid);
    batch.set(userRef, json);
    batch.set(friendsRef, {"data": []});
    batch.set(relationref, {"requests": [], "requesteds": []});
    try {
      batch.commit();
    } catch (e) {
      throw Exception("アカウント初期化に失敗しました。");
    }
  }

  updateUser(Map<String, dynamic> json) {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .update(json);
  }
}
