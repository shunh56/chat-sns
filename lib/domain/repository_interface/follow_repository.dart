// lib/domain/repositories/follow_repository.dart

/// フォロー関連のリポジトリインターフェース
abstract class FollowRepository {
  /// ユーザーをフォローする
  Future<void> followUser(String userId, String targetId);

  /// ユーザーのフォローを解除する
  Future<void> unfollowUser(String userId, String targetId);

  /// 指定したユーザーがフォローしているユーザーIDのリストを取得
  Future<List<String>> getFollowing(String userId);

  /// 指定したユーザーのフォロワーIDのリストを取得
  Future<List<String>> getFollowers(String userId);

  /// 指定したユーザーのフォロワーを監視するStream
  Stream<List<String>> getFollowersStream(String userId);

  /// ユーザーがターゲットをフォローしているかどうかを確認
  Future<bool> isFollowing(String userId, String targetId);
}
