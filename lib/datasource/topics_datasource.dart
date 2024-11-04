import 'package:app/core/values.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final topicsDatasourceProvider = Provider(
  (ref) => TopicsDatasource(
    ref.watch(firestoreProvider),
  ),
);

class TopicsDatasource {
  final FirebaseFirestore _firestore;
  TopicsDatasource(this._firestore);
  final collectionName = "topics";

  Future<QuerySnapshot<Map<String, dynamic>>> getRecentTopics() async {
    return await _firestore
        .collection(collectionName)
        .orderBy("createdAt", descending: true)
        .limit(6)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getTopicsFromCommunity(
      String communityId) async {
    return await _firestore
        .collection(collectionName)
        .where("communityId", isEqualTo: communityId)
        .orderBy("createdAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  createTopic(Map<String, dynamic> json) async {
    return _firestore.collection(collectionName).doc(json["id"]).set(json);
  }
}
