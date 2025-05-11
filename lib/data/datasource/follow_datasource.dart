import 'package:app/core/utils/debug_print.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
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

  Future<void> followUser(String userId, String targetId) async {
    // 自分自身をフォローしようとしていないかチェック
    if (userId == targetId) {
      throw Exception('自分自身をフォローすることはできません');
    }

    // 既にフォローしているかチェック
    final isAlreadyFollowing = await isFollowing(userId, targetId);
    if (isAlreadyFollowing) {
      // 既にフォローしている場合は成功とみなして早期リターン
      DebugPrint('既にフォローしています: $userId -> $targetId');
      return;
    }

    try {
      final batch = _firestore.batch();
      final now = DateTime.now();
      final followingData = {
        'data': FieldValue.arrayUnion([
          {
            'createdAt': now,
            'userId': targetId,
          }
        ])
      };
      final followedData = {
        'data': FieldValue.arrayUnion([
          {
            'createdAt': now,
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

      // 3. フォロー数とフォロワー数をインクリメント
      final myRef = _usersCollection.doc(userId);
      batch.set(myRef, {'followingCount': FieldValue.increment(1)},
          SetOptions(merge: true));

      final userRef = _usersCollection.doc(targetId);

      batch.set(userRef, {'followerCount': FieldValue.increment(1)},
          SetOptions(merge: true));

      await batch.commit();
      DebugPrint('フォローに成功しました: $userId -> $targetId');
    } catch (e) {
      DebugPrint('フォロー操作に失敗しました: $e');
      // Firestoreの操作中にエラーが発生した場合
      throw Exception('フォロー操作に失敗しました: ${e.toString()}');
    }
  }

  Future<void> unfollowUser(String userId, String targetId) async {
    // 自分自身をアンフォローしようとしていないかチェック
    if (userId == targetId) {
      throw Exception('自分自身をアンフォローすることはできません');
    }

    // フォローしているかチェック
    final isCurrentlyFollowing = await isFollowing(userId, targetId);
    if (!isCurrentlyFollowing) {
      // フォローしていない場合は成功とみなして早期リターン
      DebugPrint('フォローしていないユーザー: $userId -> $targetId');
      return;
    }

    try {
      final followingList = await _getFollowingList(userId);
      final followerList = await _getFollowerList(targetId);

      // 削除対象のデータを検索
      final followingToRemove =
          followingList.where((item) => item['userId'] == targetId).toList();
      final followerToRemove =
          followerList.where((item) => item['userId'] == userId).toList();

      if (followingToRemove.isEmpty || followerToRemove.isEmpty) {
        DebugPrint('フォロー関係が見つかりません: $userId -> $targetId');
        return; // エラーを投げずに早期リターン
      }

      final batch = _firestore.batch();

      // 1. followingsコレクションから削除
      batch.set(
          _followingsCollection.doc(userId),
          {'data': FieldValue.arrayRemove(followingToRemove)},
          SetOptions(merge: true));

      // 2. followersコレクションから削除
      batch.set(
          _followersCollection.doc(targetId),
          {'data': FieldValue.arrayRemove(followerToRemove)},
          SetOptions(merge: true));

      // 3. フォロー数とフォロワー数をデクリメント
      batch.update(_usersCollection.doc(userId),
          {'followingCount': FieldValue.increment(-1)});

      batch.update(_usersCollection.doc(targetId),
          {'followerCount': FieldValue.increment(-1)});

      await batch.commit();
      DebugPrint('アンフォローに成功しました: $userId -> $targetId');
    } catch (e) {
      DebugPrint('アンフォロー操作に失敗しました: $e');
      throw Exception('アンフォロー操作に失敗しました: ${e.toString()}');
    }
  }

  /// ユーザーがフォローしている人のリストを取得
  Future<List<String>> getFollowing(String userId) async {
    try {
      final list = await _getFollowingList(userId);
      return list.map((item) => item['userId'] as String).toList();
    } catch (e) {
      DebugPrint('フォローリスト取得エラー: $e');
      return []; // エラー時は空リストを返す
    }
  }

  /// ユーザーのフォロワーリストを取得
  Future<List<String>> getFollowers(String userId) async {
    try {
      final list = await _getFollowerList(userId);
      return list.map((item) => item['userId'] as String).toList();
    } catch (e) {
      DebugPrint('フォロワーリスト取得エラー: $e');
      return []; // エラー時は空リストを返す
    }
  }

  /// ユーザーのフォロワーをリアルタイムで監視するStream
  Stream<List<String>> getFollowersStream(String userId) {
    return _followersCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return <String>[];
      }

      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      if (!data.containsKey('data')) {
        return <String>[];
      }

      final followersList = List<Map<String, dynamic>>.from(data['data'] ?? []);
      // フォロワーのリストをユーザーIDのリストに変換
      return followersList.map((item) => item['userId'] as String).toList();
    });
  }

  /// ユーザーがターゲットをフォローしているかどうかを確認
  Future<bool> isFollowing(String userId, String targetId) async {
    try {
      final list = await _getFollowingList(userId);
      return list.any((item) => item['userId'] == targetId);
    } catch (e) {
      DebugPrint('フォロー状態確認エラー: $e');
      return false; // エラー時はフォローしていないと見なす
    }
  }

  // ここが最も重要な修正ポイント - ドキュメントが存在しない場合のエラー処理
  Future<List<Map<String, dynamic>>> _getFollowingList(String userId) async {
    try {
      final ref = _followingsCollection.doc(userId);
      final doc = await ref.get();

      if (!doc.exists) {
        return []; // ドキュメントが存在しない場合は空リスト
      }

      final data = doc.data() as Map<String, dynamic>? ?? {};
      if (!data.containsKey('data')) {
        return []; // データフィールドがない場合は空リスト
      }

      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      DebugPrint('_getFollowingList エラー: $e');
      return []; // エラー時は空リスト
    }
  }

  // 同様の修正
  Future<List<Map<String, dynamic>>> _getFollowerList(String userId) async {
    try {
      final ref = _followersCollection.doc(userId);
      final doc = await ref.get();

      if (!doc.exists) {
        return []; // ドキュメントが存在しない場合は空リスト
      }

      final data = doc.data() as Map<String, dynamic>? ?? {};
      if (!data.containsKey('data')) {
        return []; // データフィールドがない場合は空リスト
      }

      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      DebugPrint('_getFollowerList エラー: $e');
      return []; // エラー時は空リスト
    }
  }
}
