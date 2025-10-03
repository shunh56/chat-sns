import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/values.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

final topicsDatasourceProvider = Provider(
  (ref) => TopicsDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class TopicsDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  TopicsDatasource(this._auth, this._firestore);
  final collectionName = "topics";

  Future<QuerySnapshot<Map<String, dynamic>>> getPopularTopics() async {
    return await _firestore
        .collection(collectionName)
        .orderBy("postCount", descending: true)
        .limit(6)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTopicsFromCommunity(
      String communityId) async {
    return await _firestore
        .collection(collectionName)
        .where("communityId", isEqualTo: communityId)
        .orderBy("updatedAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  createTopic(Map<String, dynamic> json) async {
    final batch = _firestore.batch();
    final communityId = json["communityId"];

    //
    final topicRef = _firestore.collection(collectionName).doc(json["id"]);
    batch.set(topicRef, json);
    //
    final communityRef = _firestore.collection("communities").doc(communityId);
    batch.update(communityRef, {
      "updatedAt": Timestamp.now(),
      "topicsCount": FieldValue.increment(1),
    });
    try {
      batch.commit();
    } catch (e) {
      DebugPrint(e);
    }
  }

  sendMessage(String topicId, String text) async {
    final batch = _firestore.batch();

    final Map<String, dynamic> json = {
      "id": const Uuid().v4(),
      "createdAt": Timestamp.now(),
      "userId": _auth.currentUser!.uid,
      "text": text,
    };

    final messageRef = _firestore
        .collection(collectionName)
        .doc(topicId)
        .collection("messages")
        .doc(json["id"]);

    batch.set(messageRef, json);

    final topicRef =
        FirebaseFirestore.instance.collection(collectionName).doc(topicId);

    batch.update(topicRef, {
      'updatedAt': Timestamp.now(),
      'postCount': FieldValue.increment(1),
    });

    try {
      await batch.commit();
    } catch (e) {
      // エラーハンドリング
      throw Exception('FAILED TO SEND MESSAGE');
    }
  }
}
