import 'package:app/core/utils/timestamp_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_tag.freezed.dart';
part 'user_tag.g.dart';

/// ユーザーが作成したタグ定義
/// users/{userId}/tags/{tagId}
@freezed
class UserTag with _$UserTag {
  const factory UserTag({
    required String tagId,
    required String name,
    required String icon, // Emoji
    required String color, // Color code (e.g., '#FFD700')
    required int priority, // 1-5
    required bool isSystemTag,
    required bool showInTimeline,
    required bool enableNotifications,
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
    @Default(0) int userCount, // このタグが付けられているユーザー数
  }) = _UserTag;

  factory UserTag.fromJson(Map<String, dynamic> json) =>
      _$UserTagFromJson(json);

  /// システムタグのプリセット
  static const systemTags = [
    {
      'tagId': 'oshi',
      'name': '推し',
      'icon': '✨',
      'color': '#9370DB',
      'priority': 5,
    },
    {
      'tagId': 'friend',
      'name': 'フレンド',
      'icon': '⭐',
      'color': '#FFD700',
      'priority': 4,
    },
    {
      'tagId': 'family',
      'name': '家族',
      'icon': '👨‍👩‍👧‍👦',
      'color': '#90EE90',
      'priority': 5,
    },
    {
      'tagId': 'work',
      'name': '仕事',
      'icon': '💼',
      'color': '#4682B4',
      'priority': 3,
    },
    {
      'tagId': 'watch_later',
      'name': '気になる',
      'icon': '👀',
      'color': '#87CEEB',
      'priority': 2,
    },
    {
      'tagId': 'skip',
      'name': 'スキップ',
      'icon': '🚫',
      'color': '#D3D3D3',
      'priority': 1,
    },
  ];

  /// システムタグを作成
  factory UserTag.systemTag(Map<String, dynamic> tagData) {
    final now = Timestamp.now();
    return UserTag(
      tagId: tagData['tagId'] as String,
      name: tagData['name'] as String,
      icon: tagData['icon'] as String,
      color: tagData['color'] as String,
      priority: tagData['priority'] as int,
      isSystemTag: true,
      showInTimeline: true,
      enableNotifications: true,
      createdAt: now,
      updatedAt: now,
      userCount: 0,
    );
  }

  /// カスタムタグを作成
  factory UserTag.custom({
    required String tagId,
    required String name,
    required String icon,
    required String color,
    required int priority,
  }) {
    final now = Timestamp.now();
    return UserTag(
      tagId: tagId,
      name: name,
      icon: icon,
      color: color,
      priority: priority,
      isSystemTag: false,
      showInTimeline: true,
      enableNotifications: false,
      createdAt: now,
      updatedAt: now,
      userCount: 0,
    );
  }
}
