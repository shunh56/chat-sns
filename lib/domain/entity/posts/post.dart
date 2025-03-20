import 'package:app/domain/entity/posts/timeline_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post extends PostBase {
  final String text;
  final List<String> mediaUrls;
  final List<double> aspectRatios;
  final bool isPublic;

  Post({
    required this.text,
    required this.mediaUrls,
    required this.aspectRatios,
    required this.isPublic,
    //
    required super.id,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    required super.likeCount,
    required super.replyCount,
    required super.isDeletedByUser,
    required super.isDeletedByAdmin,
    required super.isDeletedByModerator,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      text: json["text"],
      mediaUrls: List<String>.from(json["mediaUrls"]),
      aspectRatios: List<double>.from(json["aspectRatios"]),
      //
      id: json["id"],
      userId: json["userId"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"] ?? json["createdAt"],
      likeCount: json["likeCount"] ?? 0,
      replyCount: json["replyCount"],
      isDeletedByUser: json["isDeletedByUser"],
      isDeletedByAdmin: json["isDeletedByAdmin"],
      isDeletedByModerator: json["isDeletedByModerator"],
      isPublic: json["isPublic"] ?? false,
    );
  }
  factory Post.fromAlgoliaJson(Map<String, dynamic> json) {
    return Post(
      text: json["text"],
      mediaUrls: List<String>.from(json["mediaUrls"]),
      aspectRatios: List<double>.from((json["aspectRatios"] as List)
          .map((val) => val * 10 / 10.0)
          .toList()),
      //
      id: json["id"],
      userId: json["userId"],
      createdAt: Timestamp.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: json["updatedAt"] != null
          ? Timestamp.fromMillisecondsSinceEpoch(json['updatedAt'])
          : Timestamp.fromMillisecondsSinceEpoch(json['createdAt']),
      likeCount: json["likeCount"] ?? 0,
      replyCount: json["replyCount"],
      isDeletedByUser: json["isDeletedByUser"],
      isDeletedByAdmin: json["isDeletedByAdmin"],
      isDeletedByModerator: json["isDeletedByModerator"],
      isPublic: json["isPublic"] ?? false,
    );
  }

  Post copyWith({
    int? likeCount,
    int? replyCount,
    bool? isDeletedByUser,
    bool? isDeletedByAdmin,
    bool? isDeletedByModerator,
  }) {
    return Post(
      text: text,
      mediaUrls: mediaUrls,
      aspectRatios: aspectRatios,
      //
      id: id,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isDeletedByUser: isDeletedByUser ?? this.isDeletedByUser,
      isDeletedByAdmin: isDeletedByAdmin ?? this.isDeletedByAdmin,
      isDeletedByModerator: isDeletedByModerator ?? this.isDeletedByModerator,
      isPublic: isPublic,
    );
  }
}
