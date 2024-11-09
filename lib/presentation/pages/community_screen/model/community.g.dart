// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityImpl _$$CommunityImplFromJson(Map<String, dynamic> json) =>
    _$CommunityImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      thumbnailImageUrl: json['thumbnailImageUrl'] as String,
      description: json['description'] as String,
      memberCount: (json['memberCount'] as num).toInt(),
      dailyActiveUsers: (json['dailyActiveUsers'] as num).toInt(),
      weeklyActiveUsers: (json['weeklyActiveUsers'] as num).toInt(),
      monthlyActiveUsers: (json['monthlyActiveUsers'] as num).toInt(),
      totalPosts: (json['totalPosts'] as num).toInt(),
      dailyPosts: (json['dailyPosts'] as num).toInt(),
      topicsCount: (json['topicsCount'] as num).toInt(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      rules: (json['rules'] as List<dynamic>).map((e) => e as String).toList(),
      moderators: (json['moderators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dailyNewMembers: (json['dailyNewMembers'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CommunityImplToJson(_$CommunityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'memberCount': instance.memberCount,
      'dailyActiveUsers': instance.dailyActiveUsers,
      'weeklyActiveUsers': instance.weeklyActiveUsers,
      'monthlyActiveUsers': instance.monthlyActiveUsers,
      'totalPosts': instance.totalPosts,
      'dailyPosts': instance.dailyPosts,
      'topicsCount': instance.topicsCount,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'dailyNewMembers': instance.dailyNewMembers,
      'description': instance.description,
      'rules': instance.rules,
      'moderators': instance.moderators,
    };
