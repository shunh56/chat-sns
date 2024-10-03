import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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

  addImage(String imageUrl, {String type = "default"}) {
    final id = Uuid().v4();
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("images")
        .doc(id)
        .set({
      "imageUrl": imageUrl,
      "createdAt": Timestamp.now(),
    });
  }
}
