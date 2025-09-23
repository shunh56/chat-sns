// lib/domain/entity/posts/post.dart の修正
import 'package:app/domain/entity/posts/post_reaction.dart';
import 'package:app/domain/entity/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String text;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<String> mediaUrls;
  final List<double> aspectRatios;
  final List<String> hashtags;
  final List<String> mentions;
  final bool isPublic;
  int likeCount; // 後方互換性のため残す（全リアクションの合計）
  int replyCount;
  bool isDeletedByUser;
  bool isDeletedByAdmin;
  bool isDeletedByModerator;

  // 新しいリアクション機能
  final Map<String, PostReaction> reactions;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.mediaUrls,
    required this.aspectRatios,
    required this.hashtags,
    required this.mentions,
    required this.isPublic,
    required this.likeCount,
    required this.replyCount,
    required this.isDeletedByUser,
    required this.isDeletedByAdmin,
    required this.isDeletedByModerator,
    this.reactions = const {},
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    Map<String, PostReaction> reactionsMap = {};

    // リアクションデータの解析
    if (json['reactions'] != null) {
      final reactionsJson = json['reactions'] as Map<String, dynamic>;
      reactionsMap = reactionsJson.map(
        (key, value) => MapEntry(
          key,
          PostReaction.fromJson(Map<String, dynamic>.from(value)),
        ),
      );
    }

    return Post(
      id: json["id"],
      userId: json["userId"],
      title: json["title"] ?? "",
      text: json["text"] ?? "",
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"] ?? json["createdAt"],
      mediaUrls: List<String>.from(json["mediaUrls"] ?? []),
      aspectRatios: List<double>.from(json["aspectRatios"] ?? []),
      hashtags: List<String>.from(json["hashtags"] ?? []),
      mentions: List<String>.from(json["mentions"] ?? []),
      likeCount: json["likeCount"] ?? _calculateTotalLikes(reactionsMap),
      replyCount: json["replyCount"] ?? 0,
      isDeletedByUser: json["isDeletedByUser"] ?? false,
      isDeletedByAdmin: json["isDeletedByAdmin"] ?? false,
      isDeletedByModerator: json["isDeletedByModerator"] ?? false,
      isPublic: json["isPublic"] ?? false,
      reactions: reactionsMap,
    );
  }

  Map<String, dynamic> toJson() {
    final reactionsJson = reactions.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    return {
      'id': id,
      'userId': userId,
      'title': title,
      'text': text,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'mediaUrls': mediaUrls,
      'aspectRatios': aspectRatios,
      'hashtags': hashtags,
      'mentions': mentions,
      'isPublic': isPublic,
      'likeCount': getTotalReactionCount(),
      'replyCount': replyCount,
      'isDeletedByUser': isDeletedByUser,
      'isDeletedByAdmin': isDeletedByAdmin,
      'isDeletedByModerator': isDeletedByModerator,
      'reactions': reactionsJson,
    };
  }

  // ヘルパーメソッド
  int getTotalReactionCount() {
    return reactions.values
        .fold(0, (accumulator, reaction) => accumulator + reaction.count);
  }

  int getReactionCount(String type) {
    return reactions[type]?.count ?? 0;
  }

  bool hasUserReacted(String userId, String type) {
    return reactions[type]?.userIds.contains(userId) ?? false;
  }

  List<String> getUserReactionTypes(String userId) {
    return reactions.entries
        .where((entry) => entry.value.userIds.contains(userId))
        .map((entry) => entry.key)
        .toList();
  }

  Post addReaction(String userId, String type) {
    final newReactions = Map<String, PostReaction>.from(reactions);
    if (newReactions.containsKey(type)) {
      newReactions[type] = newReactions[type]!.addUser(userId);
    } else {
      newReactions[type] = PostReaction(
        type: type,
        count: 1,
        userIds: [userId],
        lastUpdated: Timestamp.now(),
      );
    }
    return copyWith(
      reactions: newReactions,
      likeCount: getTotalReactionCount() + 1,
    );
  }

  Post removeReaction(String userId, String type) {
    final newReactions = Map<String, PostReaction>.from(reactions);
    if (newReactions.containsKey(type)) {
      final updatedReaction = newReactions[type]!.removeUser(userId);
      if (updatedReaction.count > 0) {
        newReactions[type] = updatedReaction;
      } else {
        newReactions.remove(type);
      }
    }
    return copyWith(
      reactions: newReactions,
      likeCount: getTotalReactionCount() - 1,
    );
  }

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? text,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? mediaUrls,
    List<double>? aspectRatios,
    List<String>? hashtags,
    List<String>? mentions,
    bool? isPublic,
    int? likeCount,
    int? replyCount,
    bool? isDeletedByUser,
    bool? isDeletedByAdmin,
    bool? isDeletedByModerator,
    Map<String, PostReaction>? reactions,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      aspectRatios: aspectRatios ?? this.aspectRatios,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      isPublic: isPublic ?? this.isPublic,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isDeletedByUser: isDeletedByUser ?? this.isDeletedByUser,
      isDeletedByAdmin: isDeletedByAdmin ?? this.isDeletedByAdmin,
      isDeletedByModerator: isDeletedByModerator ?? this.isDeletedByModerator,
      reactions: reactions ?? this.reactions,
    );
  }

  static int _calculateTotalLikes(Map<String, PostReaction> reactions) {
    return reactions.values
        .fold(0, (accumulator, reaction) => accumulator + reaction.count);
  }

  bool isValidPost(UserAccount user) {
    if (user.accountStatus != AccountStatus.normal) return false;
    if (isDeletedByUser || isDeletedByModerator || isDeletedByAdmin) {
      return false;
    }
    return true;
  }
}
