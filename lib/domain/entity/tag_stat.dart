// lib/domain/entities/tag_stat.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TagInfo {
  final String id;
  final String text;
  final int count;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String imageUrl;

  TagInfo({
    required this.id,
    required this.text,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
  });

  factory TagInfo.fromJson(Map<String, dynamic> json) {
    return TagInfo(
      id: json['id'],
      text: json['text'] ?? "TAGNAME",
      count: json['count'] ?? 111,
      createdAt: json['createAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
      imageUrl: json['imageUrl'] ?? "https://i.pinimg.com/736x/d0/c0/f7/d0c0f7cf9fe0223de9b250f87fd61344.jpg",
    );
  }
}

// lib/domain/entities/tag_user.dart
class TagUser {
  final String userId;
  final Timestamp createdAt;
  final bool isActive;
  final Timestamp? updatedAt;

  TagUser({
    required this.userId,
    required this.createdAt,
    required this.isActive,
    this.updatedAt,
  });

  factory TagUser.fromJson( Map<String, dynamic> json) {
    return TagUser(
      userId: json['id'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }
}

// lib/domain/entities/tag_history.dart
class TagHistory {
  final int count;
  final Timestamp timestamp;

  TagHistory({
    required this.count,
    required this.timestamp,
  });
}
