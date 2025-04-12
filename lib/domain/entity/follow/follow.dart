// lib/domain/entities/follow.dart

class Follow {
  final String userId;
  final String followerId;
  final DateTime createdAt;
  
  Follow({
    required this.userId,
    required this.followerId,
    required this.createdAt,
  });
}

// フォロー統計情報を扱うエンティティ
class FollowStats {
  final int followingCount;  // usersコレクションから取得
  final int followerCount;   // usersコレクションから取得
  final int followingCountLastDay;  // follow_stats_by_userコレクションから取得
  final int followingCountLastWeek; // follow_stats_by_userコレクションから取得
  final int followerCountLastDay;   // follow_stats_by_userコレクションから取得
  final int followerCountLastWeek;  // follow_stats_by_userコレクションから取得
  
  FollowStats({
    this.followingCount = 0,
    this.followerCount = 0,
    this.followingCountLastDay = 0,
    this.followingCountLastWeek = 0,
    this.followerCountLastDay = 0,
    this.followerCountLastWeek = 0,
  });

  FollowStats copyWith({
    int? followingCount,
    int? followerCount,
    int? followingCountLastDay,
    int? followingCountLastWeek,
    int? followerCountLastDay,
    int? followerCountLastWeek,
  }) {
    return FollowStats(
      followingCount: followingCount ?? this.followingCount,
      followerCount: followerCount ?? this.followerCount,
      followingCountLastDay: followingCountLastDay ?? this.followingCountLastDay,
      followingCountLastWeek: followingCountLastWeek ?? this.followingCountLastWeek,
      followerCountLastDay: followerCountLastDay ?? this.followerCountLastDay,
      followerCountLastWeek: followerCountLastWeek ?? this.followerCountLastWeek,
    );
  }
}

// フォローアクティビティの種類
enum FollowActivityType {
  follow,
  unfollow
}

// フォローアクティビティを表すエンティティ
class FollowActivity {
  final String id;
  final String fromUserId;
  final String toUserId;
  final FollowActivityType activityType;
  final DateTime createdAt;
  
  FollowActivity({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.activityType,
    required this.createdAt,
  });
}