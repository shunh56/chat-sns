import 'package:app/datasource/post/post_datasource.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/reply.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRepositoryProvider = Provider(
  (ref) => PostRepository(
    ref.read(postDatasourceProvider),
  ),
);

class PostRepository {
  final PostDatasource _datasource;
  PostRepository(this._datasource);

  Future<Post> getPost(String postId) async {
    final res = await _datasource.getPost(postId);
    return Post.fromJson(res.data()!);
  }

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

  Future<List<Post>> getPostFromUserIds(List<String> userIds,
      {bool onlyPublic = false}) async {
    List<QuerySnapshot<Map<String, dynamic>>> allRes = [];
    // 30個ずつのチャンクに分ける
    for (int i = 0; i < userIds.length; i += 30) {
      // リストを30個のチャンクに分割
      final chunk =
          userIds.sublist(i, i + 30 > userIds.length ? userIds.length : i + 30);
      // チャンクに対してFirestoreクエリを実行
      final res =
          await _datasource.getPostFromUserIds(chunk, onlyPublic: onlyPublic);
      // クエリ結果を結合
      allRes.add(res);
    }

    return allRes
        .expand((q) => q.docs.map((e) => Post.fromJson(e.data())).toList())
        .toList();
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
