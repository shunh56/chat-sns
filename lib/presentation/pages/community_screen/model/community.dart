import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String thumbnailImageUrl;
  final int memberCount;
  final int dailyActiveUsers;
  final int weeklyActiveUsers;
  final int monthlyActiveUsers;
  final int totalPosts;
  final int dailyPosts;
  final int topicsCount;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<String> rules;
  final List<String> moderators;
  final int? dailyNewMembers;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailImageUrl,
    required this.memberCount,
    required this.dailyActiveUsers,
    required this.weeklyActiveUsers,
    required this.monthlyActiveUsers,
    required this.totalPosts,
    required this.dailyPosts,
    required this.topicsCount,
    required this.createdAt,
    required this.updatedAt,
    required this.rules,
    required this.moderators,
    this.dailyNewMembers,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      thumbnailImageUrl: json['thumbnailImageUrl'] as String,
      memberCount: json['memberCount'] as int,
      dailyActiveUsers: json['dailyActiveUsers'] as int,
      weeklyActiveUsers: json['weeklyActiveUsers'] as int,
      monthlyActiveUsers: json['monthlyActiveUsers'] as int,
      totalPosts: json['totalPosts'] as int,
      dailyPosts: json['dailyPosts'] as int,
      topicsCount: json['topicsCount'] as int,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
      rules: List<String>.from(json['rules'] as List),
      moderators: List<String>.from(json['moderators'] as List),
      dailyNewMembers: json['dailyNewMembers'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnailImageUrl': thumbnailImageUrl,
      'memberCount': memberCount,
      'dailyActiveUsers': dailyActiveUsers,
      'weeklyActiveUsers': weeklyActiveUsers,
      'monthlyActiveUsers': monthlyActiveUsers,
      'totalPosts': totalPosts,
      'dailyPosts': dailyPosts,
      'topicsCount': topicsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'rules': rules,
      'moderators': moderators,
      'dailyNewMembers': dailyNewMembers,
    };
  }

  // データのコピーを作成するメソッド
  Community copyWith({
    String? id,
    String? name,
    String? description,
    String? thumbnailImageUrl,
    int? memberCount,
    int? dailyActiveUsers,
    int? weeklyActiveUsers,
    int? monthlyActiveUsers,
    int? totalPosts,
    int? dailyPosts,
    int? topicsCount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? rules,
    List<String>? moderators,
    int? dailyNewMembers,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      memberCount: memberCount ?? this.memberCount,
      dailyActiveUsers: dailyActiveUsers ?? this.dailyActiveUsers,
      weeklyActiveUsers: weeklyActiveUsers ?? this.weeklyActiveUsers,
      monthlyActiveUsers: monthlyActiveUsers ?? this.monthlyActiveUsers,
      totalPosts: totalPosts ?? this.totalPosts,
      dailyPosts: dailyPosts ?? this.dailyPosts,
      topicsCount: topicsCount ?? this.topicsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rules: rules ?? this.rules,
      moderators: moderators ?? this.moderators,
      dailyNewMembers: dailyNewMembers ?? this.dailyNewMembers,
    );
  }

  // toString()メソッドのオーバーライド（デバッグ用）
  @override
  String toString() {
    return 'Community(id: $id, name: $name, memberCount: $memberCount)';
  }

  // equals演算子のオーバーライド
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Community &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.thumbnailImageUrl == thumbnailImageUrl &&
        other.memberCount == memberCount &&
        other.dailyActiveUsers == dailyActiveUsers &&
        other.weeklyActiveUsers == weeklyActiveUsers &&
        other.monthlyActiveUsers == monthlyActiveUsers &&
        other.totalPosts == totalPosts &&
        other.dailyPosts == dailyPosts &&
        other.topicsCount == topicsCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.dailyNewMembers == dailyNewMembers;
  }

  // hashCodeのオーバーライド
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        thumbnailImageUrl.hashCode ^
        memberCount.hashCode ^
        dailyActiveUsers.hashCode ^
        weeklyActiveUsers.hashCode ^
        monthlyActiveUsers.hashCode ^
        totalPosts.hashCode ^
        dailyPosts.hashCode ^
        topicsCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        dailyNewMembers.hashCode;
  }
}