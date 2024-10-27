import 'package:app/domain/entity/posts/timeline_post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrentStatusPost extends PostBase {
  final CurrentStatus before;
  final CurrentStatus after;
  List<String> seenUserIds;

  CurrentStatusPost({
    required this.before,
    required this.after,
    required this.seenUserIds,
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

  factory CurrentStatusPost.fromJson(Map<String, dynamic> json) {
    return CurrentStatusPost(
      before: CurrentStatus.fromJson(json["before"]),
      after: CurrentStatus.fromJson(json["after"]),
      seenUserIds: List<String>.from(json["seenUserIds"] ?? []),
      //
      id: json["id"],
      userId: json["userId"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"] ?? json["createdAt"],
      likeCount: json["likeCount"] ?? 0,
      replyCount: json["replyCount"],
      isDeletedByUser: json["isDeletedByUser"] ?? false,
      isDeletedByAdmin: json["isDeletedByAdmin"] ?? false,
      isDeletedByModerator: json["isDeletedByModerator"] ?? false,
    );
  }

  bool get noNewChange {
    if (after.tags.where((tag) => !before.tags.contains(tag)).isNotEmpty ||
        after.tags.length != before.tags.length) {
      return false;
    }
    if (after.doing != before.doing && after.doing.isNotEmpty) {
      return false;
    }
    if (after.eating != before.eating && after.eating.isNotEmpty) {
      return false;
    }
    if (after.mood != before.mood && after.mood.isNotEmpty) {
      return false;
    }
    if (after.nowAt != before.nowAt && after.nowAt.isNotEmpty) {
      return false;
    }
    if (after.nextAt != before.nextAt && after.nextAt.isNotEmpty) {
      return false;
    }
    if (after.nowWith.where((id) => !before.nowWith.contains(id)).isNotEmpty) {
      return false;
    }
    return true;
  }

  bool get isHost {
    return userId == FirebaseAuth.instance.currentUser!.uid;
  }

  bool get isSeen {
    return seenUserIds.contains(FirebaseAuth.instance.currentUser!.uid);
  }
}
