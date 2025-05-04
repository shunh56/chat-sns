import 'package:app/domain/entity/follow/follow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// フォロー関係のFirestoreモデル
class FollowModel {
  final String userId;
  final DateTime createdAt;
  
  FollowModel({
    required this.userId,
    required this.createdAt,
  });
  
  factory FollowModel.fromFirestore(Map<String, dynamic> data) {
    // createdAtがFirestoreのTimestampの場合、DateTimeに変換
    final timestamp = data['createdAt'];
    final createdAt = timestamp is Timestamp 
        ? timestamp.toDate() 
        : DateTime.now();
    
    return FollowModel(
      userId: data['userId'] as String,
      createdAt: createdAt,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// フォロー統計情報のFirestoreモデル
class FollowStatsModel {
  final int followingCount;
  final int followerCount;
  final int followingCountLastDay;
  final int followingCountLastWeek;
  final int followerCountLastDay;
  final int followerCountLastWeek;
  
  FollowStatsModel({
    this.followingCount = 0,
    this.followerCount = 0,
    this.followingCountLastDay = 0,
    this.followingCountLastWeek = 0,
    this.followerCountLastDay = 0,
    this.followerCountLastWeek = 0,
  });
  
  factory FollowStatsModel.fromFirestore(Map<String, dynamic> data) {
    return FollowStatsModel(
      followingCount: data['followingCount'] ?? 0,
      followerCount: data['followerCount'] ?? 0,
      followingCountLastDay: data['followingCountLastDay'] ?? 0,
      followingCountLastWeek: data['followingCountLastWeek'] ?? 0,
      followerCountLastDay: data['followerCountLastDay'] ?? 0,
      followerCountLastWeek: data['followerCountLastWeek'] ?? 0,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'followingCount': followingCount,
      'followerCount': followerCount,
      'followingCountLastDay': followingCountLastDay,
      'followingCountLastWeek': followingCountLastWeek,
      'followerCountLastDay': followerCountLastDay,
      'followerCountLastWeek': followerCountLastWeek,
    };
  }
  
  FollowStats toDomain() {
    return FollowStats(
      followingCount: followingCount,
      followerCount: followerCount,
      followingCountLastDay: followingCountLastDay,
      followingCountLastWeek: followingCountLastWeek,
      followerCountLastDay: followerCountLastDay,
      followerCountLastWeek: followerCountLastWeek,
    );
  }
  
  factory FollowStatsModel.fromDomain(FollowStats stats) {
    return FollowStatsModel(
      followingCount: stats.followingCount,
      followerCount: stats.followerCount,
      followingCountLastDay: stats.followingCountLastDay,
      followingCountLastWeek: stats.followingCountLastWeek,
      followerCountLastDay: stats.followerCountLastDay,
      followerCountLastWeek: stats.followerCountLastWeek,
    );
  }
}

/// フォローアクティビティのFirestoreモデル
class FollowActivityModel {
  final String id;
  final String from;
  final String to;
  final String action;
  final DateTime createdAt;
  
  FollowActivityModel({
    required this.id,
    required this.from,
    required this.to,
    required this.action,
    required this.createdAt,
  });
  
  factory FollowActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['createdAt'];
    final createdAt = timestamp is Timestamp 
        ? timestamp.toDate() 
        : DateTime.now();
    
    return FollowActivityModel(
      id: doc.id,
      from: data['from'] as String,
      to: data['to'] as String,
      action: data['action'] as String,
      createdAt: createdAt,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'from': from,
      'to': to,
      'action': action,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  FollowActivity toDomain() {
    return FollowActivity(
      id: id,
      fromUserId: from,
      toUserId: to,
      activityType: action == 'follow' 
          ? FollowActivityType.follow 
          : FollowActivityType.unfollow,
      createdAt: createdAt,
    );
  }
  
  factory FollowActivityModel.fromDomain(FollowActivity activity) {
    return FollowActivityModel(
      id: activity.id,
      from: activity.fromUserId,
      to: activity.toUserId,
      action: activity.activityType == FollowActivityType.follow 
          ? 'follow' 
          : 'unfollow',
      createdAt: activity.createdAt,
    );
  }
}