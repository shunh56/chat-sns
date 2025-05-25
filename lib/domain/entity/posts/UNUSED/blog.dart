/*import 'package:app/domain/entity/posts/UNUSED/timeline_post.dart';

class Blog extends PostBase {
  final String title;
  final List<dynamic> contents;

  Blog({
    required this.title,
    required this.contents,
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

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      title: json["title"],
      contents: List<dynamic>.from(json["contents"]),
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
    );
  }
}
 */