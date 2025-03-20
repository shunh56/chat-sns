import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/entity/story/story_view.dart';
import 'package:app/domain/repositories/story_repository.dart';
import 'package:app/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// アップロード進捗状態を管理するプロバイダー
final uploadProgressProvider = StateProvider<double>((ref) => 0.0);

class StoryRepositoryImpl implements StoryRepository {
  final FirebaseFirestore _firestore;
  final StorageService _storageService;
  final Ref _ref;

  StoryRepositoryImpl(this._firestore, this._storageService, this._ref);

  @override
  Future<void> uploadStory(Story story, String localMediaPath) async {
    try {
      // 初期進捗状態をリセット
      _ref.read(uploadProgressProvider.notifier).state = 0.0;

      // 1. ストレージにメディアをアップロード（進捗状況を監視）
      final mediaUrl = await _storageService.uploadFileWithProgress(
        'stories/${story.userId}/${story.id}',
        localMediaPath,
        (progress) {
          // 進捗状況を更新
          _ref.read(uploadProgressProvider.notifier).state = progress;
        },
      );

      // 2. メディアURLを含めたストーリーデータをFirestoreに保存
      final updatedStory = story.copyWith(mediaUrl: mediaUrl);
      await _firestore
          .collection('stories')
          .doc(story.id)
          .set(updatedStory.toFirestore());

      // 完了したらプログレスを100%に設定
      _ref.read(uploadProgressProvider.notifier).state = 1.0;
    } catch (e) {
      // エラー時もプログレスをリセット
      _ref.read(uploadProgressProvider.notifier).state = 0.0;
      throw Exception('Failed to upload story: $e');
    }
  }

  @override
  Future<Story?> getStory(String storyId) async {
    try {
      final doc = await _firestore.collection('stories').doc(storyId).get();

      if (!doc.exists) {
        return null;
      }

      return Story.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get story: $e');
    }
  }

