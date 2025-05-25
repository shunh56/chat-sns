import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/posts/post_reaction.dart';
import 'package:app/domain/entity/reply.dart';
import 'package:app/domain/usecases/image_uploader_usecase.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';
import 'package:app/data/repository/posts/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postUsecaseProvider = Provider(
  (ref) => PostUsecase(
    ref,
    ref.read(postRepositoryProvider),
  ),
);

class PostUsecase {
  final Ref _ref;
  final PostRepository _repository;
  PostUsecase(this._ref, this._repository);
  Future<Post> getPost(String postId) async {
    return await _repository.getPost(postId);
  }

  Future<List<Post>> getPosts() async {
    return await _repository.getPosts();
  }

  Future<List<Post>> getPublicPosts() async {
    return await _repository.getPublicPosts();
  }

  Future<List<Post>> getPopularPosts() async {
    return await _repository.getPopularPosts();
  }

  Future<List<Post>> getPostFromUserIds(List<String> userIds,
      {bool onlyPublic = false}) async {
    return await _repository.getPostFromUserIds(userIds,
        onlyPublic: onlyPublic);
  }

  Future<List<Post>> getPostsFromCommunityId(String communityId) async {
    return await _repository.getPostsFromCommunityId(communityId);
  }

  Future<List<Post>> getPostFromUserId(String userId) async {
    return await _repository.getPostFromUserId(userId);
  }

  Future<List<Post>> getImagePostFromUserId(String userId) async {
    return await _repository.getImagePostFromUserId(userId);
  }

  Stream<List<Reply>> streamPostReplies(String postId) {
    return _repository.streamPostReplies(postId);
  }

  uploadPost(PostState state) async {
    final uploader = _ref.read(imageUploadUsecaseProvider);
    final imageUrls = await uploader.uploadPostImage(state.id, state.images);
    final aspectRatios = uploader.getAspectRatios(state.images);
    return _repository.uploadPost(state, imageUrls, aspectRatios);
  }

  incrementLikeCount(String id, int count) {
    return _repository.incrementLikeCount(id, count);
  }

  addReply(String id, String text) {
    return _repository.addReply(id, text);
  }

  incrementLikeCountToReply(String postId, String replyId, int count) {
    return _repository.incrementLikeCountToReply(postId, replyId, count);
  }

  deletePostByUser(Post post) {
    return _repository.deletePostByUser(post.id);
  }

  deletePostByModerator(Post post) {
    return _repository.deletePostByModerator(post.id);
  }

  deletePostByAdmin(Post post) {
    return _repository.deletePostByAdmin(post.id);
  }

  // リアクション追加
  Future<void> addReaction(
      String postId, String userId, String reactionType) async {
    try {
      await _repository.addReaction(postId, userId, reactionType);
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  // リアクション削除
  Future<void> removeReaction(
      String postId, String userId, String reactionType) async {
    try {
      await _repository.removeReaction(postId, userId, reactionType);
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  // ユーザーの全リアクション削除（リアクション変更時）
  Future<void> removeUserAllReactions(String postId, String userId) async {
    try {
      for (final reactionType in ReactionType.allTypes) {
        await _repository.removeReaction(postId, userId, reactionType);
      }
    } catch (e) {
      throw Exception('Failed to remove all reactions: $e');
    }
  }

  // リアクション切り替え（既存があれば削除、なければ追加）
  Future<void> toggleReaction(
      String postId, String userId, String reactionType) async {
    try {
      final post = await _repository.getPost(postId);

      if (post.hasUserReacted(userId, reactionType)) {
        await removeReaction(postId, userId, reactionType);
      } else {
        // 他のリアクションを削除してから新しいリアクションを追加
        await removeUserAllReactions(postId, userId);
        await addReaction(postId, userId, reactionType);
      }
    } catch (e) {
      throw Exception('Failed to toggle reaction: $e');
    }
  }

  // 投稿のリアクション統計取得
  Future<Map<String, int>> getReactionStats(String postId) async {
    try {
      final post = await _repository.getPost(postId);

      return post.reactions.map(
        (key, value) => MapEntry(key, value.count),
      );
    } catch (e) {
      throw Exception('Failed to get reaction stats: $e');
    }
  }
}
