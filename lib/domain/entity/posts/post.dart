import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String? text;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<String> mediaUrls;
  final List<double> aspectRatios;
  final List<String> hashtags;
  final List<String> mentions;
  final bool isPublic;
  int likeCount;
  int replyCount;
  bool isDeletedByUser;
  bool isDeletedByAdmin;
  bool isDeletedByModerator;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    this.text,
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
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      userId: json["userId"],
      title: json["title"] ?? "TITLE HERE",
      text: json["text"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"] ?? json["createdAt"],
      mediaUrls: List<String>.from(json["mediaUrls"] ?? []),
      aspectRatios: List<double>.from(json["aspectRatios"] ?? []),
      hashtags: List<String>.from(json["hashtags"] ?? []),
      mentions: List<String>.from(json["mentions"] ?? []),
      likeCount: json["likeCount"] ?? 0,
      replyCount: json["replyCount"] ?? 0,
      isDeletedByUser: json["isDeletedByUser"] ?? false,
      isDeletedByAdmin: json["isDeletedByAdmin"] ?? false,
      isDeletedByModerator: json["isDeletedByModerator"] ?? false,
      isPublic: json["isPublic"] ?? false,
    );
  }

  factory Post.fromAlgoliaJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      userId: json["userId"],
      title: json["title"] ?? "",
      text: json["text"],
      createdAt: Timestamp.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: json["updatedAt"] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['updatedAt'])
          : Timestamp.fromMillisecondsSinceEpoch(json['createdAt']),
      mediaUrls: List<String>.from(json["mediaUrls"] ?? []),
      aspectRatios: List<double>.from((json["aspectRatios"] as List?)
              ?.map((val) => val * 10 / 10.0)
              .toList() ??
          []),
      hashtags: List<String>.from(json["hashtags"] ?? []),
      mentions: List<String>.from(json["mentions"] ?? []),
      likeCount: json["likeCount"] ?? 0,
      replyCount: json["replyCount"] ?? 0,
      isDeletedByUser: json["isDeletedByUser"] ?? false,
      isDeletedByAdmin: json["isDeletedByAdmin"] ?? false,
      isDeletedByModerator: json["isDeletedByModerator"] ?? false,
      isPublic: json["isPublic"] ?? false,
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
    );
  }
}
