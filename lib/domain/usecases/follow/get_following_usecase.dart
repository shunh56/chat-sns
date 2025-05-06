import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/repository_interface/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFollowingUsecaseProvider = Provider(
  (ref) => GetFollowingUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

class GetFollowingUseCase {
  final FollowRepository repository;

  GetFollowingUseCase(this.repository);

  Future<List<String>> call(String userId) async {
    final list = await repository.getFollowing(userId);
    list.removeWhere((id) => id == userId);
    return list;
  }
}
