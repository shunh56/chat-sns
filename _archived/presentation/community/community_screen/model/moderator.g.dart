// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModeratorImpl _$$ModeratorImplFromJson(Map<String, dynamic> json) =>
    _$ModeratorImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$ModeratorImplToJson(_$ModeratorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'role': instance.role,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
