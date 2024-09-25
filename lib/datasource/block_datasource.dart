// Package imports:
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockDatasourceProvider = Provider<BlockDatasource>(
  (ref) => BlockDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class BlockDatasource {
  BlockDatasource(
    this._auth,
    this._firestore,
  );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final blocks = "blocks";
  final blockeds = "blockeds";

  Future<QuerySnapshot> getBlocks() async {
    return await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(blocks)
        .get();
  }

  Stream<QuerySnapshot> streamBlockedsDocument() {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(blockeds)
        .snapshots();
  }

  Future<void> blockUser(String userId) async {
    Timestamp ts = Timestamp.now();
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(blocks)
        .doc(userId)
        .set({
      "created_at": ts,
    });
    _firestore
        .collection("users")
        .doc(userId)
        .collection(blockeds)
        .doc(_auth.currentUser!.uid)
        .set({
      "created_at": ts,
    });

    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("friendRequests")
        .doc(userId)
        .delete();
    _firestore
        .collection("users")
        .doc(userId)
        .collection("friendRequests")
        .doc(_auth.currentUser!.uid)
        .delete();
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("friendRequesteds")
        .doc(userId)
        .delete();
    _firestore
        .collection("users")
        .doc(userId)
        .collection("friendRequesteds")
        .doc(_auth.currentUser!.uid)
        .delete();

    return;
  }

  Future<void> unblockUser(String userId) async {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(blocks)
        .doc(userId)
        .delete();
    _firestore
        .collection("users")
        .doc(userId)
        .collection(blockeds)
        .doc(_auth.currentUser!.uid)
        .delete();
    return;
  }
}
