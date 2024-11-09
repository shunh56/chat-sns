import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final communityDatasourceProvider = Provider(
  (ref) => CommunityDatasource(
    ref.watch(firestoreProvider),
  ),
);

class CommunityDatasource {
  final FirebaseFirestore _firestore;

  CommunityDatasource(this._firestore);
  final String collectionName = "communities";
  Future<DocumentSnapshot<Map<String, dynamic>>> getCommunityFromId(
      String communityId) async {
    /* await createCommunity({
      "id": "student_life",
      "name": "学生生活",
      "description": "大学生活に関する情報共有・相談コミュニティ",
      "createdAt": DateTime.now(),
      "updatedAt": DateTime.now(),
      "memberCount": 4234,
      "dailyActiveUsers": 567,
      "weeklyActiveUsers": 2134,
      "monthlyActiveUsers": 3856,
      "totalPosts": 12567,
      "dailyPosts": 89,
      "activeVoiceRooms": 3,
      "rules": ["個人情報の共有は禁止です", "誹謗中傷は禁止です", "著作権を侵害する投稿は禁止です"],
      "moderators": ["user123", "user456"]
    });
    */
    return await _firestore.collection(collectionName).doc(communityId).get();
  }

  createCommunity(Map<String, dynamic> json) {
    return _firestore.collection(collectionName).doc(json["id"]).set(json);
  }

  Future<QuerySnapshot> getRecentUsers(String communityId) async {
    return await _firestore
        .collection(collectionName)
        .doc(communityId)
        .collection("members")
        .orderBy("joinedAt", descending: true)
        .limit(5)
        .get();
  }
}
