import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final voiceChatDatasourceProvider = Provider(
  (ref) => VoiceChatDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class VoiceChatDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  VoiceChatDatasource(this._auth, this._firestore);

  final collectionName = "voice_chats";

  //CREATE
  Future<Map<String, dynamic>> createVoiceChat(
    String title, {
    bool isPremium = false,
  }) async {
    final id = const Uuid().v4();
    final timestamp = Timestamp.now();
    final endAt = Timestamp.fromDate(
        DateTime.now().add(Duration(minutes: isPremium ? 60 : 20)));
    final json = {
      "id": id,
      "title": title,
      "joinedUsers": [],
      "adminUsers": [],
      "userMap": {},
      "createdAt": timestamp,
      "createdBy": _auth.currentUser!.uid,
      "endAt": endAt,
      "maxCount": isPremium ? 8 : 4,
    };
    await _firestore.collection(collectionName).doc(id).set(json);
    return json;
  }

  //READ

  Future<QuerySnapshot<Map<String, dynamic>>> fetchFriendsVoiceChats(
      List<String> userIds) async {
    final myId = _auth.currentUser!.uid;
    return await _firestore
        .collection(collectionName)
        .where("joinedUsers", arrayContainsAny: [...userIds, myId])
        .where("endAt", isGreaterThan: Timestamp.now())
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchVoiceChat(
      String id) async {
    return await _firestore.collection(collectionName).doc(id).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamVoiceChat(String id) {
    return _firestore.collection(collectionName).doc(id).snapshots();
  }

  //UPDATE
  Future<void> joinVoiceChat(String id, int localId) async {
    return _firestore.collection(collectionName).doc(id).update({
      "joinedUsers": FieldValue.arrayUnion([_auth.currentUser!.uid]),
      "userMap.${_auth.currentUser!.uid}": {
        "agoraUid": localId,
        "isMuted": false,
      },
      "updatedAt": Timestamp.now(),
    });
  }

  Future<void> changeMute(String id, bool isMuted) async {
    return _firestore.collection(collectionName).doc(id).update({
      "joinedUsers": FieldValue.arrayUnion([_auth.currentUser!.uid]),
      "userMap.${_auth.currentUser!.uid}.isMuted": isMuted,
      "updatedAt": Timestamp.now(),
    });
  }

  Future<void> leaveVoiceChat(String id) async {
    return _firestore.collection(collectionName).doc(id).update({
      "joinedUsers": FieldValue.arrayRemove([_auth.currentUser!.uid]),
      "updatedAt": Timestamp.now(),
    });
  }

  //DELETE
  Future<void> quitVoiceChat(String id) async {
    return _firestore.collection(collectionName).doc(id).delete();
  }
}
