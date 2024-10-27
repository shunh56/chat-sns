import 'package:app/datasource/post/current_status_post_datasource.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentStatusPostRepositoryProvider = Provider(
  (ref) => CurrentStatusPostRepository(
    ref.watch(currentStatusPostDatasourceProvider),
  ),
);

class CurrentStatusPostRepository {
  final CurrentStatusPostDatasource _datasource;

  CurrentStatusPostRepository(this._datasource);

  Future<CurrentStatusPost> getPost(String postId) async {
    final res = await _datasource.getPost(postId);
    return CurrentStatusPost.fromJson(res.data()!);
  }

  Future<List<CurrentStatusPost>> getUsersNewestPost(String userId) async {
    final res = await _datasource.getUsersNewestPost(userId);
    return res.map((doc) => CurrentStatusPost.fromJson(doc.data()!)).toList();
  }

  Future<List<CurrentStatusPost>> getUsersPosts(String userId) async {
    final res = await _datasource.getUsersPosts(userId);
    return res.docs
        .map((doc) => CurrentStatusPost.fromJson(doc.data()))
        .toList();
  }

  Future<List<CurrentStatusPost>> getPostFromUserIds(
      List<String> userIds) async {
    List<QuerySnapshot<Map<String, dynamic>>> allRes = [];
    // 30個ずつのチャンクに分ける
    for (int i = 0; i < userIds.length; i += 30) {
      // リストを30個のチャンクに分割
      final chunk =
          userIds.sublist(i, i + 30 > userIds.length ? userIds.length : i + 30);
      // チャンクに対してFirestoreクエリを実行
      final res = await _datasource.getPostFromUserIds(chunk);
      // クエリ結果を結合
      allRes.add(res);
    }

    return allRes
        .expand((q) =>
            q.docs.map((e) => CurrentStatusPost.fromJson(e.data())).toList())
        .toList();
  }

  addPost(Map<String, dynamic> before, Map<String, dynamic> after) {
    return _datasource.addPost(before, after);
  }

  incrementLikeCount(String id, int count) {
    return _datasource.incrementLikeCount(id, count);
  }

  addReply(String id, String text) {
    return _datasource.addReply(id, text);
  }

  readPost(String id) {
    return _datasource.readPost(id);
  }

  incrementLikeCountToReply(String postId, String replyId, int count) {
    return _datasource.incrementLikeCountToReply(postId, replyId, count);
  }
}
