import 'package:app/datasource/post/post_datasource.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/reply.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRepositoryProvider = Provider(
  (ref) => PostRepository(
    ref.read(postDatasourceProvider),
  ),
);

class PostRepository {
  final PostDatasource _datasource;
  PostRepository(this._datasource);

  Future<List<Post>> getPosts() async {
    final query = await _datasource.getPosts();
    return query.docs.map((e) => Post.fromJson(e.data())).toList();
  }

  Future<List<Post>> getPublicPosts() async {
    final query = await _datasource.fetchPublicPosts();
    return query.docs.map((e) => Post.fromJson(e.data())).toList();
  }

  Future<List<Post>> getPopularPosts() async {
    final query = await _datasource.fetchPopularPosts();
    return query.docs.map((e) => Post.fromJson(e.data())).toList();
  }

  Future<List<Post>> getPostFromUserId(String userId) async {
    final query = await _datasource.getPostFromUserId(userId);
    return query.docs.map((e) => Post.fromJson(e.data())).toList();
  }

  Stream<List<Reply>> streamPostReplies(String postId) {
    final stream = _datasource.streamPostReplies(postId);
    return stream.map((event) =>
        event.docs.map((doc) => Reply.fromJson(doc.data())).toList());
  }

  /*Future<Post?> getPostById(String postId) async {
    final res = await _datasource.getPostById(postId);
    if (res.exists) {
      return Post.fromJson(res.data()!);
    } else {
      return null;
    }
  } */

  uploadPost(
      PostState state, List<String> imageUrls, List<double> aspectRatios) {
    return _datasource.uploadPost(state.toJson(aspectRatios, imageUrls));
  }

  incrementLikeCount(String id, int count) {
    return _datasource.incrementLikeCount(id, count);
  }

  addReply(String id, String text) {
    return _datasource.addReply(id, text);
  }

  incrementLikeCountToReply(String postId, String replyId, int count) {
    return _datasource.incrementLikeCountToReply(postId, replyId, count);
  }
}
