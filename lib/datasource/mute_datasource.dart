// Package imports:
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final muteDatasourceProvider = Provider<MuteDatasource>(
  (ref) => MuteDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class MuteDatasource {
  MuteDatasource(
    this._auth,
    this._firestore,
  );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final mutes = "mutes";
  final muteds = "muteds";

  Future<QuerySnapshot> getMutes() async {
    return await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(mutes)
        .get();
  }

  Future<void> muteUser(String userId) async {
    Timestamp ts = Timestamp.now();
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(mutes)
        .doc(userId)
        .set({
      "createdAt": ts,
    });
    _firestore
        .collection("users")
        .doc(userId)
        .collection(muteds)
        .doc(_auth.currentUser!.uid)
        .set({
      "createdAt": ts,
    });

    return;
  }

  Future<void> unMuteUser(String userId) async {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(mutes)
        .doc(userId)
        .delete();
    _firestore
        .collection("users")
        .doc(userId)
        .collection(muteds)
        .doc(_auth.currentUser!.uid)
        .delete();
    return;
  }
}
