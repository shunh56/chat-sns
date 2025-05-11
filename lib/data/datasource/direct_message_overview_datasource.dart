import 'package:app/domain/entity/message_overview.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dmOverviewDatasourceProvider = Provider(
  (ref) => DirectMessageOverviewDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class DirectMessageOverviewDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  DirectMessageOverviewDatasource(this._auth, this._firestore);

  Stream<QuerySnapshot<Map<String, dynamic>>> streamDMOverviews() {
    return _firestore
        .collection("direct_messages")
        .where("users.${_auth.currentUser!.uid}", isEqualTo: true)
        .limit(50)
        .snapshots();
  }

  joinChat(String otherUserId) {
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
    _firestore.collection("direct_messages").doc(roomId).update({
      "users.${_auth.currentUser!.uid}": true,
    });
  }

  closeChat(String otherUserId) async {
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
    final docExists =
        (await _firestore.collection("direct_messages").doc(roomId).get())
            .exists;
    if (docExists) {
      _firestore.collection("direct_messages").doc(roomId).update({
        "users.${_auth.currentUser!.uid}": false,
        "users.$otherUserId": false,
      });
    }
  }

  leaveChat(String otherUserId) async {
    String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
    final docExists =
        (await _firestore.collection("direct_messages").doc(roomId).get())
            .exists;
    if (docExists) {
      _firestore.collection("direct_messages").doc(roomId).update({
        "users.${_auth.currentUser!.uid}": false,
      });
    }
  }
}
