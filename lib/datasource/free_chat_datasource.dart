import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final freeChatDatasourceProvider = Provider(
  (ref) => FreeChatDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class FreeChatDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  FreeChatDatasource(this._auth, this._firestore);

  Future<QuerySnapshot<Map<String, dynamic>>> getRecentChats() async {
    DateTime now = DateTime.now();
    DateTime oneMinAgo = now.subtract(const Duration(minutes: 1));
    Timestamp ts = Timestamp.fromDate(oneMinAgo);
    return await _firestore
        .collection("freeChats")
        .where("createdAt", isGreaterThanOrEqualTo: ts)
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get();
  }

  Stream<QuerySnapshot> streamFreeChats() {
    DateTime now = DateTime.now();
    DateTime oneMinAgo = now.subtract(const Duration(minutes: 1));
    Timestamp ts = Timestamp.fromDate(oneMinAgo);
    return _firestore
        .collection("freeChats")
        .where("createdAt", isGreaterThanOrEqualTo: ts)
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots();
  }

  addMessage(String text) {
    final id = const Uuid().v4();
    final Timestamp timestamp = Timestamp.now();
    Map<String, dynamic> messageData = {
      "id": id,
      "createdAt": timestamp,
      "text": text,
      "senderId": _auth.currentUser!.uid,
    };
    _firestore.collection("freeChats").doc(id).set(messageData);
  }
}
