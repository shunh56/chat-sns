import 'package:app/data/repository/activities_repository.dart';
import 'package:app/domain/entity/activities.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/data/repository/posts/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activitiesUsecaseProvider = Provider(
  (ref) => ActivitiesUsecase(
    ref.watch(activitiesRepositoryProvider),
    ref.watch(postRepositoryProvider),
  ),
);

class ActivitiesUsecase {
  final ActivitiesRepository _repository;
  final PostRepository _postRepository;

  ActivitiesUsecase(
    this._repository,
    this._postRepository,
  );

  Stream<List<Activity>> streamActivity() {
    return _repository.streamActivity();
  }

  Future<List<Activity>> getRecentActivities() async {
    final list = await _repository.getRecentActivities();
    /*for (var e in list) {
      if (e.actionType == ActionType.postLike ||
          e.actionType == ActionType.postComment) {
        final post = await _postRepository.getPost(e.refId);
        e.post = post;
      } else {
        final post = await _currentStatusPostRepository.getPost(e.refId);
        e.post = post;
      }
    } */
    return list;
  }

  Future<void> readActivities() {
    return _repository.readActitivies();
  }

  addLikeToPost(UserAccount user, Post post) async {
    return _repository.addLikeToPost(user.userId, post.id);
  }

  addCommentToPost(UserAccount user, Post post) async {
    return _repository.addCommentToPost(user.userId, post.id);
  }
}
