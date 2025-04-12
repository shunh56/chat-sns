// lib/infrastructure/repositories/follow_repository_impl.dart
import 'package:app/domain/entity/follow/follow.dart';
import 'package:app/domain/repositories/follow_repository.dart';
import 'package:app/infrastructure/datasource/follow_datasource.dart';

/// FollowRepositoryの実装クラス
class FollowRepositoryImpl implements FollowRepository {
  final FirestoreFollowDataSource _dataSource;

  FollowRepositoryImpl(this._dataSource);

  @override
  Future<void> followUser(String userId, String targetId) {
    return _dataSource.followUser(userId, targetId);
  }

  @override
  Future<void> unfollowUser(String userId, String targetId) {
    return _dataSource.unfollowUser(userId, targetId);
  }

  @override
  Future<List<String>> getFollowing(String userId) {
    return _dataSource.getFollowing(userId);
  }

  @override
  Future<List<String>> getFollowers(String userId) {
    return _dataSource.getFollowers(userId);
  }

  @override
  Stream<List<String>> getFollowersStream(String userId) {
    return _dataSource.getFollowersStream(userId);
  }

  @override
  Future<bool> isFollowing(String userId, String targetId) {
    return _dataSource.isFollowing(userId, targetId);
  }

  @override
  Future<FollowStats> getFollowStats(String userId) async {
    final statsModel = await _dataSource.getFollowStats(userId);
    return statsModel.toDomain();
  }

  @override
  Future<List<FollowActivity>> getRecentFollowActivities(String userId,
      {int limit = 20}) async {
    final activityModels =
        await _dataSource.getRecentFollowActivities(userId, limit: limit);
    return activityModels.map((model) => model.toDomain()).toList();
  }

  @override
  Future<List<String>> getRecentFollowing(String userId, {int limit = 10}) {
    return _dataSource.getRecentFollowing(userId, limit: limit);
  }

  @override
  Future<List<String>> getRecentFollowers(String userId, {int limit = 10}) {
    return _dataSource.getRecentFollowers(userId, limit: limit);
  }

  @override
  Stream<FollowStats> followStatsStream(String userId) {
    return _dataSource
        .followStatsStream(userId)
        .map((statsModel) => statsModel.toDomain());
  }
}
