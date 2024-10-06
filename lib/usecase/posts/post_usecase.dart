import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/reply.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/images/images.dart';
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

  Future<List<Post>> getPosts() async {
    return await _repository.getPosts();
  }

  Future<List<Post>> getPublicPosts() async {
    return await _repository.getPublicPosts();
  }

  Future<List<Post>> getPopularPosts() async {
    return await _repository.getPopularPosts();
  }

  Future<List<Post>> getPostFromUserId(String userId) async {
    return await _repository.getPostFromUserId(userId);
  }

  Stream<List<Reply>> streamPostReplies(String postId) {
    return _repository.streamPostReplies(postId);
  }

  /* Future<Post?> getPostById(String postId) async {
    return await _repository.getPostById(postId);
  } */

  uploadPost(PostState state) async {
    final uploader = _ref.read(imageUploadUsecaseProvider);
    final imageUrls = await uploader.uploadPostImage(state.id, state.images);
    _ref
        .read(
            userImagesNotiferProvider(_ref.read(authProvider).currentUser!.uid)
                .notifier)
        .addImages(imageUrls);
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
}
