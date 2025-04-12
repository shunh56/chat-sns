import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/repositories/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followUserUsecaseProvider = Provider(
  (ref) => FollowUserUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class FollowUserUseCase {
  final FollowRepository repository;

  FollowUserUseCase(this.repository);

  Future<void> call(String userId, String targetId) {
    return repository.followUser(userId, targetId);
  }
}
