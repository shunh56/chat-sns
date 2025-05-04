import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/data/repository/posts/current_status_post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentStatusPostUsecaseProvider = Provider(
  (ref) => CurrentStatusPostUsecase(
    ref.watch(currentStatusPostRepositoryProvider),
  ),
);

class CurrentStatusPostUsecase {
  final CurrentStatusPostRepository _repository;

  CurrentStatusPostUsecase(this._repository);

  Future<CurrentStatusPost> getPost(String postId) async {
    return await _repository.getPost(postId);
  }

  /*Future<List<CurrentStatusPost>> getUsersNewestPost(String userId) async {
    return await _repository.getUsersNewestPost(userId);
  } */

  Future<List<CurrentStatusPost>> getUsersPosts(String userId) async {
    return await _repository.getUsersPosts(userId);
  }

  Future<List<CurrentStatusPost>> getPostFromUserIds(
      List<String> userIds) async {
    return await _repository.getPostFromUserIds(userIds);
  }

  addPost(Map<String, dynamic> before, Map<String, dynamic> after) {
    return _repository.addPost(before, after);
  }

  incrementLikeCount(String id, int count) {
    return _repository.incrementLikeCount(id, count);
  }

  readPost(CurrentStatusPost post) {
    return _repository.readPost(post.id);
  }

  addReply(String id, String text) {
    return _repository.addReply(id, text);
  }
}
