// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoiceRoomImpl _$$VoiceRoomImplFromJson(Map<String, dynamic> json) =>
    _$VoiceRoomImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      subGenreId: json['subGenreId'] as String,
      participantCount: (json['participantCount'] as num).toInt(),
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      isActive: json['isActive'] as bool,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$VoiceRoomImplToJson(_$VoiceRoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subGenreId': instance.subGenreId,
      'participantCount': instance.participantCount,
      'maxParticipants': instance.maxParticipants,
      'isActive': instance.isActive,
      'description': instance.description,
    };
