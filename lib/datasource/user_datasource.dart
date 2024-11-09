import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/values.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
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
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserDatasource(this._auth, this._firestore);

  final collectionName = "users";
  Future<QuerySnapshot<Map<String, dynamic>>> getOnlineUsers(
      {Timestamp? lastOpenedAt}) async {
    final floor =
        Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3)));
    if (lastOpenedAt != null) {
      return _firestore
          .collection(collectionName)
          .where("isOnline", isEqualTo: true)
          .where("lastOpenedAt", isLessThan: lastOpenedAt)
          .where("lastOpenedAt", isGreaterThan: floor)
          .orderBy("lastOpenedAt", descending: true)
          .limit(QUERY_LIMIT)
          .get();
    } else {
      return _firestore
          .collection(collectionName)
          .where("isOnline", isEqualTo: true)
          .where("lastOpenedAt", isGreaterThan: floor)
          .orderBy("lastOpenedAt", descending: true)
          .limit(10)
          .get();
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getNewUsers(
      {Timestamp? createdAt}) async {
    if (createdAt != null) {
      return _firestore
          .collection(collectionName)
          .where("createdAt", isLessThan: createdAt)
          .orderBy("createdAt", descending: true)
          .limit(QUERY_LIMIT)
          .get();
    } else {
      return _firestore
          .collection(collectionName)
          .orderBy("createdAt", descending: true)
          .limit(10)
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
      DebugPrint('Exception: $e');
      return null;
    }
  }

  updateJson(Map<String, dynamic> json) async {
    await _firestore.collection("users").doc(json["userId"]).delete();
    _firestore.collection("users").doc(json["userId"]).set(json);
  }

  createUser(Map<String, dynamic> json) {
    return _firestore.collection("users").doc(_auth.currentUser!.uid).set(json);
  }

  updateUser(Map<String, dynamic> json) {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .update(json);
  }
}
