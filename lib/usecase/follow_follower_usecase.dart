/*// Project imports:
import 'package:app/repository/follow_follower_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ffUsecaseProvider = Provider(
  (ref) => FFUsecase(
    ref.watch(ffRepositoryProvider),
  ),
);

class FFUsecase {
  FFUsecase(this._repository);
  final FFRepository _repository;
  Future<List<String>> getFollowings({String? userId}) {
    return _repository.getFollowings(userId: userId);
  }

  Future<List<String>> getFollowers({String? userId}) {
    return _repository.getFollowers(userId: userId);
  }

  Stream<List<String>> streamFollowers() {
    return _repository.streamFollowers();
  }

  Future<void> followUser(String userId) {
    return _repository.followUser(userId);
  }

  Future<void> unfollowUser(String userId) {
    return _repository.unfollowUser(userId);
  }
}
 */