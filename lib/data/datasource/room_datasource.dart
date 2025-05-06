import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomDatasourceProvider = Provider(
  (ref) => RoomDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class RoomDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  RoomDatasource(
    this._auth,
    this._firestore,
  );

  final collectionName = "rooms";

  //GET

  //メッセージを取得する
  Future<QuerySnapshot<Map<String, dynamic>>> fetchMessages(String userId,
      {Timestamp? lastMessageTimestamp}) async {
    if (lastMessageTimestamp == null) {
      DebugPrint("get $userId messages");
      return await _firestore
          .collection(collectionName)
          .doc(userId)
          .collection("messages")
          .orderBy("createdAt", descending: true)
          .limit(30)
          .get();
    } else {
      return await _firestore
          .collection(collectionName)
          .doc(userId)
          .collection("messages")
          .where("createdAt", isLessThan: lastMessageTimestamp)
          .orderBy("createdAt", descending: true)
          .limit(30)
          .get();
    }
  }

  //最新メッセージをリアルタイムで取得する
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(String userId) {
    return _firestore
        .collection(collectionName)
        .doc(userId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots();
  }

  //CREATE
  sendMessage(String text) {
    final json = {
      "text": text,
    };
    final data = _create(json, "text");
    _uploadMessage(data);
  }

  sendImages(List<String> imageUrls, List<double> aspectRatios) {
    final json = {
      "imageUrls": imageUrls,
      "aspectRatios": aspectRatios,
    };
    final data = _create(json, "image");
    _uploadMessage(data);
  }

  Map<String, dynamic> _create(Map<String, dynamic> json, String type) {
    final id = _firestore
        .collection(collectionName)
        .doc(_auth.currentUser!.uid)
        .collection("messages")
        .doc()
        .id;

    return {
      ...json,
      "id": id,
      "userId": _auth.currentUser!.uid,
      "createdAt": Timestamp.now(),
      "type": type,
      "reactions": {},
    };
  }

  _uploadMessage(Map<String, dynamic> json) {
    return _firestore
        .collection(collectionName)
        .doc(_auth.currentUser!.uid)
        .collection("messages")
        .doc(json["id"])
        .set(json);
  }

  //UPDATE
  sendReaction() {}
}
