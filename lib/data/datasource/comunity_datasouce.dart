import 'package:app/core/utils/debug_print.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final communityDatasourceProvider = Provider(
  (ref) => CommunityDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class CommunityDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CommunityDatasource(this._auth, this._firestore);
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

  createCommunity(Map<String, dynamic> json) async {
    await _firestore.collection(collectionName).doc(json["id"]).set(json);
    return await joinCommunity(json["id"]);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getRecentUsers(String communityId,
      {Timestamp? timestamp}) async {
    if (timestamp != null) {
      return await _firestore
          .collection(collectionName)
          .doc(communityId)
          .collection("members")
          .where("joinedAt", isLessThan: timestamp)
          .orderBy("joinedAt", descending: true)
          .limit(10)
          .get();
    } else {
      return await _firestore
          .collection(collectionName)
          .doc(communityId)
          .collection("members")
          .orderBy("joinedAt", descending: true)
          .limit(10)
          .get();
    }
  }

  ///
  Stream<QuerySnapshot<Map<String, dynamic>>> _streamJoinedCommunities() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('joinedCommunities')
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> streamJoinedCommunities() {
    final stream = _streamJoinedCommunities();
    return stream.asyncMap((snapshot) async {
      final List<Map<String, dynamic>> list = [];
      for (var doc in snapshot.docs) {
        final data = await getCommunityFromId(doc.id);
        if (data.exists) {
          list.add(data.data()!);
        }
      }
      return list;
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPopularCommunities() async {
    return await _firestore
        .collection('communities')
        .orderBy('memberCount', descending: true)
        .limit(20)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getNewCommunities() async {
    return await _firestore
        .collection('communities')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> searchCommunityByName(
      String query) async {
    return _firestore
        .collection(collectionName)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();
  }

  Future<void> joinCommunity(String communityId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final batch = FirebaseFirestore.instance.batch();

    // コミュニティのメンバーに追加
    final memberRef = FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .collection('members')
        .doc(uid);

    batch.set(memberRef, {
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // ユーザーの参加コミュニティに追加
    final userCommRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('joinedCommunities')
        .doc(communityId);

    batch.set(userCommRef, {
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // コミュニティのメンバー数を更新
    final commRef =
        FirebaseFirestore.instance.collection('communities').doc(communityId);

    batch.update(commRef, {
      'memberCount': FieldValue.increment(1),
    });

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('コミュニティへの参加に失敗しました');
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    DebugPrint("LEAVING COMMUNITY DATASOURCE");
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      DebugPrint("NO UID");
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    // コミュニティのメンバーから削除
    final memberRef = FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .collection('members')
        .doc(uid);

    batch.delete(memberRef);

    // ユーザーの参加コミュニティから削除
    final userCommRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('joinedCommunities')
        .doc(communityId);

    batch.delete(userCommRef);

    // コミュニティのメンバー数を更新
    final commRef =
        FirebaseFirestore.instance.collection('communities').doc(communityId);

    batch.update(commRef, {
      'memberCount': FieldValue.increment(-1),
    });

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('コミュニティからの退会に失敗しました');
    }
  }

  //MESSAGE

  Future<QuerySnapshot<Map<String, dynamic>>> fetchMessages(String communityId,
      {Timestamp? lastMessageTimestamp}) async {
    if (lastMessageTimestamp == null) {
      return await _firestore
          .collection(collectionName)
          .doc(communityId)
          .collection("messages")
          .orderBy("createdAt", descending: true)
          .limit(30)
          .get();
    } else {
      return await _firestore
          .collection(collectionName)
          .doc(communityId)
          .collection("messages")
          .where("createdAt", isLessThan: lastMessageTimestamp)
          .orderBy("createdAt", descending: true)
          .limit(30)
          .get();
    }
  }

  //最新メッセージをリアルタイムで取得する
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(
      String communityId) {
    return _firestore
        .collection(collectionName)
        .doc(communityId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots();
  }

  //CREATE
  sendMessage(String communityId, String text) {
    final json = {
      "text": text,
    };
    final data = _create(json, "text");
    _uploadMessage(communityId, data);
  }

  sendImages(
      String communityId, List<String> imageUrls, List<double> aspectRatios) {
    final json = {
      "imageUrls": imageUrls,
      "aspectRatios": aspectRatios,
    };
    final data = _create(json, "image");
    _uploadMessage(communityId, data);
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

  _uploadMessage(String communityId, Map<String, dynamic> json) {
    return _firestore
        .collection(collectionName)
        .doc(communityId)
        .collection("messages")
        .doc(json["id"])
        .set(json);
  }
}