  @override
  Future<void> updateStoryCaption(String storyId, String newCaption) async {
    try {
      await _firestore
          .collection('stories')
          .doc(storyId)
          .update({'caption': newCaption});
    } catch (e) {
      throw Exception('Failed to update story caption: $e');
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    try {
      // 1. ストーリーのデータを取得
      final storyDoc =
          await _firestore.collection('stories').doc(storyId).get();

      if (!storyDoc.exists) {
        throw Exception('Story not found');
      }

      final story = Story.fromFirestore(storyDoc);

      // 2. ストレージからメディアを削除
      await _storageService.deleteFile(story.mediaUrl);

      // 3. Firestoreからストーリーデータを削除
      await _firestore.collection('stories').doc(storyId).delete();

      // 4. 関連するいいねも削除
      final likesQuery = await _firestore
          .collection('storyLikes')
          .where('storyId', isEqualTo: storyId)
          .get();

      final batch = _firestore.batch();
      for (var doc in likesQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  @override
  Future<void> likeStory(String storyId, String userId) async {
    try {
      // トランザクションを使用して、いいね追加とカウント更新を同時に行う
      await _firestore.runTransaction((transaction) async {
        // 1. すでにいいねしているか確認
        final likeQuery = await _firestore
            .collection('storyLikes')
            .where('storyId', isEqualTo: storyId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (likeQuery.docs.isNotEmpty) {
          // すでにいいねしている場合は何もしない
          return;
        }

        // 2. いいねドキュメントを作成
        final likeRef = _firestore.collection('storyLikes').doc();
        transaction.set(likeRef, {
          'storyId': storyId,
          'userId': userId,
          'createdAt': Timestamp.now(),
        });

        // 3. ストーリーのいいねカウントを更新
        final storyRef = _firestore.collection('stories').doc(storyId);
        transaction.update(storyRef, {
          'likeCount': FieldValue.increment(1),
        });
      });
    } catch (e) {
      throw Exception('Failed to like story: $e');
    }
  }

  @override
  Future<void> unlikeStory(String storyId, String userId) async {
    try {
      // トランザクションを使用して、いいね削除とカウント更新を同時に行う
      await _firestore.runTransaction((transaction) async {
        // 1. いいねドキュメントを検索
        final likeQuery = await _firestore
            .collection('storyLikes')
            .where('storyId', isEqualTo: storyId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (likeQuery.docs.isEmpty) {
          // いいねしていない場合は何もしない
          return;
        }

        // 2. いいねドキュメントを削除
        transaction.delete(likeQuery.docs.first.reference);

        // 3. ストーリーのいいねカウントを更新
        final storyRef = _firestore.collection('stories').doc(storyId);
        transaction.update(storyRef, {
          'likeCount': FieldValue.increment(-1),
        });
      });
    } catch (e) {
      throw Exception('Failed to unlike story: $e');
    }
  }

  @override
  Future<bool> hasUserLikedStory(String storyId, String userId) async {
    try {
      final likeQuery = await _firestore
          .collection('storyLikes')
          .where('storyId', isEqualTo: storyId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return likeQuery.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check story like status: $e');
    }
  }

  @override
  Future<List<Story>> getUserStories(String userId) async {
    try {
      final query = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => Story.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user stories: $e');
    }
  }

  @override
  Future<List<Story>> getFollowingUserStories(String userId) async {
    try {
      // 1. フォロー中のユーザーIDを取得
      final followingQuery = await _firestore
          .collection('follows')
          .where('followerId', isEqualTo: userId)
          .get();

      final followingIds = followingQuery.docs
          .map((doc) => doc.data()['followingId'] as String)
          .toList();

      // 2. 有効期限内のストーリーを取得
      final now = Timestamp.now();

      // 3. フォロー中のユーザーのストーリーを取得
      // Firestoreの制約（whereInに10個以上の値を入れられない）に対応
      List<Story> stories = [];

      for (int i = 0; i < followingIds.length; i += 10) {
        final end =
            (i + 10 < followingIds.length) ? i + 10 : followingIds.length;
        final chunk = followingIds.sublist(i, end);

        final query = await _firestore
            .collection('stories')
            .where('userId', whereIn: chunk)
            .where('expiresAt', isGreaterThanOrEqualTo: now)
            .orderBy('expiresAt')
            .get();

        stories.addAll(query.docs.map((doc) => Story.fromFirestore(doc)));
      }

      // 作成日時で降順ソート
      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return stories;
    } catch (e) {
      throw Exception('Failed to get following user stories: $e');
    }
  }

  @override
  Future<void> addStoryAction(StoryAction action) async {
    try {
      // アクションを保存
      await _firestore
          .collection('storyActions')
          .doc(action.id)
          .set(action.toJson());

      // ビューアクションの場合は、ストーリーのビューカウントを更新
      if (action.actionType == StoryActionType.view) {
        await _firestore.collection('stories').doc(action.storyId).update({
          'viewCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw Exception('Failed to add story action: $e');
    }
  }

  @override
  Future<List<Story>> getActiveUserStories(String userId) async {
    try {
      final now = Timestamp.now();
      final query = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .where('expiresAt', isGreaterThanOrEqualTo: now)
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => Story.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get active user stories: $e');
    }
  }

  @override
  Future<List<Story>> getStoriesByTag(String tagId) async {
    try {
      final now = Timestamp.now();
      final query = await _firestore
          .collection('stories')
          .where('tags', arrayContains: tagId)
          /*.where('expiresAt', isGreaterThanOrEqualTo: now)
          .orderBy('expiresAt') */
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => Story.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get stories by tag: $e');
    }
  }

  @override
  Future<List<StoryAction>> getStoryActions(
      String storyId, StoryActionType type) async {
    try {
      final query = await _firestore
          .collection('storyActions')
          .where('storyId', isEqualTo: storyId)
          .where('actionType', isEqualTo: type.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => StoryAction.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get story actions: $e');
    }
  }
}
