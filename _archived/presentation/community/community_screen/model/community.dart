import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String thumbnailImageUrl;
  final int memberCount;
  final int messageCount;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<String> moderators;
  final String userId;
  final List<String> tags;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailImageUrl,
    required this.memberCount,
    required this.messageCount,
    required this.createdAt,
    required this.updatedAt,
    required this.moderators,
    required this.userId,
    required this.tags,
  }) {
    // データの整合性チェック
    if (id.isEmpty) throw ArgumentError('id cannot be empty');
    if (name.isEmpty) throw ArgumentError('name cannot be empty');
    if (description.isEmpty) throw ArgumentError('description cannot be empty');
    if (thumbnailImageUrl.isEmpty) {
      throw ArgumentError('thumbnailImageUrl cannot be empty');
    }
    if (memberCount < 0) throw ArgumentError('memberCount cannot be negative');
    if (messageCount < 0) {
      throw ArgumentError('messageCount cannot be negative');
    }
    if (moderators.isEmpty) {
      throw ArgumentError('moderators list cannot be empty');
    }
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
  }

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailImageUrl: json['thumbnailImageUrl'] as String? ?? '',
      memberCount: json['memberCount'] as int? ?? 0,
      messageCount: json['messageCount'] as int? ?? 0,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: json['updatedAt'] as Timestamp? ?? Timestamp.now(),
      moderators: (json['moderators'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      userId: json['userId'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnailImageUrl': thumbnailImageUrl,
      'memberCount': memberCount,
      'messageCount': messageCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'moderators': moderators,
      'userId': userId,
      'tags': tags,
    };
  }

  Community copyWith({
    String? id,
    String? name,
    String? description,
    String? thumbnailImageUrl,
    int? memberCount,
    int? messageCount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? moderators,
    String? userId,
    List<String>? tags,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      memberCount: memberCount ?? this.memberCount,
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moderators: moderators ?? List.from(this.moderators),
      userId: userId ?? this.userId,
      tags: tags ?? List.from(this.tags),
    );
  }

  @override
  String toString() {
    return 'Community{'
        'id: $id, '
        'name: $name, '
        'description: $description, '
        'thumbnailImageUrl: $thumbnailImageUrl, '
        'memberCount: $memberCount, '
        'messageCount: $messageCount, '
        'createdAt: ${createdAt.toDate()}, '
        'updatedAt: ${updatedAt.toDate()}, '
        'moderators: $moderators, '
        'userId: $userId, '
        'tags: $tags'
        '}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Community &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.thumbnailImageUrl == thumbnailImageUrl &&
        other.memberCount == memberCount &&
        other.messageCount == messageCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEquals(other.moderators, moderators) &&
        other.userId == userId &&
        listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      thumbnailImageUrl,
      memberCount,
      messageCount,
      createdAt,
      updatedAt,
      Object.hashAll(moderators),
      userId,
      Object.hashAll(tags),
    );
  }
}
