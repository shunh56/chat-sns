import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/repositories/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkFollowingStatusUsecase = Provider(
  (ref) => CheckFollowingStatusUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class CheckFollowingStatusUseCase {
  final FollowRepository repository;

  CheckFollowingStatusUseCase(this.repository);

  Future<bool> call(String userId, String targetId) {
    return repository.isFollowing(userId, targetId);
  }
}
