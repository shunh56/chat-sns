import 'package:cloud_firestore/cloud_firestore.dart';

// type => "currentStatus", ""

abstract class CoreMessage {
  final String id;
  final Timestamp createdAt;
  final String text;
  final String senderId;

  CoreMessage({
    required this.id,
    required this.createdAt,
    required this.text,
    required this.senderId,
  });
}

class Message extends CoreMessage {
  Message({
    required super.id,
    required super.createdAt,
    required super.text,
    required super.senderId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"],
      createdAt: json["createdAt"],
      text: json["text"],
      senderId: json["senderId"],
    );
  }
}

class CurrentStatusMessage extends CoreMessage {
  final String userId;
  final String postId;
  CurrentStatusMessage({
    //
    required this.userId,
    required this.postId,
    //
    required super.id,
    required super.createdAt,
    required super.text,
    required super.senderId,
  });

  factory CurrentStatusMessage.fromJson(Map<String, dynamic> json) {
    return CurrentStatusMessage(
      //
      userId: json['userId'],
      postId: json['postId'],
      //
      id: json["id"],
      createdAt: json["createdAt"],
      text: json["text"],
      senderId: json["senderId"],
    );
  }
}
