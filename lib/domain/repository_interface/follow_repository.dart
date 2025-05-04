// lib/domain/repositories/follow_repository.dart


import 'package:app/domain/entity/follow/follow.dart';

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
  
  /// ユーザーのフォロー統計情報を取得
  Future<FollowStats> getFollowStats(String userId);
  
  /// 最近のフォローアクティビティを取得（一定期間内のフォロー/フォロー解除の履歴）
  Future<List<FollowActivity>> getRecentFollowActivities(String userId, {int limit = 20});

  /// ユーザーが最近フォローしたユーザーIDのリストを取得
  Future<List<String>> getRecentFollowing(String userId, {int limit = 10});
  
  /// ユーザーを最近フォローしたユーザーIDのリストを取得
  Future<List<String>> getRecentFollowers(String userId, {int limit = 10});
  
  /// フォロー統計のリアルタイム更新を監視するStream
  Stream<FollowStats> followStatsStream(String userId);
}