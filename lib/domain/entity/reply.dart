import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String id;
  final String userId;
  final Timestamp createdAt;
  final String text;
  int likeCount;

  bool isDeletedByUser;
  bool isDeletedByAdmin;
  bool isDeletedByModerator;

  Reply({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.text,
    required this.likeCount,
    required this.isDeletedByUser,
    required this.isDeletedByAdmin,
    required this.isDeletedByModerator,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json["id"],
      userId: json["userId"],
      createdAt: json["createdAt"],
      text: json["text"],
      likeCount: json["likeCount"],
      isDeletedByUser: json["isDeletedByUser"] ?? false,
      isDeletedByAdmin: json["isDeletedByAdmin"] ?? false,
      isDeletedByModerator: json["isDeletedByModerator"] ?? false,
    );
  }
}
