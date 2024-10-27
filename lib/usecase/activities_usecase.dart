import 'package:app/Repository/activities_repository.dart';
import 'package:app/domain/entity/activities.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/repository/posts/current_status_post_repository.dart';
import 'package:app/repository/posts/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activitiesUsecaseProvider = Provider(
  (ref) => ActivitiesUsecase(
    ref.watch(activitiesRepositoryProvider),
    ref.watch(postRepositoryProvider),
    ref.watch(currentStatusPostRepositoryProvider),
  ),
);

class ActivitiesUsecase {
  final ActivitiesRepository _repository;
  final PostRepository _postRepository;
  final CurrentStatusPostRepository _currentStatusPostRepository;
  ActivitiesUsecase(
    this._repository,
    this._postRepository,
    this._currentStatusPostRepository,
  );

  Future<List<Activity>> getRecentActivities() async {
    final list = await _repository.getRecentActivities();
    for (var e in list) {
      if (e.actionType == ActionType.postLike ||
          e.actionType == ActionType.postComment) {
        final post = await _postRepository.getPost(e.refId);
        e.post = post;
      } else {
        final post = await _currentStatusPostRepository.getPost(e.refId);
        e.post = post;
      }
    }
    return list;
  }

  addLikeToPost(UserAccount user, Post post) async {
    return _repository.addLikeToPost(user.userId, post.id);
  }

  addCommentToPost(UserAccount user, Post post) async {
    return _repository.addCommentToPost(user.userId, post.id);
  }

  addLikeToCurrentStatusPost(UserAccount user, CurrentStatusPost post) async {
    return _repository.addLikeToCurrentStatusPost(user.userId, post.id);
  }
}
