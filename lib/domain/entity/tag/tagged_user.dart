import 'package:app/core/utils/timestamp_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tagged_user.freezed.dart';
part 'tagged_user.g.dart';

/// タグ付けされたユーザー
/// user_tags/{userId}/tagged_users/{targetId}
@freezed
class TaggedUser with _$TaggedUser {
  const factory TaggedUser({
    required String userId, // タグを付けた人
    required String targetId, // タグ付けされた人
    required List<String> tags, // タグIDのリスト (複数可)
    String? memo, // プライベートメモ
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
  }) = _TaggedUser;

  factory TaggedUser.fromJson(Map<String, dynamic> json) =>
      _$TaggedUserFromJson(json);

  /// 新規作成
  factory TaggedUser.create({
    required String userId,
    required String targetId,
    required List<String> tags,
    String? memo,
  }) {
    final now = Timestamp.now();
    return TaggedUser(
      userId: userId,
      targetId: targetId,
      tags: tags,
      memo: memo,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// タグ付けされたユーザーの詳細情報
/// (TaggedUser + User情報を結合したもの)
@freezed
class TaggedUserDetail with _$TaggedUserDetail {
  const factory TaggedUserDetail({
    required TaggedUser taggedUser,
    required String displayName,
    required String? profileImageUrl,
    required String? bio,
  }) = _TaggedUserDetail;

  factory TaggedUserDetail.fromJson(Map<String, dynamic> json) =>
      _$TaggedUserDetailFromJson(json);
}
