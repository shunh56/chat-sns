// lib/domain/entity/posts/post_reaction.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PostReaction {
  final String type; // 'love', 'fire', 'wow', 'clap', 'laugh', 'sad'
  final int count;
  final List<String> userIds; // リアクションしたユーザーのID
  final Timestamp? lastUpdated;

  PostReaction({
    required this.type,
    required this.count,
    required this.userIds,
    this.lastUpdated,
  });

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    return PostReaction(
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
      userIds: List<String>.from(json['userIds'] ?? []),
      lastUpdated: json['lastUpdated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'count': count,
      'userIds': userIds,
      'lastUpdated': lastUpdated ?? FieldValue.serverTimestamp(),
    };
  }

  PostReaction copyWith({
    String? type,
    int? count,
    List<String>? userIds,
    Timestamp? lastUpdated,
  }) {
    return PostReaction(
      type: type ?? this.type,
      count: count ?? this.count,
      userIds: userIds ?? this.userIds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // リアクション追加
  PostReaction addUser(String userId) {
    if (userIds.contains(userId)) return this;
    return copyWith(
      count: count + 1,
      userIds: [...userIds, userId],
      lastUpdated: Timestamp.now(),
    );
  }

  // リアクション削除
  PostReaction removeUser(String userId) {
    if (!userIds.contains(userId)) return this;
    final newUserIds = userIds.where((id) => id != userId).toList();
    return copyWith(
      count: newUserIds.length,
      userIds: newUserIds,
      lastUpdated: Timestamp.now(),
    );
  }
}

// リアクションタイプの定数
class ReactionType {
  static const String love = 'love';
  static const String fire = 'fire';
  static const String wow = 'wow';
  static const String clap = 'clap';
  static const String laugh = 'laugh';
  static const String sad = 'sad';

  static const List<String> allTypes = [love, fire, wow, clap, laugh, sad];

  static String getEmoji(String type) {
    switch (type) {
      case love:
        return '❤️';
      case fire:
        return '🔥';
      case wow:
        return '😍';
      case clap:
        return '👏';
      case laugh:
        return '😂';
      case sad:
        return '😢';
      default:
        return '❤️';
    }
  }

  static String getLabel(String type) {
    switch (type) {
      case love:
        return 'Love';
      case fire:
        return 'Fire';
      case wow:
        return 'Wow';
      case clap:
        return 'Clap';
      case laugh:
        return 'Laugh';
      case sad:
        return 'Sad';
      default:
        return 'Like';
    }
  }
}
