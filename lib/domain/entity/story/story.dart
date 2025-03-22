// lib/domain/entities/story/story.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryVisibility {
  public,
  followers,
  closeFriends,
}

enum StoryMediaType {
  image,
  video,
}

class Story {
  final String id;
  final String userId;
  final String mediaUrl;
  final String? caption;
  final StoryMediaType mediaType;
  final StoryVisibility visibility;
  final Timestamp createdAt;
  final Timestamp expiresAt;
  final int viewCount;
  final bool isHighlighted;
  final List<String> tags;
  final String? location;
  final bool isSensitiveContent;
  final int likeCount;

  const Story({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    this.caption,
    required this.mediaType,
    required this.visibility,
    required this.createdAt,
    required this.expiresAt,
    this.viewCount = 0,
    this.isHighlighted = false,
    this.tags = const [],
    this.location,
    this.isSensitiveContent = false,
    this.likeCount = 0,
  });

  bool get isExpired => Timestamp.now().compareTo(expiresAt) > 0;

  // copyWith メソッド
  Story copyWith({
    String? id,
    String? userId,
    String? mediaUrl,
    String? caption,
    StoryMediaType? mediaType,
    StoryVisibility? visibility,
    Timestamp? createdAt,
    Timestamp? expiresAt,
    int? viewCount,
    bool? isHighlighted,
    List<String>? tags,
    String? location,
    bool? isSensitiveContent,
    int? likeCount,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      mediaType: mediaType ?? this.mediaType,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      isSensitiveContent: isSensitiveContent ?? this.isSensitiveContent,
      likeCount: likeCount ?? this.likeCount,
    );
  }

  // fromJson メソッド
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      userId: json['userId'] as String,
      mediaUrl: json['mediaUrl'] as String,
      caption: json['caption'] as String?,
      mediaType: _parseMediaType(json['mediaType'] as String),
      visibility: _parseVisibility(json['visibility'] as String),
      createdAt: json['createdAt'] as Timestamp,
      expiresAt: json['expiresAt'] as Timestamp,
      viewCount: json['viewCount'] as int? ?? 0,
      isHighlighted: json['isHighlighted'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      location: json['location'] as String?,
      isSensitiveContent: json['isSensitiveContent'] as bool? ?? false,
      likeCount: json['likeCount'] as int? ?? 0,
    );
  }

  // toJson メソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'mediaType': mediaType.toString().split('.').last,
      'visibility': visibility.toString().split('.').last,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'viewCount': viewCount,
      'isHighlighted': isHighlighted,
      'tags': tags,
      'location': location,
      'isSensitiveContent': isSensitiveContent,
      'likeCount': likeCount,
    };
  }

  // Firestore変換メソッド
  factory Story.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Story(
      id: doc.id,
      userId: data['userId'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      caption: data['caption'],
      mediaType: _parseMediaType(data['mediaType'] ?? 'image'),
      visibility: _parseVisibility(data['visibility'] ?? 'public'),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      expiresAt: data['expiresAt'] ?? Timestamp.now(),
      viewCount: data['viewCount'] ?? 0,
      isHighlighted: data['isHighlighted'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      location: data['location'],
      isSensitiveContent: data['isSensitiveContent'] ?? false,
      likeCount: data['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'mediaType': mediaType.toString().split('.').last,
      'visibility': visibility.toString().split('.').last,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'viewCount': viewCount,
      'isHighlighted': isHighlighted,
      'tags': tags,
      'location': location,
      'isSensitiveContent': isSensitiveContent,
      'likeCount': likeCount,
    };
  }

  // toString メソッド
  @override
  String toString() {
    return 'Story(id: $id, userId: $userId, caption: $caption, mediaType: $mediaType, '
        'visibility: $visibility, createdAt: $createdAt, expiresAt: $expiresAt, '
        'viewCount: $viewCount, isHighlighted: $isHighlighted, tags: $tags, '
        'location: $location, isSensitiveContent: $isSensitiveContent, likeCount: $likeCount)';
  }

  // ヘルパーメソッド
  static StoryMediaType _parseMediaType(String value) {
    return StoryMediaType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => StoryMediaType.image,
    );
  }

  static StoryVisibility _parseVisibility(String value) {
    return StoryVisibility.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => StoryVisibility.public,
    );
  }
}
