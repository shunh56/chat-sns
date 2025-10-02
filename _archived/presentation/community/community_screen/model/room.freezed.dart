// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  String get id => throw _privateConstructorUsedError;
  String get communityId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get currentParticipants => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  bool get isLive => throw _privateConstructorUsedError;
  List<String> get joinedUserIds => throw _privateConstructorUsedError;
  List<String>? get participantImageUrls => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call(
      {String id,
      String communityId,
      String title,
      String userId,
      int currentParticipants,
      int maxParticipants,
      DateTime createdAt,
      List<String> tags,
      bool isLive,
      List<String> joinedUserIds,
      List<String>? participantImageUrls});
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communityId = null,
    Object? title = null,
    Object? userId = null,
    Object? currentParticipants = null,
    Object? maxParticipants = null,
    Object? createdAt = null,
    Object? tags = null,
    Object? isLive = null,
    Object? joinedUserIds = null,
    Object? participantImageUrls = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      currentParticipants: null == currentParticipants
          ? _value.currentParticipants
          : currentParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLive: null == isLive
          ? _value.isLive
          : isLive // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedUserIds: null == joinedUserIds
          ? _value.joinedUserIds
          : joinedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantImageUrls: freezed == participantImageUrls
          ? _value.participantImageUrls
          : participantImageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
          _$RoomImpl value, $Res Function(_$RoomImpl) then) =
      __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String communityId,
      String title,
      String userId,
      int currentParticipants,
      int maxParticipants,
      DateTime createdAt,
      List<String> tags,
      bool isLive,
      List<String> joinedUserIds,
      List<String>? participantImageUrls});
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? communityId = null,
    Object? title = null,
    Object? userId = null,
    Object? currentParticipants = null,
    Object? maxParticipants = null,
    Object? createdAt = null,
    Object? tags = null,
    Object? isLive = null,
    Object? joinedUserIds = null,
    Object? participantImageUrls = freezed,
  }) {
    return _then(_$RoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      communityId: null == communityId
          ? _value.communityId
          : communityId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      currentParticipants: null == currentParticipants
          ? _value.currentParticipants
          : currentParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLive: null == isLive
          ? _value.isLive
          : isLive // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedUserIds: null == joinedUserIds
          ? _value._joinedUserIds
          : joinedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participantImageUrls: freezed == participantImageUrls
          ? _value._participantImageUrls
          : participantImageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomImpl implements _Room {
  const _$RoomImpl(
      {required this.id,
      required this.communityId,
      required this.title,
      required this.userId,
      required this.currentParticipants,
      required this.maxParticipants,
      required this.createdAt,
      required final List<String> tags,
      required this.isLive,
      required final List<String> joinedUserIds,
      final List<String>? participantImageUrls})
      : _tags = tags,
        _joinedUserIds = joinedUserIds,
        _participantImageUrls = participantImageUrls;

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  final String id;
  @override
  final String communityId;
  @override
  final String title;
  @override
  final String userId;
  @override
  final int currentParticipants;
  @override
  final int maxParticipants;
  @override
  final DateTime createdAt;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final bool isLive;
  final List<String> _joinedUserIds;
  @override
  List<String> get joinedUserIds {
    if (_joinedUserIds is EqualUnmodifiableListView) return _joinedUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_joinedUserIds);
  }

  final List<String>? _participantImageUrls;
  @override
  List<String>? get participantImageUrls {
    final value = _participantImageUrls;
    if (value == null) return null;
    if (_participantImageUrls is EqualUnmodifiableListView)
      return _participantImageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Room(id: $id, communityId: $communityId, title: $title, userId: $userId, currentParticipants: $currentParticipants, maxParticipants: $maxParticipants, createdAt: $createdAt, tags: $tags, isLive: $isLive, joinedUserIds: $joinedUserIds, participantImageUrls: $participantImageUrls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.communityId, communityId) ||
                other.communityId == communityId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.currentParticipants, currentParticipants) ||
                other.currentParticipants == currentParticipants) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isLive, isLive) || other.isLive == isLive) &&
            const DeepCollectionEquality()
                .equals(other._joinedUserIds, _joinedUserIds) &&
            const DeepCollectionEquality()
                .equals(other._participantImageUrls, _participantImageUrls));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      communityId,
      title,
      userId,
      currentParticipants,
      maxParticipants,
      createdAt,
      const DeepCollectionEquality().hash(_tags),
      isLive,
      const DeepCollectionEquality().hash(_joinedUserIds),
      const DeepCollectionEquality().hash(_participantImageUrls));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(
      this,
    );
  }
}

abstract class _Room implements Room {
  const factory _Room(
      {required final String id,
      required final String communityId,
      required final String title,
      required final String userId,
      required final int currentParticipants,
      required final int maxParticipants,
      required final DateTime createdAt,
      required final List<String> tags,
      required final bool isLive,
      required final List<String> joinedUserIds,
      final List<String>? participantImageUrls}) = _$RoomImpl;

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  String get id;
  @override
  String get communityId;
  @override
  String get title;
  @override
  String get userId;
  @override
  int get currentParticipants;
  @override
  int get maxParticipants;
  @override
  DateTime get createdAt;
  @override
  List<String> get tags;
  @override
  bool get isLive;
  @override
  List<String> get joinedUserIds;
  @override
  List<String>? get participantImageUrls;
  @override
  @JsonKey(ignore: true)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
