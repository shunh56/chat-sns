import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final footprintDatasourceProvider = Provider(
  (ref) => FootprintDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class FootprintDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  FootprintDatasource(this._auth, this._firestore);

  final footprints = "footprints";
  final footprinteds = "footprinteds";

  Future<QuerySnapshot<Map<String, dynamic>>> fetchFootprints() async {
    return await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprints)
        .orderBy("updatedAt", descending: true)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchFootprinteds() async {
    return await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprinteds)
        .orderBy("updatedAt", descending: true)
        .get();
  }

  addFootprint(String userId) {
    final ts = Timestamp.now();
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprints)
        .doc(userId)
        .set({
      "userId": userId,
      "count": FieldValue.increment(1),
      "updatedAt": ts,
    }, SetOptions(merge: true));
    _firestore
        .collection("users")
        .doc(userId)
        .collection(footprinteds)
        .doc(_auth.currentUser!.uid)
        .set({
      "userId": _auth.currentUser!.uid,
      "count": FieldValue.increment(1),
      "updatedAt": ts,
    }, SetOptions(merge: true));
  }

  deleteFootprint(String userId) {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(footprints)
        .doc(userId)
        .delete();
    _firestore
        .collection("users")
        .doc(userId)
        .collection(footprinteds)
        .doc(_auth.currentUser!.uid)
        .delete();
  }
}
