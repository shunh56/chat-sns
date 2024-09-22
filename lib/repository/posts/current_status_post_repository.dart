import 'package:app/datasource/post/current_status_post_datasource.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
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
    return res.map((doc) => CurrentStatusPost.fromJson(doc.data()!)).toList();
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

  incrementLikeCountToReply(String postId, String replyId, int count) {
    return _datasource.incrementLikeCountToReply(postId, replyId, count);
  }
}
