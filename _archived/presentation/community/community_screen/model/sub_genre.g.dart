// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_genre.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubGenreImpl _$$SubGenreImplFromJson(Map<String, dynamic> json) =>
    _$SubGenreImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      color: json['color'] as String,
      postCount: (json['postCount'] as num).toInt(),
      dailyPostCount: (json['dailyPostCount'] as num).toInt(),
      memberCount: (json['memberCount'] as num).toInt(),
      activeTopics: (json['activeTopics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$$SubGenreImplToJson(_$SubGenreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'color': instance.color,
      'postCount': instance.postCount,
      'dailyPostCount': instance.dailyPostCount,
      'memberCount': instance.memberCount,
      'activeTopics': instance.activeTopics,
      'order': instance.order,
    };
