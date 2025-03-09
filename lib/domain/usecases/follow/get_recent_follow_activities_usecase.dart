/*import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/entity/follow/follow.dart';
import 'package:app/domain/repository_interface/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getRecentFollowActivitiesUsecaseProvider = Provider(
  (ref) => GetRecentFollowActivitiesUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class GetRecentFollowActivitiesUseCase {
  final FollowRepository repository;

  GetRecentFollowActivitiesUseCase(this.repository);

  Future<List<FollowActivity>> call(String userId, {int limit = 20}) {
    return repository.getRecentFollowActivities(userId, limit: limit);
  }
}
 */