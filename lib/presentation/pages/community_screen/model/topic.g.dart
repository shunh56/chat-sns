// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicImpl _$$TopicImplFromJson(Map<String, dynamic> json) => _$TopicImpl(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      userId: json['userId'] as String,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      postCount: (json['postCount'] as num).toInt(),
      participantCount: (json['participantCount'] as num).toInt(),
      isActive: json['isActive'] as bool,
      isPro: json['isPro'] as bool,
    );

Map<String, dynamic> _$$TopicImplToJson(_$TopicImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'communityId': instance.communityId,
      'title': instance.title,
      'text': instance.text,
      'userId': instance.userId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'tags': instance.tags,
      'postCount': instance.postCount,
      'participantCount': instance.participantCount,
      'isActive': instance.isActive,
      'isPro': instance.isPro,
    };
