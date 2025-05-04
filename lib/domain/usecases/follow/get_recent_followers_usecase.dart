import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/repository_interface/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getRecentFollowersUsecaseProvider = Provider(
  (ref) => GetRecentFollowersUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class GetRecentFollowersUseCase {
  final FollowRepository repository;

  GetRecentFollowersUseCase(this.repository);

  Future<List<String>> call(String userId, {int limit = 10}) {
    return repository.getRecentFollowers(userId, limit: limit);
  }
}
