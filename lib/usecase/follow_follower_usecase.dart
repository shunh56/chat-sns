import 'package:app/domain/entity/relation.dart';
import 'package:app/repository/follow_follower_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ffUsecaseProvider = Provider(
  (ref) => FFUsecase(
    ref.watch(ffRepositoryProvider),
  ),
);

class FFUsecase {
  final FFRepository _repository;

  FFUsecase(this._repository);

  Future<List<Relation>> getFollowings({String? userId}) async {
    return await _repository.getFollowings(userId: userId);
  }

  Future<List<Relation>> getFollowers({String? userId}) async {
    return await _repository.getFollowers(userId: userId);
  }

  followUser(String userId) {
    return _repository.followUser(userId);
  }

  unfollowUser(String userId) {
    return _repository.unfollowUser(userId);
  }
}
