import 'package:app/data/providers/follow_providers.dart';
import 'package:app/domain/repository_interface/follow_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFollowersStreamUsecaseProvider = Provider(
  (ref) => GetFollowersStreamUseCase(
    ref.watch(followRepositoryProvider),
  ),
);

/// フォロワーのリアルタイム監視ユースケース
class GetFollowersStreamUseCase {
  final FollowRepository repository;

  GetFollowersStreamUseCase(this.repository);

  Stream<List<String>> call(String userId) {
    return repository.getFollowersStream(userId);
  }
}
