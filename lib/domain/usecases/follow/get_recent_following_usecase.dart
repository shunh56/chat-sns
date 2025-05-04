import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/repository_interface/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getRecentFollowingUsecaseProvider = Provider(
  (ref) => GetRecentFollowingUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

/// 最近フォローしたユーザーを取得するユースケース
class GetRecentFollowingUseCase {
  final FollowRepository repository;

  GetRecentFollowingUseCase(this.repository);

  Future<List<String>> call(String userId, {int limit = 10}) {
    return repository.getRecentFollowing(userId, limit: limit);
  }
}
