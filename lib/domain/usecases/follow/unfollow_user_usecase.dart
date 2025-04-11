import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/repositories/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final unfollowUserUsecaseProvider = Provider(
  (ref) => UnfollowUserUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class UnfollowUserUseCase {
  final FollowRepository repository;

  UnfollowUserUseCase(this.repository);

  Future<void> call(String userId, String targetId) {
    return repository.unfollowUser(userId, targetId);
  }
}
