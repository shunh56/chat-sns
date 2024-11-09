// lib/models/community.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'community.freezed.dart';
part 'community.g.dart';

@freezed
class Community with _$Community {
  const factory Community({
    required String id,
    required String name,
    required String description,
    required String thumbnailImageUrl,
    required int memberCount,
    required int dailyActiveUsers,
    required int weeklyActiveUsers,
    required int monthlyActiveUsers,
    required int totalPosts,
    required int dailyPosts,
    required int topicsCount,
    required Timestamp createdAt,
    required Timestamp updatedAt,
    required List<String> rules,
    required List<String> moderators,
    int? dailyNewMembers,
    // info
  }) = _Community;

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);
}
