import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
class Topic with _$Topic {
  const factory Topic({
    required String id,
    required String communityId,
    required String title,
    required String userId,
    required Timestamp createdAt,
    required Timestamp updatedAt,

    //
    required List<String> tags,
    required int postCount,
    required int participantCount,
    required bool isActive,
    required bool isPro,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
}


/*  "id": "topic1",
          "title": "期末テスト2024",
          "participantCount": 567,
          "tags": ["#テスト対策", "#勉強"],
          "isPro": true,
          "lastActiveAt": "2024-03-15T10:30:00Z",
          //
          "name": "期末テスト2024",
          "subGenreId": "test_prep",
          "postCount": 567,
          "createdAt": "2024-03-01T00:00:00Z",
          "isActive": true */