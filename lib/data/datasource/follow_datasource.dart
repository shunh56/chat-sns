import 'package:app/domain/entity/follow_model.dart';
import 'package:app/presentation/providers/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final followDatasourceProvider = Provider(
  (ref) => FirestoreFollowDataSource(
    ref.watch(firestoreProvider),
  ),
);

/// Firestoreを使用したフォロー関連のデータソース
class FirestoreFollowDataSource {
  final FirebaseFirestore _firestore;

  FirestoreFollowDataSource(this._firestore);

  /// フォロー関連の各コレクションへの参照を取得
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _followingsCollection =>
      _firestore.collection('followings');
  CollectionReference get _followersCollection =>
      _firestore.collection('followers');
  /*CollectionReference get _followActivitiesCollection =>
      _firestore.collection('follow_activities');
  CollectionReference get _followStatsByUserCollection =>
      _firestore.collection('follow_stats_by_user'); */

  Future<void> followUser(String userId, String targetId) async {
    final batch = _firestore.batch();
    final timestamp = FieldValue.serverTimestamp();
    final followingData = {
      'data': FieldValue.arrayUnion([
        {
          'createdAt': timestamp,
          'userId': targetId,
        }
      ])
    };
    final followedData = {
      'data': FieldValue.arrayUnion([
        {
          'createdAt': timestamp,
          'userId': userId,
        }
      ])
    };
    // 1. followingsコレクションに追加 (userIdがtargetIdをフォロー)
    final followingRef = _followingsCollection.doc(userId);
    batch.set(followingRef, followingData, SetOptions(merge: true));
    // 2. followersコレクションに追加 (targetIdのフォロワーにuserIdを追加)
    final followerRef = _followersCollection.doc(targetId);
    batch.set(followerRef, followedData, SetOptions(merge: true));
    // 3. フォロー数とフォロワー数をインクリメント（usersコレクションのみ）
    batch.update(_usersCollection.doc(userId),
        {'followingCount': FieldValue.increment(1)});

    batch.update(_usersCollection.doc(targetId),
        {'followerCount': FieldValue.increment(1)});
    await batch.commit();
    /* final activityRef = _followActivitiesCollection.doc();
    batch.set(activityRef, {
      'from': userId,
      'to': targetId,
      'action': 'follow',
      'createdAt': timestamp
    });

    // 5. フォロー統計情報の更新（日次・週次のカウントのみ）
    final statsUserRef = _followStatsByUserCollection.doc(userId);
    batch.set(
        statsUserRef,
        {
          'followingCountLastDay': FieldValue.increment(1),
          'followingCountLastWeek': FieldValue.increment(1)
        },
        SetOptions(merge: true));

    final statsTargetRef = _followStatsByUserCollection.doc(targetId);
    batch.set(
        statsTargetRef,
        {
          'followerCountLastDay': FieldValue.increment(1),
          'followerCountLastWeek': FieldValue.increment(1)
        },
        SetOptions(merge: true));
 */
  }

  Future<void> unfollowUser(String userId, String targetId) async {
    final followingList = await _getFollowingList(userId);
    final followerList = await _getFollowerList(userId);

    // 削除対象のデータを検索
    final followingToRemove =
        followingList.where((item) => item['userId'] == targetId).toList();
    final followerToRemove =
        followerList.where((item) => item['userId'] == userId).toList();

    final batch = _firestore.batch();

    // 1. followingsコレクションから削除
    if (followingToRemove.isNotEmpty) {
      batch.set(
          _followingsCollection.doc(userId),
          {'data': FieldValue.arrayRemove(followingToRemove)},
          SetOptions(merge: true));
    }

    // 2. followersコレクションから削除
    if (followerToRemove.isNotEmpty) {
      batch.set(
          _followersCollection.doc(targetId),
          {'data': FieldValue.arrayRemove(followerToRemove)},
          SetOptions(merge: true));
    }

    // 3. フォロー数とフォロワー数をデクリメント（usersコレクションのみ）
    batch.update(_usersCollection.doc(userId),
        {'followingCount': FieldValue.increment(-1)});

    batch.update(_usersCollection.doc(targetId),
        {'followerCount': FieldValue.increment(-1)});

    await batch.commit();
  }

  /// ユーザーがフォローしている人のリストを取得
  Future<List<String>> getFollowing(String userId) async {
    final list = await _getFollowingList(userId);
    return list.map((item) => item['userId'] as String).toList();
  }

  /// ユーザーのフォロワーリストを取得
  Future<List<String>> getFollowers(String userId) async {
    final list = await _getFollowerList(userId);
    return list.map((item) => item['userId'] as String).toList();
  }

  /// ユーザーのフォロワーをリアルタイムで監視するStream
  Stream<List<String>> getFollowersStream(String userId) {
    return _followersCollection.doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final followersList = List<Map<String, dynamic>>.from(data['data'] ?? []);
      // フォロワーのリストをユーザーIDのリストに変換
      return followersList.map((item) => item['userId'] as String).toList();
    });
  }

  /// ユーザーがターゲットをフォローしているかどうかを確認
  Future<bool> isFollowing(String userId, String targetId) async {
    final list = await _getFollowingList(userId);
    return list.any((item) => item['userId'] == targetId);
  }

  Future<List<Map<String, dynamic>>> _getFollowingList(String userId) async {
    final ref = _followingsCollection.doc(userId);
    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>;
    final list = List<Map<String, dynamic>>.from(data['data'] ?? []);
    return list;
  }

  Future<List<Map<String, dynamic>>> _getFollowerList(String userId) async {
    final ref = _followersCollection.doc(userId);
    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>;
    final list = List<Map<String, dynamic>>.from(data['data'] ?? []);
    return list;
  }
}
