// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
      id: json['id'] as String,
      communityId: json['communityId'] as String,
      title: json['title'] as String,
      userId: json['userId'] as String,
      currentParticipants: (json['currentParticipants'] as num).toInt(),
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isLive: json['isLive'] as bool,
      joinedUserIds: (json['joinedUserIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      participantImageUrls: (json['participantImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'communityId': instance.communityId,
      'title': instance.title,
      'userId': instance.userId,
      'currentParticipants': instance.currentParticipants,
      'maxParticipants': instance.maxParticipants,
      'createdAt': instance.createdAt.toIso8601String(),
      'tags': instance.tags,
      'isLive': instance.isLive,
      'joinedUserIds': instance.joinedUserIds,
      'participantImageUrls': instance.participantImageUrls,
    };
