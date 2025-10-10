// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tagged_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaggedUserImpl _$$TaggedUserImplFromJson(Map<String, dynamic> json) =>
    _$TaggedUserImpl(
      userId: json['userId'] as String,
      targetId: json['targetId'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      memo: json['memo'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$TaggedUserImplToJson(_$TaggedUserImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'targetId': instance.targetId,
      'tags': instance.tags,
      'memo': instance.memo,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

_$TaggedUserDetailImpl _$$TaggedUserDetailImplFromJson(
        Map<String, dynamic> json) =>
    _$TaggedUserDetailImpl(
      taggedUser:
          TaggedUser.fromJson(json['taggedUser'] as Map<String, dynamic>),
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
    );

Map<String, dynamic> _$$TaggedUserDetailImplToJson(
        _$TaggedUserDetailImpl instance) =>
    <String, dynamic>{
      'taggedUser': instance.taggedUser,
      'displayName': instance.displayName,
      'profileImageUrl': instance.profileImageUrl,
      'bio': instance.bio,
    };
