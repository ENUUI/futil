// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../os_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OsVersion _$OsVersionFromJson(Map<String, dynamic> json) {
  return _OsVersion.fromJson(json);
}

/// @nodoc
mixin _$OsVersion {
  String get version => throw _privateConstructorUsedError;
  String get os => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OsVersionCopyWith<OsVersion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OsVersionCopyWith<$Res> {
  factory $OsVersionCopyWith(OsVersion value, $Res Function(OsVersion) then) =
      _$OsVersionCopyWithImpl<$Res, OsVersion>;
  @useResult
  $Res call({String version, String os});
}

/// @nodoc
class _$OsVersionCopyWithImpl<$Res, $Val extends OsVersion>
    implements $OsVersionCopyWith<$Res> {
  _$OsVersionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? os = null,
  }) {
    return _then(_value.copyWith(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      os: null == os
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OsVersionImplCopyWith<$Res>
    implements $OsVersionCopyWith<$Res> {
  factory _$$OsVersionImplCopyWith(
          _$OsVersionImpl value, $Res Function(_$OsVersionImpl) then) =
      __$$OsVersionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String version, String os});
}

/// @nodoc
class __$$OsVersionImplCopyWithImpl<$Res>
    extends _$OsVersionCopyWithImpl<$Res, _$OsVersionImpl>
    implements _$$OsVersionImplCopyWith<$Res> {
  __$$OsVersionImplCopyWithImpl(
      _$OsVersionImpl _value, $Res Function(_$OsVersionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? os = null,
  }) {
    return _then(_$OsVersionImpl(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      os: null == os
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$OsVersionImpl implements _OsVersion {
  _$OsVersionImpl({required this.version, required this.os});

  factory _$OsVersionImpl.fromJson(Map<String, dynamic> json) =>
      _$$OsVersionImplFromJson(json);

  @override
  final String version;
  @override
  final String os;

  @override
  String toString() {
    return 'OsVersion(version: $version, os: $os)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OsVersionImpl &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.os, os) || other.os == os));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, version, os);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OsVersionImplCopyWith<_$OsVersionImpl> get copyWith =>
      __$$OsVersionImplCopyWithImpl<_$OsVersionImpl>(this, _$identity);
}

abstract class _OsVersion implements OsVersion {
  factory _OsVersion(
      {required final String version,
      required final String os}) = _$OsVersionImpl;

  factory _OsVersion.fromJson(Map<String, dynamic> json) =
      _$OsVersionImpl.fromJson;

  @override
  String get version;
  @override
  String get os;
  @override
  @JsonKey(ignore: true)
  _$$OsVersionImplCopyWith<_$OsVersionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
