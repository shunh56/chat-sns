import 'package:app/domain/entity/posts/timeline_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String refId;
  final ActionType actionType;
  final List<String> userIds;
  final Timestamp updatedAt;

  late final PostBase post;

  Activity({
    required this.id,
    required this.refId,
    required this.actionType,
    required this.userIds,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json["id"],
      refId: json["refId"],
      actionType: ActionTypeConverter.fromString(json["actionType"]),
      userIds: List<String>.from(json["userIds"]),
      updatedAt: json["updatedAt"],
    );
  }
}

enum ActionType {
  postLike, // => 〇〇があなたの投稿にいいねしました。
  postComment, // => 〇〇があなたの投稿にコメントしました
  currentStatusPostLike, // => 〇〇があなたのステータスにいいねしました。
  none,
}

class ActionTypeConverter {
  static ActionType fromString(String type) {
    switch (type) {
      case "postLike":
        return ActionType.postLike;
      case "postComment":
        return ActionType.postComment;
      case "currentStatusPostLike":
        return ActionType.currentStatusPostLike;
      default:
        return ActionType.none;
    }
  }
}





/// "docId" => "postId_like", "postId_comment"
/// 
/// "id": postId_like,
/// "ref" : postId,
/// "type" : "post_like", "post_comment", "currentStatusPost_like", 
/// "likedUsers": [],
/// "commentUsers": []
///  "updatedAt": dateTime,
/// 
