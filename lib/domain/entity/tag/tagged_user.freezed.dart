// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tagged_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaggedUser _$TaggedUserFromJson(Map<String, dynamic> json) {
  return _TaggedUser.fromJson(json);
}

/// @nodoc
mixin _$TaggedUser {
  String get userId => throw _privateConstructorUsedError; // タグを付けた人
  String get targetId => throw _privateConstructorUsedError; // タグ付けされた人
  List<String> get tags => throw _privateConstructorUsedError; // タグIDのリスト (複数可)
  String? get memo => throw _privateConstructorUsedError; // プライベートメモ
  @TimestampConverter()
  Timestamp get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  Timestamp get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TaggedUserCopyWith<TaggedUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaggedUserCopyWith<$Res> {
  factory $TaggedUserCopyWith(
          TaggedUser value, $Res Function(TaggedUser) then) =
      _$TaggedUserCopyWithImpl<$Res, TaggedUser>;
  @useResult
  $Res call(
      {String userId,
      String targetId,
      List<String> tags,
      String? memo,
      @TimestampConverter() Timestamp createdAt,
      @TimestampConverter() Timestamp updatedAt});
}

/// @nodoc
class _$TaggedUserCopyWithImpl<$Res, $Val extends TaggedUser>
    implements $TaggedUserCopyWith<$Res> {
  _$TaggedUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? targetId = null,
    Object? tags = null,
    Object? memo = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      targetId: null == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaggedUserImplCopyWith<$Res>
    implements $TaggedUserCopyWith<$Res> {
  factory _$$TaggedUserImplCopyWith(
          _$TaggedUserImpl value, $Res Function(_$TaggedUserImpl) then) =
      __$$TaggedUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String targetId,
      List<String> tags,
      String? memo,
      @TimestampConverter() Timestamp createdAt,
      @TimestampConverter() Timestamp updatedAt});
}

