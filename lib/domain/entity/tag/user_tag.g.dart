// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserTagImpl _$$UserTagImplFromJson(Map<String, dynamic> json) =>
    _$UserTagImpl(
      tagId: json['tagId'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      priority: (json['priority'] as num).toInt(),
      isSystemTag: json['isSystemTag'] as bool,
      showInTimeline: json['showInTimeline'] as bool,
      enableNotifications: json['enableNotifications'] as bool,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      userCount: (json['userCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserTagImplToJson(_$UserTagImpl instance) =>
    <String, dynamic>{
      'tagId': instance.tagId,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'priority': instance.priority,
      'isSystemTag': instance.isSystemTag,
      'showInTimeline': instance.showInTimeline,
      'enableNotifications': instance.enableNotifications,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'userCount': instance.userCount,
    };
