import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/repositories/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFollowingUsecaseProvider = Provider(
  (ref) => GetFollowingUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class GetFollowingUseCase {
  final FollowRepository repository;

  GetFollowingUseCase(this.repository);

  Future<List<String>> call(String userId) {
    return repository.getFollowing(userId);
  }
}
