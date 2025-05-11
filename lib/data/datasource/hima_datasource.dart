import 'package:app/core/values.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final himaUsersDatasourceProvider = Provider(
  (ref) => HimaUsersDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class HimaUsersDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  HimaUsersDatasource(this._auth, this._firestore);

  Future<void> addMeToList() async {
    final Timestamp now = Timestamp.now();
    final doc = await _firestore
        .collection("himaUsers")
        .doc(_auth.currentUser!.uid)
        .get();
    if (doc.exists) {
      doc.reference.update({
        "updatedAt": now,
        "count": FieldValue.increment(1),
      });
    } else {
      doc.reference.set({
        "updatedAt": now,
        "count": 1,
      });
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getHimaUsers() async {
    return await _firestore
        .collection("himaUsers")
        .orderBy("updatedAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }
}
