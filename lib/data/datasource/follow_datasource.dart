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
  CollectionReference get _followActivitiesCollection =>
      _firestore.collection('follow_activities');
  CollectionReference get _followStatsByUserCollection =>
      _firestore.collection('follow_stats_by_user');

  /// バッチ処理を使ってユーザーをフォローする
  Future<void> followUser(String userId, String targetId) async {
    final batch = _firestore.batch();
    final timestamp = FieldValue.serverTimestamp();
    final now = DateTime.now();

    // 1. followingsコレクションに追加 (userIdがtargetIdをフォロー)
    final followingRef = _followingsCollection.doc(userId);
    batch.set(
        followingRef,
        {
          'data': FieldValue.arrayUnion([
            {'createdAt': now, 'userId': targetId}
          ])
        },
        SetOptions(merge: true));

    // 2. followersコレクションに追加 (targetIdのフォロワーにuserIdを追加)
    final followerRef = _followersCollection.doc(targetId);
    batch.set(
        followerRef,
        {
          'data': FieldValue.arrayUnion([
            {'createdAt': now, 'userId': userId}
          ])
        },
        SetOptions(merge: true));

    // 3. フォロー数とフォロワー数をインクリメント（usersコレクションのみ）
    batch.update(_usersCollection.doc(userId),
        {'followingCount': FieldValue.increment(1)});

    batch.update(_usersCollection.doc(targetId),
        {'followerCount': FieldValue.increment(1)});

    // 4. フォローアクティビティを記録
    final activityRef = _followActivitiesCollection.doc();
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

    // バッチコミット
    await batch.commit();
  }

  /// バッチ処理を使ってフォローを解除する
  Future<void> unfollowUser(String userId, String targetId) async {
    // まず、followingsコレクションから該当するデータを取得
    final followingDoc = await _followingsCollection.doc(userId).get();
    final followingData = followingDoc.data() as Map<String, dynamic>? ?? {};
    final followingList =
        List<Map<String, dynamic>>.from(followingData['data'] ?? []);

    // 次に、followersコレクションから該当するデータを取得
    final followerDoc = await _followersCollection.doc(targetId).get();
    final followerData = followerDoc.data() as Map<String, dynamic>? ?? {};
    final followerList =
        List<Map<String, dynamic>>.from(followerData['data'] ?? []);

    // 削除対象のデータを検索
    final followingToRemove =
        followingList.where((item) => item['userId'] == targetId).toList();
    final followerToRemove =
        followerList.where((item) => item['userId'] == userId).toList();

    // バッチ処理開始
    final batch = _firestore.batch();
    final timestamp = FieldValue.serverTimestamp();

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

    // 4. フォローアクティビティを記録
    batch.set(_followActivitiesCollection.doc(), {
      'from': userId,
      'to': targetId,
      'action': 'unfollow',
      'createdAt': timestamp
    });

    // バッチコミット
    await batch.commit();
  }

  /// ユーザーがフォローしている人のリストを取得
  Future<List<String>> getFollowing(String userId) async {
    final doc = await _followingsCollection.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final followingList = List<Map<String, dynamic>>.from(data['data'] ?? []);

    return followingList.map((item) => item['userId'] as String).toList();
  }

  /// ユーザーのフォロワーリストを取得
  Future<List<String>> getFollowers(String userId) async {
    final doc = await _followersCollection.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final followerList = List<Map<String, dynamic>>.from(data['data'] ?? []);

    return followerList.map((item) => item['userId'] as String).toList();
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

  /// ユーザーのフォロー数をリアルタイムで監視するStream
  Stream<int> followingCountStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      return data['followingCount'] as int? ?? 0;
    });
  }

  /// ユーザーのフォロワー数をリアルタイムで監視するStream
  Stream<int> followerCountStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      return data['followerCount'] as int? ?? 0;
    });
  }

  /// ユーザーがターゲットをフォローしているかどうかを確認
  Future<bool> isFollowing(String userId, String targetId) async {
    final doc = await _followingsCollection.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final followingList = List<Map<String, dynamic>>.from(data['data'] ?? []);

    return followingList.any((item) => item['userId'] == targetId);
  }

  /// ユーザーのフォロー統計情報を取得
  Future<FollowStatsModel> getFollowStats(String userId) async {
    // ユーザードキュメントからフォロー・フォロワー数を取得
    final userDoc = await _usersCollection.doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>? ?? {};

    // 詳細な統計情報を取得
    final statsDoc = await _followStatsByUserCollection.doc(userId).get();
    final statsData = statsDoc.data() as Map<String, dynamic>? ?? {};

    return FollowStatsModel(
      // フォロー・フォロワー数はusersコレクションから取得
      followingCount: userData['followingCount'] ?? 0,
      followerCount: userData['followerCount'] ?? 0,
      // 詳細な統計情報はfollow_stats_by_userコレクションから取得
      followingCountLastDay: statsData['followingCountLastDay'] ?? 0,
      followingCountLastWeek: statsData['followingCountLastWeek'] ?? 0,
      followerCountLastDay: statsData['followerCountLastDay'] ?? 0,
      followerCountLastWeek: statsData['followerCountLastWeek'] ?? 0,
    );
  }

  /// 最近のフォローアクティビティを取得
  Future<List<FollowActivityModel>> getRecentFollowActivities(String userId,
      {int limit = 20}) async {
    final fromActivities = await _followActivitiesCollection
        .where('from', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final toActivities = await _followActivitiesCollection
        .where('to', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    // 両方のアクティビティをマージして時系列順に並べ替え
    final List<FollowActivityModel> activities = [
      ...fromActivities.docs
          .map((doc) => FollowActivityModel.fromFirestore(doc)),
      ...toActivities.docs.map((doc) => FollowActivityModel.fromFirestore(doc)),
    ];

    // 日付の新しい順にソート
    activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // limit件数に制限
    if (activities.length > limit) {
      return activities.sublist(0, limit);
    }

    return activities;
  }

  /// ユーザーが最近フォローしたユーザーIDのリストを取得
  Future<List<String>> getRecentFollowing(String userId,
      {int limit = 10}) async {
    final doc = await _followingsCollection.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final followingList = List<Map<String, dynamic>>.from(data['data'] ?? []);

    // createdAtで新しいものから並べ替え
    followingList.sort((a, b) {
      final aCreatedAt = a['createdAt'] as DateTime;
      final bCreatedAt = b['createdAt'] as DateTime;
      return bCreatedAt.compareTo(aCreatedAt); // 降順
    });

    // 最新のlimit件数を取得
    final limitedList = followingList.take(limit).toList();

    return limitedList.map((item) => item['userId'] as String).toList();
  }

  /// ユーザーを最近フォローしたユーザーIDのリストを取得
  Future<List<String>> getRecentFollowers(String userId,
      {int limit = 10}) async {
    final doc = await _followersCollection.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final followersList = List<Map<String, dynamic>>.from(data['data'] ?? []);

    // createdAtで新しいものから並べ替え
    followersList.sort((a, b) {
      final aCreatedAt = a['createdAt'] as DateTime;
      final bCreatedAt = b['createdAt'] as DateTime;
      return bCreatedAt.compareTo(aCreatedAt); // 降順
    });

    // 最新のlimit件数を取得
    final limitedList = followersList.take(limit).toList();

    return limitedList.map((item) => item['userId'] as String).toList();
  }

  /// フォロー統計のリアルタイム更新を監視するStream
  /// ユーザーコレクションからフォロー・フォロワー数を、
  /// フォロー統計コレクションから詳細な統計情報を取得
  Stream<FollowStatsModel> followStatsStream(String userId) {
    // usersコレクションとfollow_stats_by_userコレクションの両方を監視
    final userStream = _usersCollection.doc(userId).snapshots();

    // userStreamの変更を監視し、その都度statsも取得して組み合わせる
    return userStream.asyncMap((userSnapshot) async {
      final userData = userSnapshot.data() as Map<String, dynamic>? ?? {};

      // statsデータを取得（この時点で最新のデータを取得）
      final statsSnapshot =
          await _followStatsByUserCollection.doc(userId).get();
      final statsData = statsSnapshot.data() as Map<String, dynamic>? ?? {};

      return FollowStatsModel(
        // usersコレクションからフォロー・フォロワー数を取得
        followingCount: userData['followingCount'] ?? 0,
        followerCount: userData['followerCount'] ?? 0,
        // 詳細な統計情報はfollow_stats_by_userコレクションから取得
        followingCountLastDay: statsData['followingCountLastDay'] ?? 0,
        followingCountLastWeek: statsData['followingCountLastWeek'] ?? 0,
        followerCountLastDay: statsData['followerCountLastDay'] ?? 0,
        followerCountLastWeek: statsData['followerCountLastWeek'] ?? 0,
      );
    });
  }
}
