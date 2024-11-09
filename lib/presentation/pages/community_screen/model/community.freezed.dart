// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Community _$CommunityFromJson(Map<String, dynamic> json) {
  return _Community.fromJson(json);
}

/// @nodoc
mixin _$Community {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get thumbnailImageUrl => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  int get dailyActiveUsers => throw _privateConstructorUsedError;
  int get weeklyActiveUsers => throw _privateConstructorUsedError;
  int get monthlyActiveUsers => throw _privateConstructorUsedError;
  int get totalPosts => throw _privateConstructorUsedError;
  int get dailyPosts => throw _privateConstructorUsedError;
  int get topicsCount => throw _privateConstructorUsedError;
  Timestamp get createdAt => throw _privateConstructorUsedError;
  Timestamp get updatedAt => throw _privateConstructorUsedError;
  List<String> get rules => throw _privateConstructorUsedError;
  List<String> get moderators => throw _privateConstructorUsedError;
  int? get dailyNewMembers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommunityCopyWith<Community> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityCopyWith<$Res> {
  factory $CommunityCopyWith(Community value, $Res Function(Community) then) =
      _$CommunityCopyWithImpl<$Res, Community>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String thumbnailImageUrl,
      int memberCount,
      int dailyActiveUsers,
      int weeklyActiveUsers,
      int monthlyActiveUsers,
      int totalPosts,
      int dailyPosts,
      int topicsCount,
      Timestamp createdAt,
      Timestamp updatedAt,
      List<String> rules,
      List<String> moderators,
      int? dailyNewMembers});
}

/// @nodoc
class _$CommunityCopyWithImpl<$Res, $Val extends Community>
    implements $CommunityCopyWith<$Res> {
  _$CommunityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? thumbnailImageUrl = null,
    Object? memberCount = null,
    Object? dailyActiveUsers = null,
    Object? weeklyActiveUsers = null,
    Object? monthlyActiveUsers = null,
    Object? totalPosts = null,
    Object? dailyPosts = null,
    Object? topicsCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? rules = null,
    Object? moderators = null,
    Object? dailyNewMembers = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailImageUrl: null == thumbnailImageUrl
          ? _value.thumbnailImageUrl
          : thumbnailImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      memberCount: null == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
      dailyActiveUsers: null == dailyActiveUsers
          ? _value.dailyActiveUsers
          : dailyActiveUsers // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyActiveUsers: null == weeklyActiveUsers
          ? _value.weeklyActiveUsers
          : weeklyActiveUsers // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyActiveUsers: null == monthlyActiveUsers
          ? _value.monthlyActiveUsers
          : monthlyActiveUsers // ignore: cast_nullable_to_non_nullable
              as int,
      totalPosts: null == totalPosts
          ? _value.totalPosts
          : totalPosts // ignore: cast_nullable_to_non_nullable
              as int,
      dailyPosts: null == dailyPosts
          ? _value.dailyPosts
          : dailyPosts // ignore: cast_nullable_to_non_nullable
              as int,
      topicsCount: null == topicsCount
          ? _value.topicsCount
          : topicsCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      rules: null == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      moderators: null == moderators
          ? _value.moderators
          : moderators // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dailyNewMembers: freezed == dailyNewMembers
          ? _value.dailyNewMembers
          : dailyNewMembers // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommunityImplCopyWith<$Res>
    implements $CommunityCopyWith<$Res> {
  factory _$$CommunityImplCopyWith(
          _$CommunityImpl value, $Res Function(_$CommunityImpl) then) =
      __$$CommunityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String thumbnailImageUrl,
      int memberCount,
      int dailyActiveUsers,
      int weeklyActiveUsers,
      int monthlyActiveUsers,
      int totalPosts,
      int dailyPosts,
      int topicsCount,
      Timestamp createdAt,
      Timestamp updatedAt,
      List<String> rules,
      List<String> moderators,
      int? dailyNewMembers});
}