/// @nodoc
class __$$TaggedUserImplCopyWithImpl<$Res>
    extends _$TaggedUserCopyWithImpl<$Res, _$TaggedUserImpl>
    implements _$$TaggedUserImplCopyWith<$Res> {
  __$$TaggedUserImplCopyWithImpl(
      _$TaggedUserImpl _value, $Res Function(_$TaggedUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? targetId = null,
    Object? tags = null,
    Object? memo = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TaggedUserImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      targetId: null == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      memo: freezed == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as Timestamp,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaggedUserImpl implements _TaggedUser {
  const _$TaggedUserImpl(
      {required this.userId,
      required this.targetId,
      required final List<String> tags,
      this.memo,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : _tags = tags;

  factory _$TaggedUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaggedUserImplFromJson(json);

  @override
  final String userId;
// タグを付けた人
  @override
  final String targetId;
// タグ付けされた人
  final List<String> _tags;
// タグ付けされた人
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

// タグIDのリスト (複数可)
  @override
  final String? memo;
// プライベートメモ
  @override
  @TimestampConverter()
  final Timestamp createdAt;
  @override
  @TimestampConverter()
  final Timestamp updatedAt;

  @override
  String toString() {
    return 'TaggedUser(userId: $userId, targetId: $targetId, tags: $tags, memo: $memo, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaggedUserImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, targetId,
      const DeepCollectionEquality().hash(_tags), memo, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaggedUserImplCopyWith<_$TaggedUserImpl> get copyWith =>
      __$$TaggedUserImplCopyWithImpl<_$TaggedUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaggedUserImplToJson(
      this,
    );
  }
}

abstract class _TaggedUser implements TaggedUser {
  const factory _TaggedUser(
          {required final String userId,
          required final String targetId,
          required final List<String> tags,
          final String? memo,
          @TimestampConverter() required final Timestamp createdAt,
          @TimestampConverter() required final Timestamp updatedAt}) =
      _$TaggedUserImpl;

  factory _TaggedUser.fromJson(Map<String, dynamic> json) =
      _$TaggedUserImpl.fromJson;

  @override
  String get userId;
  @override // タグを付けた人
  String get targetId;
  @override // タグ付けされた人
  List<String> get tags;
  @override // タグIDのリスト (複数可)
  String? get memo;
  @override // プライベートメモ
  @TimestampConverter()
  Timestamp get createdAt;
  @override
  @TimestampConverter()
  Timestamp get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TaggedUserImplCopyWith<_$TaggedUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaggedUserDetail _$TaggedUserDetailFromJson(Map<String, dynamic> json) {
  return _TaggedUserDetail.fromJson(json);
}

/// @nodoc
mixin _$TaggedUserDetail {
  TaggedUser get taggedUser => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TaggedUserDetailCopyWith<TaggedUserDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaggedUserDetailCopyWith<$Res> {
  factory $TaggedUserDetailCopyWith(
          TaggedUserDetail value, $Res Function(TaggedUserDetail) then) =
      _$TaggedUserDetailCopyWithImpl<$Res, TaggedUserDetail>;
  @useResult
  $Res call(
      {TaggedUser taggedUser,
      String displayName,
      String? profileImageUrl,
      String? bio});

  $TaggedUserCopyWith<$Res> get taggedUser;
}

/// @nodoc
class _$TaggedUserDetailCopyWithImpl<$Res, $Val extends TaggedUserDetail>
    implements $TaggedUserDetailCopyWith<$Res> {
  _$TaggedUserDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taggedUser = null,
    Object? displayName = null,
    Object? profileImageUrl = freezed,
    Object? bio = freezed,
  }) {
    return _then(_value.copyWith(
      taggedUser: null == taggedUser
          ? _value.taggedUser
          : taggedUser // ignore: cast_nullable_to_non_nullable
              as TaggedUser,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TaggedUserCopyWith<$Res> get taggedUser {
    return $TaggedUserCopyWith<$Res>(_value.taggedUser, (value) {
      return _then(_value.copyWith(taggedUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaggedUserDetailImplCopyWith<$Res>
    implements $TaggedUserDetailCopyWith<$Res> {
  factory _$$TaggedUserDetailImplCopyWith(_$TaggedUserDetailImpl value,
          $Res Function(_$TaggedUserDetailImpl) then) =
      __$$TaggedUserDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TaggedUser taggedUser,
      String displayName,
      String? profileImageUrl,
      String? bio});

  @override
  $TaggedUserCopyWith<$Res> get taggedUser;
}

/// @nodoc
class __$$TaggedUserDetailImplCopyWithImpl<$Res>
    extends _$TaggedUserDetailCopyWithImpl<$Res, _$TaggedUserDetailImpl>
    implements _$$TaggedUserDetailImplCopyWith<$Res> {
  __$$TaggedUserDetailImplCopyWithImpl(_$TaggedUserDetailImpl _value,
      $Res Function(_$TaggedUserDetailImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taggedUser = null,
    Object? displayName = null,
    Object? profileImageUrl = freezed,
    Object? bio = freezed,
  }) {
    return _then(_$TaggedUserDetailImpl(
      taggedUser: null == taggedUser
          ? _value.taggedUser
          : taggedUser // ignore: cast_nullable_to_non_nullable
              as TaggedUser,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaggedUserDetailImpl implements _TaggedUserDetail {
  const _$TaggedUserDetailImpl(
      {required this.taggedUser,
      required this.displayName,
      required this.profileImageUrl,
      required this.bio});

  factory _$TaggedUserDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaggedUserDetailImplFromJson(json);

  @override
  final TaggedUser taggedUser;
  @override
  final String displayName;
  @override
  final String? profileImageUrl;
  @override
  final String? bio;

  @override
  String toString() {
    return 'TaggedUserDetail(taggedUser: $taggedUser, displayName: $displayName, profileImageUrl: $profileImageUrl, bio: $bio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaggedUserDetailImpl &&
            (identical(other.taggedUser, taggedUser) ||
                other.taggedUser == taggedUser) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.bio, bio) || other.bio == bio));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, taggedUser, displayName, profileImageUrl, bio);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaggedUserDetailImplCopyWith<_$TaggedUserDetailImpl> get copyWith =>
      __$$TaggedUserDetailImplCopyWithImpl<_$TaggedUserDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaggedUserDetailImplToJson(
      this,
    );
  }
}

abstract class _TaggedUserDetail implements TaggedUserDetail {
  const factory _TaggedUserDetail(
      {required final TaggedUser taggedUser,
      required final String displayName,
      required final String? profileImageUrl,
      required final String? bio}) = _$TaggedUserDetailImpl;

  factory _TaggedUserDetail.fromJson(Map<String, dynamic> json) =
      _$TaggedUserDetailImpl.fromJson;

  @override
  TaggedUser get taggedUser;
  @override
  String get displayName;
  @override
  String? get profileImageUrl;
  @override
  String? get bio;
  @override
  @JsonKey(ignore: true)
  _$$TaggedUserDetailImplCopyWith<_$TaggedUserDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
