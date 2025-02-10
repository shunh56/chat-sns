import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ffDatasourceProvider = Provider(
  (ref) => FFDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class FFDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  FFDatasource(this._auth, this._firestore);

  static const String followingsCollection = "followings";
  static const String followersCollection = "followers";

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> _initializeCollection(String collection, String userId) async {
    await _firestore.collection(collection).doc(userId).set({
      "data": [],
    });
  }

  Future<Map<String, dynamic>?> getFollowings({String? userId}) async {
    final snapshot = await _firestore
        .collection(followingsCollection)
        .doc(userId ?? _currentUserId)
        .get();

    if (!snapshot.exists) {
      await _initializeCollection(
        followingsCollection,
        userId ?? _currentUserId,
      );
      return {"data": []};
    }
    return snapshot.data();
  }

  Future<Map<String, dynamic>?> getFollowers({String? userId}) async {
    final snapshot = await _firestore
        .collection(followersCollection)
        .doc(userId ?? _currentUserId)
        .get();

    if (!snapshot.exists) {
      await _initializeCollection(
        followingsCollection,
        userId ?? _currentUserId,
      );
      return {"data": []};
    }
    return snapshot.data();
  }

  Future<void> followUser(String targetUserId) async {
    if (_currentUserId == targetUserId) {
      throw Exception('Cannot follow yourself');
    }

    final batch = _firestore.batch();
    final myFollowingsRef =
        _firestore.collection(followingsCollection).doc(_currentUserId);
    final targetFollowersRef =
        _firestore.collection(followersCollection).doc(targetUserId);

    try {
      final followData = {
        "userId": targetUserId,
        "createdAt": Timestamp.now(),
        "lastOpenedAt": Timestamp.now(),
      };

      final followersData = {
        "userId": _currentUserId,
        "createdAt": Timestamp.now(),
        "lastOpenedAt": Timestamp.now(),
      };

      final myDoc = await myFollowingsRef.get();
      final targetDoc = await targetFollowersRef.get();

      // 自分のフォローリストを更新
      if (!myDoc.exists) {
        batch.set(myFollowingsRef, {
          "data": [followData]
        });
      } else {
        final List<dynamic> currentData = myDoc.data()?['data'] ?? [];
        if (!currentData.any((item) => item['userId'] == targetUserId)) {
          batch.update(myFollowingsRef, {
            "data": FieldValue.arrayUnion([followData])
          });
        }
      }

      // 相手のフォロワーリストを更新
      if (!targetDoc.exists) {
        batch.set(targetFollowersRef, {
          "data": [followersData]
        });
      } else {
        final List<dynamic> currentData = targetDoc.data()?['data'] ?? [];
        if (!currentData.any((item) => item['userId'] == _currentUserId)) {
          batch.update(targetFollowersRef, {
            "data": FieldValue.arrayUnion([followersData])
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to follow user: ${e.toString()}');
    }
  }

  Future<void> unfollowUser(String targetUserId) async {
    if (_currentUserId == targetUserId) {
      throw Exception('Cannot unfollow yourself');
    }

    try {
      final batch = _firestore.batch();
      final myFollowingsRef =
          _firestore.collection(followingsCollection).doc(_currentUserId);
      final targetFollowersRef =
          _firestore.collection(followersCollection).doc(targetUserId);

      final myDoc = await myFollowingsRef.get();
      if (myDoc.exists && myDoc.data() != null) {
        final List<dynamic> currentData = myDoc.data()!['data'] ?? [];
        final itemToRemove = currentData.firstWhere(
            (item) => item['userId'] == targetUserId,
            orElse: () => null);
        if (itemToRemove != null) {
          batch.update(myFollowingsRef, {
            "data": FieldValue.arrayRemove([itemToRemove])
          });
        }
      }

      final targetDoc = await targetFollowersRef.get();
      if (targetDoc.exists && targetDoc.data() != null) {
        final List<dynamic> currentData = targetDoc.data()!['data'] ?? [];
        final itemToRemove = currentData.firstWhere(
            (item) => item['userId'] == _currentUserId,
            orElse: () => null);
        if (itemToRemove != null) {
          batch.update(targetFollowersRef, {
            "data": FieldValue.arrayRemove([itemToRemove])
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unfollow user: ${e.toString()}');
    }
  }
}
