// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VoiceRoom _$VoiceRoomFromJson(Map<String, dynamic> json) {
  return _VoiceRoom.fromJson(json);
}

/// @nodoc
mixin _$VoiceRoom {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get subGenreId => throw _privateConstructorUsedError;
  int get participantCount => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VoiceRoomCopyWith<VoiceRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceRoomCopyWith<$Res> {
  factory $VoiceRoomCopyWith(VoiceRoom value, $Res Function(VoiceRoom) then) =
      _$VoiceRoomCopyWithImpl<$Res, VoiceRoom>;
  @useResult
  $Res call(
      {String id,
      String name,
      String subGenreId,
      int participantCount,
      int maxParticipants,
      bool isActive,
      String description});
}

/// @nodoc
class _$VoiceRoomCopyWithImpl<$Res, $Val extends VoiceRoom>
    implements $VoiceRoomCopyWith<$Res> {
  _$VoiceRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? subGenreId = null,
    Object? participantCount = null,
    Object? maxParticipants = null,
    Object? isActive = null,
    Object? description = null,
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
      subGenreId: null == subGenreId
          ? _value.subGenreId
          : subGenreId // ignore: cast_nullable_to_non_nullable
              as String,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoiceRoomImplCopyWith<$Res>
    implements $VoiceRoomCopyWith<$Res> {
  factory _$$VoiceRoomImplCopyWith(
          _$VoiceRoomImpl value, $Res Function(_$VoiceRoomImpl) then) =
      __$$VoiceRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String subGenreId,
      int participantCount,
      int maxParticipants,
      bool isActive,
      String description});
}

/// @nodoc
class __$$VoiceRoomImplCopyWithImpl<$Res>
    extends _$VoiceRoomCopyWithImpl<$Res, _$VoiceRoomImpl>
    implements _$$VoiceRoomImplCopyWith<$Res> {
  __$$VoiceRoomImplCopyWithImpl(
      _$VoiceRoomImpl _value, $Res Function(_$VoiceRoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? subGenreId = null,
    Object? participantCount = null,
    Object? maxParticipants = null,
    Object? isActive = null,
    Object? description = null,
  }) {
    return _then(_$VoiceRoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      subGenreId: null == subGenreId
          ? _value.subGenreId
          : subGenreId // ignore: cast_nullable_to_non_nullable
              as String,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxParticipants: null == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceRoomImpl implements _VoiceRoom {
  const _$VoiceRoomImpl(
      {required this.id,
      required this.name,
      required this.subGenreId,
      required this.participantCount,
      required this.maxParticipants,
      required this.isActive,
      required this.description});

  factory _$VoiceRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceRoomImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String subGenreId;
  @override
  final int participantCount;
  @override
  final int maxParticipants;
  @override
  final bool isActive;
  @override
  final String description;

  @override
  String toString() {
    return 'VoiceRoom(id: $id, name: $name, subGenreId: $subGenreId, participantCount: $participantCount, maxParticipants: $maxParticipants, isActive: $isActive, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.subGenreId, subGenreId) ||
                other.subGenreId == subGenreId) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, subGenreId,
      participantCount, maxParticipants, isActive, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceRoomImplCopyWith<_$VoiceRoomImpl> get copyWith =>
      __$$VoiceRoomImplCopyWithImpl<_$VoiceRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceRoomImplToJson(
      this,
    );
  }
}

abstract class _VoiceRoom implements VoiceRoom {
  const factory _VoiceRoom(
      {required final String id,
      required final String name,
      required final String subGenreId,
      required final int participantCount,
      required final int maxParticipants,
      required final bool isActive,
      required final String description}) = _$VoiceRoomImpl;

  factory _VoiceRoom.fromJson(Map<String, dynamic> json) =
      _$VoiceRoomImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get subGenreId;
  @override
  int get participantCount;
  @override
  int get maxParticipants;
  @override
  bool get isActive;
  @override
  String get description;
  @override
  @JsonKey(ignore: true)
  _$$VoiceRoomImplCopyWith<_$VoiceRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
