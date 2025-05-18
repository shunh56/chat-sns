// lib/infrastructure/repositories/follow_repository_impl.dart
import 'package:app/domain/repository_interface/follow_repository.dart';
import 'package:app/data/datasource/follow_datasource.dart';

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
}
