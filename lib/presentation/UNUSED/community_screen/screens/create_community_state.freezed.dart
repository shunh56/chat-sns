// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_community_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CreateCommunityState {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  File? get thumbnailFile =>
      throw _privateConstructorUsedError; // FileをNullableで管理
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CreateCommunityStateCopyWith<CreateCommunityState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateCommunityStateCopyWith<$Res> {
  factory $CreateCommunityStateCopyWith(CreateCommunityState value,
          $Res Function(CreateCommunityState) then) =
      _$CreateCommunityStateCopyWithImpl<$Res, CreateCommunityState>;
  @useResult
  $Res call(
      {String name,
      String description,
      List<String> tags,
      File? thumbnailFile,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$CreateCommunityStateCopyWithImpl<$Res,
        $Val extends CreateCommunityState>
    implements $CreateCommunityStateCopyWith<$Res> {
  _$CreateCommunityStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? tags = null,
    Object? thumbnailFile = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      thumbnailFile: freezed == thumbnailFile
          ? _value.thumbnailFile
          : thumbnailFile // ignore: cast_nullable_to_non_nullable
              as File?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateCommunityStateImplCopyWith<$Res>
    implements $CreateCommunityStateCopyWith<$Res> {
  factory _$$CreateCommunityStateImplCopyWith(_$CreateCommunityStateImpl value,
          $Res Function(_$CreateCommunityStateImpl) then) =
      __$$CreateCommunityStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String description,
      List<String> tags,
      File? thumbnailFile,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$CreateCommunityStateImplCopyWithImpl<$Res>
    extends _$CreateCommunityStateCopyWithImpl<$Res, _$CreateCommunityStateImpl>
    implements _$$CreateCommunityStateImplCopyWith<$Res> {
  __$$CreateCommunityStateImplCopyWithImpl(_$CreateCommunityStateImpl _value,
      $Res Function(_$CreateCommunityStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? tags = null,
    Object? thumbnailFile = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$CreateCommunityStateImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      thumbnailFile: freezed == thumbnailFile
          ? _value.thumbnailFile
          : thumbnailFile // ignore: cast_nullable_to_non_nullable
              as File?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CreateCommunityStateImpl implements _CreateCommunityState {
  const _$CreateCommunityStateImpl(
      {this.name = '',
      this.description = '',
      final List<String> tags = const [],
      this.thumbnailFile,
      this.isLoading = false,
      this.error})
      : _tags = tags;

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final File? thumbnailFile;
// FileをNullableで管理
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'CreateCommunityState(name: $name, description: $description, tags: $tags, thumbnailFile: $thumbnailFile, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateCommunityStateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.thumbnailFile, thumbnailFile) ||
                other.thumbnailFile == thumbnailFile) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      description,
      const DeepCollectionEquality().hash(_tags),
      thumbnailFile,
      isLoading,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateCommunityStateImplCopyWith<_$CreateCommunityStateImpl>
      get copyWith =>
          __$$CreateCommunityStateImplCopyWithImpl<_$CreateCommunityStateImpl>(
              this, _$identity);
}

abstract class _CreateCommunityState implements CreateCommunityState {
  const factory _CreateCommunityState(
      {final String name,
      final String description,
      final List<String> tags,
      final File? thumbnailFile,
      final bool isLoading,
      final String? error}) = _$CreateCommunityStateImpl;

  @override
  String get name;
  @override
  String get description;
  @override
  List<String> get tags;
  @override
  File? get thumbnailFile;
  @override // FileをNullableで管理
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$CreateCommunityStateImplCopyWith<_$CreateCommunityStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
