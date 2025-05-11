import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageDatasourceProvider = Provider(
  (ref) => ImageDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class ImageDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ImageDatasource(this._auth, this._firestore);

  addImage(Map<String, dynamic> json) {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("images")
        .doc(json["id"])
        .set(json);
    return json;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getImages(
      {String? userId}) async {
    userId ?? _auth.currentUser!.uid;
    return await _firestore
        .collection("users")
        .doc(userId)
        .collection("images")
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get();
  }

  void removeImage(String id) {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("images")
        .doc(id)
        .delete();
  }
}