/// @nodoc
class __$$CommunityImplCopyWithImpl<$Res>
    extends _$CommunityCopyWithImpl<$Res, _$CommunityImpl>
    implements _$$CommunityImplCopyWith<$Res> {
  __$$CommunityImplCopyWithImpl(
      _$CommunityImpl _value, $Res Function(_$CommunityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? thumbnailImageUrl = null,
    Object? memberCount = null,
    Object? dailyActiveUsers = null,
    Object? weeklyActiveUsers = null,
    Object? monthlyActiveUsers = null,
    Object? totalPosts = null,
    Object? dailyPosts = null,
    Object? topicsCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? rules = null,
    Object? moderators = null,
    Object? dailyNewMembers = freezed,
  }) {
    return _then(_$CommunityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailImageUrl: null == thumbnailImageUrl
          ? _value.thumbnailImageUrl
          : thumbnailImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      memberCount: null == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
      dailyActiveUsers: null == dailyActiveUsers
          ? _value.dailyActiveUsers
          : dailyActiveUsers // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyActiveUsers: null == weeklyActiveUsers
          ? _value.weeklyActiveUsers
          : weeklyActiveUsers // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyActiveUsers: null == monthlyActiveUsers
          ? _value.monthlyActiveUsers
          : monthlyActiveUsers // ignore: cast_nullable_to_non_nullable
              as int,
      totalPosts: null == totalPosts
          ? _value.totalPosts
          : totalPosts // ignore: cast_nullable_to_non_nullable
              as int,
      dailyPosts: null == dailyPosts
          ? _value.dailyPosts
          : dailyPosts // ignore: cast_nullable_to_non_nullable
              as int,
      topicsCount: null == topicsCount
          ? _value.topicsCount
          : topicsCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      rules: null == rules
          ? _value._rules
          : rules // ignore: cast_nullable_to_non_nullable
              as List<String>,
      moderators: null == moderators
          ? _value._moderators
          : moderators // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dailyNewMembers: freezed == dailyNewMembers
          ? _value.dailyNewMembers
          : dailyNewMembers // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommunityImpl implements _Community {
  const _$CommunityImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.thumbnailImageUrl,
      required this.memberCount,
      required this.dailyActiveUsers,
      required this.weeklyActiveUsers,
      required this.monthlyActiveUsers,
      required this.totalPosts,
      required this.dailyPosts,
      required this.topicsCount,
      required this.createdAt,
      required this.updatedAt,
      required final List<String> rules,
      required final List<String> moderators,
      this.dailyNewMembers})
      : _rules = rules,
        _moderators = moderators;

  factory _$CommunityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommunityImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String thumbnailImageUrl;
  @override
  final int memberCount;
  @override
  final int dailyActiveUsers;
  @override
  final int weeklyActiveUsers;
  @override
  final int monthlyActiveUsers;
  @override
  final int totalPosts;
  @override
  final int dailyPosts;
  @override
  final int topicsCount;
  @override
  final Timestamp createdAt;
  @override
  final Timestamp updatedAt;
  final List<String> _rules;
  @override
  List<String> get rules {
    if (_rules is EqualUnmodifiableListView) return _rules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rules);
  }

  final List<String> _moderators;
  @override
  List<String> get moderators {
    if (_moderators is EqualUnmodifiableListView) return _moderators;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moderators);
  }

  @override
  final int? dailyNewMembers;

  @override
  String toString() {
    return 'Community(id: $id, name: $name, description: $description, thumbnailImageUrl: $thumbnailImageUrl, memberCount: $memberCount, dailyActiveUsers: $dailyActiveUsers, weeklyActiveUsers: $weeklyActiveUsers, monthlyActiveUsers: $monthlyActiveUsers, totalPosts: $totalPosts, dailyPosts: $dailyPosts, topicsCount: $topicsCount, createdAt: $createdAt, updatedAt: $updatedAt, rules: $rules, moderators: $moderators, dailyNewMembers: $dailyNewMembers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.thumbnailImageUrl, thumbnailImageUrl) ||
                other.thumbnailImageUrl == thumbnailImageUrl) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.dailyActiveUsers, dailyActiveUsers) ||
                other.dailyActiveUsers == dailyActiveUsers) &&
            (identical(other.weeklyActiveUsers, weeklyActiveUsers) ||
                other.weeklyActiveUsers == weeklyActiveUsers) &&
            (identical(other.monthlyActiveUsers, monthlyActiveUsers) ||
                other.monthlyActiveUsers == monthlyActiveUsers) &&
            (identical(other.totalPosts, totalPosts) ||
                other.totalPosts == totalPosts) &&
            (identical(other.dailyPosts, dailyPosts) ||
                other.dailyPosts == dailyPosts) &&
            (identical(other.topicsCount, topicsCount) ||
                other.topicsCount == topicsCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._rules, _rules) &&
            const DeepCollectionEquality()
                .equals(other._moderators, _moderators) &&
            (identical(other.dailyNewMembers, dailyNewMembers) ||
                other.dailyNewMembers == dailyNewMembers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      thumbnailImageUrl,
      memberCount,
      dailyActiveUsers,
      weeklyActiveUsers,
      monthlyActiveUsers,
      totalPosts,
      dailyPosts,
      topicsCount,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_rules),
      const DeepCollectionEquality().hash(_moderators),
      dailyNewMembers);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityImplCopyWith<_$CommunityImpl> get copyWith =>
      __$$CommunityImplCopyWithImpl<_$CommunityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommunityImplToJson(
      this,
    );
  }
}

abstract class _Community implements Community {
  const factory _Community(
      {required final String id,
      required final String name,
      required final String description,
      required final String thumbnailImageUrl,
      required final int memberCount,
      required final int dailyActiveUsers,
      required final int weeklyActiveUsers,
      required final int monthlyActiveUsers,
      required final int totalPosts,
      required final int dailyPosts,
      required final int topicsCount,
      required final Timestamp createdAt,
      required final Timestamp updatedAt,
      required final List<String> rules,
      required final List<String> moderators,
      final int? dailyNewMembers}) = _$CommunityImpl;

  factory _Community.fromJson(Map<String, dynamic> json) =
      _$CommunityImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get thumbnailImageUrl;
  @override
  int get memberCount;
  @override
  int get dailyActiveUsers;
  @override
  int get weeklyActiveUsers;
  @override
  int get monthlyActiveUsers;
  @override
  int get totalPosts;
  @override
  int get dailyPosts;
  @override
  int get topicsCount;
  @override
  Timestamp get createdAt;
  @override
  Timestamp get updatedAt;
  @override
  List<String> get rules;
  @override
  List<String> get moderators;
  @override
  int? get dailyNewMembers;
  @override
  @JsonKey(ignore: true)
  _$$CommunityImplCopyWith<_$CommunityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
