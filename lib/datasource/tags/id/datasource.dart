import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TagsIdDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final String id;

  TagsIdDatasource(this._auth, this._firestore, this.id);

  // タグドキュメントへの参照を取得
  DocumentReference<Map<String, dynamic>> get _tagRef =>
      _firestore.collection('tags').doc(id);

  // フォロワーカウントを増加
  Future<void> incrementFollowCount() async {
    try {
      await _tagRef.update({
        'followerCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to increment follow count: $e');
    }
  }

  // フォロワーカウントを減少
  Future<void> decrementFollowCount() async {
    try {
      // ドキュメントを取得して現在のカウントを確認
      final doc = await _tagRef.get();
      final currentCount = doc.data()?['followerCount'] ?? 0;

      // カウントが0以下にならないように確認
      if (currentCount > 0) {
        await _tagRef.update({
          'followerCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to decrement follow count: $e');
    }
  }

  // 投稿カウントを増加
  Future<void> incrementPostCount() async {
    try {
      await _tagRef.update({
        'postCount': FieldValue.increment(1),
        'weeklyPostCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to increment post count: $e');
    }
  }

  // 投稿カウントを減少
  Future<void> decrementPostCount() async {
    try {
      // ドキュメントを取得して現在のカウントを確認
      final doc = await _tagRef.get();
      final currentCount = doc.data()?['postCount'] ?? 0;
      final weeklyCount = doc.data()?['weeklyPostCount'] ?? 0;

      // カウントが0以下にならないように確認
      final batch = _firestore.batch();

      if (currentCount > 0) {
        batch.update(_tagRef, {
          'postCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (weeklyCount > 0) {
        batch.update(_tagRef, {
          'weeklyPostCount': FieldValue.increment(-1),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to decrement post count: $e');
    }
  }

  // タグをフォローする
  Future<void> followTag() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.uid;
      final followId = '${userId}_$id';

      // タグフォロードキュメントの参照
      final followRef = _firestore.collection('tagFollows').doc(followId);

      // ドキュメントが既に存在するか確認
      final doc = await followRef.get();
      if (doc.exists) {
        return; // 既にフォロー済みなら何もしない
      }

      // フォロー関係を作成
      await followRef.set({
        'userId': userId,
        'tagId': id,
        'followedAt': FieldValue.serverTimestamp(),
      });

      // フォロワーカウントを更新
      await incrementFollowCount();

      // ユーザードキュメントの興味タグを更新（オプション）
      await _firestore.collection('users').doc(userId).update({
        'interestTags': FieldValue.arrayUnion([id])
      });
    } catch (e) {
      throw Exception('Failed to follow tag: $e');
    }
  }

  // タグのフォローを解除する
  Future<void> unfollowTag() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userId = currentUser.uid;
      final followId = '${userId}_$id';

      // タグフォロードキュメントの参照
      final followRef = _firestore.collection('tagFollows').doc(followId);

      // ドキュメントが存在するか確認
      final doc = await followRef.get();
      if (!doc.exists) {
        return; // フォローしていなければ何もしない
      }

      // フォロー関係を削除
      await followRef.delete();

      // フォロワーカウントを更新
      await decrementFollowCount();

      // ユーザードキュメントの興味タグを更新（オプション）
      await _firestore.collection('users').doc(userId).update({
        'interestTags': FieldValue.arrayRemove([id])
      });
    } catch (e) {
      throw Exception('Failed to unfollow tag: $e');
    }
  }

  // タグ情報を取得
  Future<Map<String, dynamic>?> getTagInfo() async {
    try {
      final doc = await _tagRef.get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get tag info: $e');
    }
  }

  // タグが現在のユーザーにフォローされているか確認
  Future<bool> isFollowedByCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      final userId = currentUser.uid;
      final followId = '${userId}_$id';

      final doc = await _firestore.collection('tagFollows').doc(followId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if tag is followed: $e');
    }
  }

  // 関連するタグを取得
  Future<List<String>> getRelatedTags() async {
    try {
      final doc = await _tagRef.get();
      final data = doc.data();
      if (data != null && data.containsKey('relatedTags')) {
        return List<String>.from(data['relatedTags']);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get related tags: $e');
    }
  }

  // カテゴリに基づく同じカテゴリのタグを取得
  Future<List<Map<String, dynamic>>> getSimilarTagsInCategory(int limit) async {
    try {
      final doc = await _tagRef.get();
      final category = doc.data()?['category'];

      if (category == null) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('tags')
          .where('category', isEqualTo: category)
          .where('id', isNotEqualTo: id)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get similar tags: $e');
    }
  }
}
