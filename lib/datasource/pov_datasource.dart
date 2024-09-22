import 'package:app/domain/entity/pov.dart';
import 'package:app/presentation/providers/notifier/image/image_uploader_notifier.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:image/image.dart' as img;

final povDatasourceProvider = Provider(
  (ref) => PovDatasource(
    ref,
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class PovDatasource {
  final Ref _ref;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final collectionName = "pov";

  PovDatasource(
    this._ref,
    this._auth,
    this._firestore,
  );

  //CREATE
  uploadPov(PovState state) async {
    final String id = const Uuid().v4();
    final Timestamp now = Timestamp.now();

    final originalImage = img.decodeImage((state.imageFile!).readAsBytesSync());
    int? width = originalImage?.width;
    int? height = originalImage?.height;
    final aspectRatio = (height! / width!) * 100.roundToDouble() / 100;
    final imageUrl = await _ref
        .read(imageUploaderNotifierProvider)
        .uploadIconImage(state.imageFile!);

    _firestore.collection(collectionName).doc(id).set({
      "text": state.text,
      "imageUrl": imageUrl,
      "aspectRatio": aspectRatio,
      //
      "id": id,
      "createdAt": now,
      "userId": _auth.currentUser!.uid,
      "likeCount": 0,
      "replyCount": 0,
      "isDeletedByUser": false,
      "isDeletedByAdmin": false,
      "isDeletedByModerator": false,
      "isPublic": false,
    });
  }

  //READ
  Future<QuerySnapshot<Map<String, dynamic>>> getPovs() async {
    return await _firestore
        .collection(collectionName)
        .orderBy("createdAt", descending: true)
        .limit(30)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchPublicPovs() async {
    return await _firestore
        .collection(collectionName)
        .where("isPublic", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .limit(30)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchPopularPovs() async {
    return await _firestore
        .collection(collectionName)
        .where("isPublic", isEqualTo: true)
        .orderBy("likeCount", descending: true)
        .limit(30)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPovsFromUserId(
      String userId) async {
    return await _firestore
        .collection(collectionName)
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPovReplies(String povId) {
    return _firestore
        .collection(collectionName)
        .doc(povId)
        .collection("replies")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  incrementLikeCount(String id, int count) {
    _firestore.collection(collectionName).doc(id).update(
      {
        "updatedAt": Timestamp.now(),
        "likeCount": FieldValue.increment(count),
      },
    );
  }

  addReply(String id, String text) {
    String replyId = const Uuid().v4();
    _firestore
        .collection(collectionName)
        .doc(id)
        .collection("replies")
        .doc(replyId)
        .set(
      {
        "id": replyId,
        "createdAt": Timestamp.now(),
        "text": text,
        "userId": _auth.currentUser!.uid,
        "likeCount": 0,
      },
    );
  }

  incrementLikeCountToReply(String povId, String replyId, int count) {
    _firestore
        .collection(collectionName)
        .doc(povId)
        .collection("replies")
        .doc(replyId)
        .update(
      {
        "updatedAt": Timestamp.now(),
        "likeCount": FieldValue.increment(count),
      },
    );
  }
}
