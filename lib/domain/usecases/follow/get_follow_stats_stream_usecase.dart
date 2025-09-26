/*import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/entity/follow/follow.dart';
import 'package:app/domain/repository_interface/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFollowStatsStreamUsecaseProvider = Provider(
  (ref) => GetFollowStatsStreamUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class GetFollowStatsStreamUseCase {
  final FollowRepository repository;

  GetFollowStatsStreamUseCase(this.repository);

  Stream<FollowStats> call(String userId) {
    return repository.followStatsStream(userId);
  }
}
 */
