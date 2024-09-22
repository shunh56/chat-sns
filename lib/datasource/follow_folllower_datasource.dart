/*// Package imports:
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final ffDatasourceProvider = Provider<FFDatasource>(
  (ref) => FFDatasource(
    ref,
    ref.watch(firestoreProvider),
    ref.watch(authProvider),
  ),
);

class FFDatasource {
  FFDatasource(this._ref, this._firestore, this._auth);
  final Ref _ref;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<QuerySnapshot> streamFollowers() {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("followers")
        .snapshots();
  }

  Future<QuerySnapshot> getFollowings({String? userId}) async {
    String id = userId ?? _auth.currentUser!.uid;
    return await _firestore
        .collection("users")
        .doc(id)
        .collection("followings")
        .limit(50)
        .get();
  }

  Future<QuerySnapshot> getFollowers({String? userId}) async {
    String id = userId ?? _auth.currentUser!.uid;
    return await _firestore
        .collection("users")
        .doc(id)
        .collection("followers")
        .limit(50)
        .get();
  }

  Future<void> followUser(String userId) async {
    DateTime now = DateTime.now();
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("followings")
        .doc(userId)
        .set({"createdAt": now.toString()});
    _firestore
        .collection("users")
        .doc(userId)
        .collection("followers")
        .doc(_auth.currentUser!.uid)
        .set({"createdAt": now.toString()});
  }

  Future<void> unfollowUser(String userId) async {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("followings")
        .doc(userId)
        .delete();
    _firestore
        .collection("users")
        .doc(userId)
        .collection("followers")
        .doc(_auth.currentUser!.uid)
        .delete();
  }
}
 */