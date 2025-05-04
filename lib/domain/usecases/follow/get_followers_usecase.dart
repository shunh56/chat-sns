import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/repository_interface/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFollowersUsecaseProvider = Provider(
  (ref) => GetFollowersUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class GetFollowersUseCase {
  final FollowRepository repository;

  GetFollowersUseCase(this.repository);

  Future<List<String>> call(String userId) {
    return repository.getFollowers(userId);
  }
}
