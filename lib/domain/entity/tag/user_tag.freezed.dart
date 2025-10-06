// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserTag _$UserTagFromJson(Map<String, dynamic> json) {
  return _UserTag.fromJson(json);
}

/// @nodoc
mixin _$UserTag {
  String get tagId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError; // Emoji
  String get color =>
      throw _privateConstructorUsedError; // Color code (e.g., '#FFD700')
  int get priority => throw _privateConstructorUsedError; // 1-5
  bool get isSystemTag => throw _privateConstructorUsedError;
  bool get showInTimeline => throw _privateConstructorUsedError;
  bool get enableNotifications => throw _privateConstructorUsedError;
  @TimestampConverter()
  Timestamp get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  Timestamp get updatedAt => throw _privateConstructorUsedError;
  int get userCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserTagCopyWith<UserTag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserTagCopyWith<$Res> {
  factory $UserTagCopyWith(UserTag value, $Res Function(UserTag) then) =
      _$UserTagCopyWithImpl<$Res, UserTag>;
  @useResult
  $Res call(
      {String tagId,
      String name,
      String icon,
      String color,
      int priority,
      bool isSystemTag,
      bool showInTimeline,
      bool enableNotifications,
      @TimestampConverter() Timestamp createdAt,
      @TimestampConverter() Timestamp updatedAt,
      int userCount});
}

/// @nodoc
class _$UserTagCopyWithImpl<$Res, $Val extends UserTag>
    implements $UserTagCopyWith<$Res> {
  _$UserTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagId = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? priority = null,
    Object? isSystemTag = null,
    Object? showInTimeline = null,
    Object? enableNotifications = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userCount = null,
  }) {
    return _then(_value.copyWith(
      tagId: null == tagId
          ? _value.tagId
          : tagId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      isSystemTag: null == isSystemTag
          ? _value.isSystemTag
          : isSystemTag // ignore: cast_nullable_to_non_nullable
              as bool,
      showInTimeline: null == showInTimeline
          ? _value.showInTimeline
          : showInTimeline // ignore: cast_nullable_to_non_nullable
              as bool,
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      userCount: null == userCount
          ? _value.userCount
          : userCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserTagImplCopyWith<$Res> implements $UserTagCopyWith<$Res> {
  factory _$$UserTagImplCopyWith(
          _$UserTagImpl value, $Res Function(_$UserTagImpl) then) =
      __$$UserTagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tagId,
      String name,
      String icon,
      String color,
      int priority,
      bool isSystemTag,
      bool showInTimeline,
      bool enableNotifications,
      @TimestampConverter() Timestamp createdAt,
      @TimestampConverter() Timestamp updatedAt,
      int userCount});
}

/// @nodoc
class __$$UserTagImplCopyWithImpl<$Res>
    extends _$UserTagCopyWithImpl<$Res, _$UserTagImpl>
    implements _$$UserTagImplCopyWith<$Res> {
  __$$UserTagImplCopyWithImpl(
      _$UserTagImpl _value, $Res Function(_$UserTagImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tagId = null,
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? priority = null,
    Object? isSystemTag = null,
    Object? showInTimeline = null,
    Object? enableNotifications = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userCount = null,
  }) {
    return _then(_$UserTagImpl(
      tagId: null == tagId
          ? _value.tagId
          : tagId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      isSystemTag: null == isSystemTag
          ? _value.isSystemTag
          : isSystemTag // ignore: cast_nullable_to_non_nullable
              as bool,
      showInTimeline: null == showInTimeline
          ? _value.showInTimeline
          : showInTimeline // ignore: cast_nullable_to_non_nullable
              as bool,
      enableNotifications: null == enableNotifications
          ? _value.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      userCount: null == userCount
          ? _value.userCount
          : userCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserTagImpl implements _UserTag {
  const _$UserTagImpl(
      {required this.tagId,
      required this.name,
      required this.icon,
      required this.color,
      required this.priority,
      required this.isSystemTag,
      required this.showInTimeline,
      required this.enableNotifications,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt,
      this.userCount = 0});

  factory _$UserTagImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserTagImplFromJson(json);

  @override
  final String tagId;
  @override
  final String name;
  @override
  final String icon;
// Emoji
  @override
  final String color;
// Color code (e.g., '#FFD700')
  @override
  final int priority;
// 1-5
  @override
  final bool isSystemTag;
  @override
  final bool showInTimeline;
  @override
  final bool enableNotifications;
  @override
  @TimestampConverter()
  final Timestamp createdAt;
  @override
  @TimestampConverter()
  final Timestamp updatedAt;
  @override
  @JsonKey()
  final int userCount;

  @override
  String toString() {
    return 'UserTag(tagId: $tagId, name: $name, icon: $icon, color: $color, priority: $priority, isSystemTag: $isSystemTag, showInTimeline: $showInTimeline, enableNotifications: $enableNotifications, createdAt: $createdAt, updatedAt: $updatedAt, userCount: $userCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserTagImpl &&
            (identical(other.tagId, tagId) || other.tagId == tagId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.isSystemTag, isSystemTag) ||
                other.isSystemTag == isSystemTag) &&
            (identical(other.showInTimeline, showInTimeline) ||
                other.showInTimeline == showInTimeline) &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userCount, userCount) ||
                other.userCount == userCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tagId,
      name,
      icon,
      color,
      priority,
      isSystemTag,
      showInTimeline,
      enableNotifications,
      createdAt,
      updatedAt,
      userCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserTagImplCopyWith<_$UserTagImpl> get copyWith =>
      __$$UserTagImplCopyWithImpl<_$UserTagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserTagImplToJson(
      this,
    );
  }
}

abstract class _UserTag implements UserTag {
  const factory _UserTag(
      {required final String tagId,
      required final String name,
      required final String icon,
      required final String color,
      required final int priority,
      required final bool isSystemTag,
      required final bool showInTimeline,
      required final bool enableNotifications,
      @TimestampConverter() required final Timestamp createdAt,
      @TimestampConverter() required final Timestamp updatedAt,
      final int userCount}) = _$UserTagImpl;

  factory _UserTag.fromJson(Map<String, dynamic> json) = _$UserTagImpl.fromJson;

  @override
  String get tagId;
  @override
  String get name;
  @override
  String get icon;
  @override // Emoji
  String get color;
  @override // Color code (e.g., '#FFD700')
  int get priority;
  @override // 1-5
  bool get isSystemTag;
  @override
  bool get showInTimeline;
  @override
  bool get enableNotifications;
  @override
  @TimestampConverter()
  Timestamp get createdAt;
  @override
  @TimestampConverter()
  Timestamp get updatedAt;
  @override
  int get userCount;
  @override
  @JsonKey(ignore: true)
  _$$UserTagImplCopyWith<_$UserTagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
