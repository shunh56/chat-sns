import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/reply.dart';
import 'package:app/usecase/image_uploader_usecase.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';
import 'package:app/repository/posts/post_repository.dart';
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
}
