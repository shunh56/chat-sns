// lib/domain/entities/story/story_action.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// ストーリーに対するアクションタイプを定義する列挙型
enum StoryActionType {
  view, // 閲覧
  like, // いいね
  share, // シェア
  save, // 保存
  comment, // コメント
  report, // 報告
  hide // 非表示
}

/// ストーリーに対するユーザーのアクションを記録するクラス
class StoryAction {
  final String id;
  final String storyId;
  final String userId;
  final StoryActionType actionType;
  final Timestamp createdAt;
  final Map<String, dynamic>? metadata; // アクションタイプ特有の追加データ

  const StoryAction({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.actionType,
    required this.createdAt,
    this.metadata,
  });

  // コピーメソッド
  StoryAction copyWith({
    String? id,
    String? storyId,
    String? userId,
    StoryActionType? actionType,
    Timestamp? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return StoryAction(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      userId: userId ?? this.userId,
      actionType: actionType ?? this.actionType,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // FromJson メソッド
  factory StoryAction.fromJson(Map<String, dynamic> json) {
    return StoryAction(
      id: json['id'] as String,
      storyId: json['storyId'] as String,
      userId: json['userId'] as String,
      actionType: _parseActionType(json['actionType'] as String),
      createdAt: json['createdAt'] as Timestamp,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // ToJson メソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'userId': userId,
      'actionType': actionType.toString().split('.').last,
      'createdAt': createdAt,
      'metadata': metadata,
    };
  }

  // アクションタイプを文字列からパースするヘルパーメソッド
  static StoryActionType _parseActionType(String value) {
    return StoryActionType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => StoryActionType.view,
    );
  }

  // ToString メソッド
  @override
  String toString() {
    return 'StoryAction(id: $id, storyId: $storyId, userId: $userId, '
        'actionType: $actionType, createdAt: $createdAt, metadata: $metadata)';
  }

  factory StoryAction.view({
    required String id,
    required String storyId,
    required String userId,
    required Timestamp createdAt,
  }) {
    return StoryAction(
      id: id,
      storyId: storyId,
      userId: userId,
      actionType: StoryActionType.view,
      createdAt: createdAt,
    );
  }
}
