import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/values.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final postDatasourceProvider = Provider(
  (ref) => PostDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class PostDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  PostDatasource(this._auth, this._firestore);
  final collectionName = "posts";

  Future<DocumentSnapshot<Map<String, dynamic>>> getPost(String postId) async {
    return await _firestore.collection(collectionName).doc(postId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPosts() async {
    return await _firestore
        .collection(collectionName)
        .orderBy("createdAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchPublicPosts() async {
    return await _firestore
        .collection(collectionName)
        .where("isPublic", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchPopularPosts() async {
    return await _firestore
        .collection(collectionName)
        .orderBy("likeCount", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostFromUserIds(
      List<String> userIds,
      {bool onlyPublic = false}) async {
    if (onlyPublic) {
      return await _firestore
          .collection(collectionName)
          .where("isPublic", isEqualTo: true)
          .where("userId", whereIn: userIds)
          .orderBy("createdAt", descending: true)
          .limit(QUERY_LIMIT)
          .get();
    } else {
      return await _firestore
          .collection(collectionName)
          .where("userId", whereIn: userIds)
          .orderBy("createdAt", descending: true)
          .limit(QUERY_LIMIT)
          .get();
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostsFromCommunityId(
      String communityId) async {
    return await _firestore
        .collection(collectionName)
        .where("communityId", isEqualTo: communityId)
        .orderBy("createdAt", descending: true)
        .limit(QUERY_LIMIT)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostFromUserId(
      String userId) async {
    return await _firestore
        .collection(collectionName)
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getImagePostFromUserId(
      String userId) async {
    return await _firestore
        .collection(collectionName)
        .where("userId", isEqualTo: userId)
        .where("mediaUrls", isNotEqualTo: [])
        .orderBy("mediaUrls")
        .orderBy("createdAt", descending: true)
        .limit(10)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPostReplies(String postId) {
    return _firestore
        .collection(collectionName)
        .doc(postId)
        .collection("replies")
        .orderBy("createdAt", descending: true)
        .limit(QUERY_LIMIT)
        .snapshots();
  }

  /*Future<DocumentSnapshot<Map<String, dynamic>>> _getPostById(
      String postId) async {
    return await _firestore.collection(collectionName).doc(postId).get();
  } */

  uploadPost(Map<String, dynamic> json) async {
    final batch = _firestore.batch();
    final postRef = _firestore.collection(collectionName).doc(json["id"]);
    batch.set(postRef, json);
    if (json["communityId"] != null) {
      final communityId = json["communityId"];
      final communityRef =
          _firestore.collection("communities").doc(communityId);
      batch.update(communityRef, {
        "updatedAt": Timestamp.now(),
        "totalPosts": FieldValue.increment(1),
        "dailyPosts": FieldValue.increment(1),
      });
    }
    try {
      batch.commit();
    } catch (e) {
      DebugPrint("POST UPLOAD ERROR");
    }
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

  incrementLikeCountToReply(String postId, String replyId, int count) {
    _firestore
        .collection(collectionName)
        .doc(postId)
        .collection("replies")
        .doc(replyId)
        .update(
      {
        "updatedAt": Timestamp.now(),
        "likeCount": FieldValue.increment(count),
      },
    );
  }

  deletePostByUser(String postId) {
    _firestore.collection(collectionName).doc(postId).update(
      {
        "isDeletedByUser": true,
      },
    );
  }

  deletePostByModerator(String postId) {
    _firestore.collection(collectionName).doc(postId).update(
      {
        "isDeletedByModerator": true,
      },
    );
  }

  deletePostByAdmin(String postId) {
    _firestore.collection(collectionName).doc(postId).update(
      {
        "isDeletedByAdmin": true,
      },
    );
  }

  Future<void> addReaction(String postId, String reactionType) async {
    final userId = _auth.currentUser!.uid;
    final docRef = _firestore.collection(collectionName).doc(postId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) throw Exception('Post does not exist');

      final data = doc.data()!;
      final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});

      if (reactions.containsKey(reactionType)) {
        final reactionData = Map<String, dynamic>.from(reactions[reactionType]);
        final userIds = List<String>.from(reactionData['userIds'] ?? []);

        if (!userIds.contains(userId)) {
          userIds.add(userId);
          reactionData['userIds'] = userIds;
          reactionData['count'] = userIds.length;
          reactionData['lastUpdated'] = FieldValue.serverTimestamp();
          reactions[reactionType] = reactionData;
        }
      } else {
        reactions[reactionType] = {
          'type': reactionType,
          'count': 1,
          'userIds': [userId],
          'lastUpdated': FieldValue.serverTimestamp(),
        };
      }

      transaction.update(docRef, {
        'reactions': reactions,
        'likeCount': FieldValue.increment(1),
      });
    });
  }

  Future<void> removeReaction(
      String postId, String userId, String reactionType) async {
    final docRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) throw Exception('Post does not exist');

      final data = doc.data()!;
      final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});

      if (reactions.containsKey(reactionType)) {
        final reactionData = Map<String, dynamic>.from(reactions[reactionType]);
        final userIds = List<String>.from(reactionData['userIds'] ?? []);

        if (userIds.contains(userId)) {
          userIds.remove(userId);

          if (userIds.isEmpty) {
            reactions.remove(reactionType);
          } else {
            reactionData['userIds'] = userIds;
            reactionData['count'] = userIds.length;
            reactionData['lastUpdated'] = FieldValue.serverTimestamp();
            reactions[reactionType] = reactionData;
          }

          transaction.update(docRef, {
            'reactions': reactions,
            'likeCount': FieldValue.increment(-1),
          });
        }
      }
    });
  }
}
