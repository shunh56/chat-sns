import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum MessageType {
  text,
  image,
  voice,
}

class Message {
  final String id;
  final String userId;
  final MessageType type;
  final String text;
  final Map<String, dynamic> reactions;
  final Timestamp createdAt;
  final int? duration;
  final List<String>? imageUrls;
  final List<double>? aspectRatios;

  Message({
    required this.id,
    required this.userId,
    required this.type,
    required this.text,
    required this.reactions,
    required this.createdAt,
    this.duration,
    this.imageUrls,
    this.aspectRatios,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      //TODO
      userId:
          (json['userId'] ?? FirebaseAuth.instance.currentUser!.uid) as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      text: json['text'] ?? '',
      reactions: json['reactions'] as Map<String, dynamic>? ?? {},
      createdAt: json['createdAt'] as Timestamp,
      duration: json['duration'] as int?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      aspectRatios: (json['aspectRatios'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'text': text,
      'reactions': reactions,
      'createdAt': createdAt,
      if (duration != null) 'duration': duration,
      if (imageUrls != null) 'imageUrls': imageUrls,
      if (aspectRatios != null) 'aspectRatios': aspectRatios,
    };
  }

  // 画像メッセージかどうかを判定するヘルパーメソッド
  bool get hasImages => imageUrls != null && imageUrls!.isNotEmpty;
}
