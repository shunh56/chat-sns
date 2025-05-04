import 'package:cloud_firestore/cloud_firestore.dart';

class Topic {
  final String id;
  final String communityId;
  final String title;
  final String text;
  final String userId;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<String> tags;
  final int postCount;
  final int participantCount;
  final bool isActive;
  final bool isPro;

  Topic({
    required this.id,
    required this.communityId,
    required this.title,
    required this.text,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.postCount,
    required this.participantCount,
    required this.isActive,
    required this.isPro,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      userId: json['userId'] as String,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
      tags: List<String>.from(json['tags'] as List),
      postCount: json['postCount'] as int,
      participantCount: json['participantCount'] as int,
      isActive: json['isActive'] as bool,
      isPro: json['isPro'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'title': title,
      'text': text,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tags': tags,
      'postCount': postCount,
      'participantCount': participantCount,
      'isActive': isActive,
      'isPro': isPro,
    };
  }

  Topic copyWith({
    String? id,
    String? communityId,
    String? title,
    String? text,
    String? userId,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? tags,
    int? postCount,
    int? participantCount,
    bool? isActive,
    bool? isPro,
  }) {
    return Topic(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      title: title ?? this.title,
      text: text ?? this.text,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      postCount: postCount ?? this.postCount,
      participantCount: participantCount ?? this.participantCount,
      isActive: isActive ?? this.isActive,
      isPro: isPro ?? this.isPro,
    );
  }

  @override
  String toString() {
    return 'Topic(id: $id, title: $title, communityId: $communityId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topic &&
        other.id == id &&
        other.communityId == communityId &&
        other.title == title &&
        other.text == text &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.postCount == postCount &&
        other.participantCount == participantCount &&
        other.isActive == isActive &&
        other.isPro == isPro;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      communityId,
      title,
      text,
      userId,
      createdAt,
      updatedAt,
      Object.hashAll(tags),
      postCount,
      participantCount,
      isActive,
      isPro,
    );
  }
}