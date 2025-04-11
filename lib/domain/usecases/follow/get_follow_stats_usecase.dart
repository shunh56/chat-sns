import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/entity/follow/follow.dart';
import 'package:app/domain/repositories/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFollowStatsUsecaseProvider = Provider(
  (ref) => GetFollowStatsUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class GetFollowStatsUseCase {
  final FollowRepository repository;

  GetFollowStatsUseCase(this.repository);

  Future<FollowStats> call(String userId) {
    return repository.getFollowStats(userId);
  }
}
