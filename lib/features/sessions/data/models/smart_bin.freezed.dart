// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smart_bin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SmartBin _$SmartBinFromJson(Map<String, dynamic> json) {
  return _SmartBin.fromJson(json);
}

/// @nodoc
mixin _$SmartBin {
  int get id => throw _privateConstructorUsedError;
  String get deviceCode => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get district => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get totalCapsCollected => throw _privateConstructorUsedError;

  /// Serializes this SmartBin to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmartBin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmartBinCopyWith<SmartBin> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmartBinCopyWith<$Res> {
  factory $SmartBinCopyWith(SmartBin value, $Res Function(SmartBin) then) =
      _$SmartBinCopyWithImpl<$Res, SmartBin>;
  @useResult
  $Res call({
    int id,
    String deviceCode,
    String location,
    String district,
    String status,
    int totalCapsCollected,
  });
}

/// @nodoc
class _$SmartBinCopyWithImpl<$Res, $Val extends SmartBin>
    implements $SmartBinCopyWith<$Res> {
  _$SmartBinCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmartBin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceCode = null,
    Object? location = null,
    Object? district = null,
    Object? status = null,
    Object? totalCapsCollected = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            deviceCode:
                null == deviceCode
                    ? _value.deviceCode
                    : deviceCode // ignore: cast_nullable_to_non_nullable
                        as String,
            location:
                null == location
                    ? _value.location
                    : location // ignore: cast_nullable_to_non_nullable
                        as String,
            district:
                null == district
                    ? _value.district
                    : district // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            totalCapsCollected:
                null == totalCapsCollected
                    ? _value.totalCapsCollected
                    : totalCapsCollected // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SmartBinImplCopyWith<$Res>
    implements $SmartBinCopyWith<$Res> {
  factory _$$SmartBinImplCopyWith(
    _$SmartBinImpl value,
    $Res Function(_$SmartBinImpl) then,
  ) = __$$SmartBinImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String deviceCode,
    String location,
    String district,
    String status,
    int totalCapsCollected,
  });
}

/// @nodoc
class __$$SmartBinImplCopyWithImpl<$Res>
    extends _$SmartBinCopyWithImpl<$Res, _$SmartBinImpl>
    implements _$$SmartBinImplCopyWith<$Res> {
  __$$SmartBinImplCopyWithImpl(
    _$SmartBinImpl _value,
    $Res Function(_$SmartBinImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SmartBin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceCode = null,
    Object? location = null,
    Object? district = null,
    Object? status = null,
    Object? totalCapsCollected = null,
  }) {
    return _then(
      _$SmartBinImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        deviceCode:
            null == deviceCode
                ? _value.deviceCode
                : deviceCode // ignore: cast_nullable_to_non_nullable
                    as String,
        location:
            null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                    as String,
        district:
            null == district
                ? _value.district
                : district // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        totalCapsCollected:
            null == totalCapsCollected
                ? _value.totalCapsCollected
                : totalCapsCollected // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SmartBinImpl implements _SmartBin {
  const _$SmartBinImpl({
    required this.id,
    required this.deviceCode,
    required this.location,
    required this.district,
    required this.status,
    required this.totalCapsCollected,
  });

  factory _$SmartBinImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmartBinImplFromJson(json);

  @override
  final int id;
  @override
  final String deviceCode;
  @override
  final String location;
  @override
  final String district;
  @override
  final String status;
  @override
  final int totalCapsCollected;

  @override
  String toString() {
    return 'SmartBin(id: $id, deviceCode: $deviceCode, location: $location, district: $district, status: $status, totalCapsCollected: $totalCapsCollected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmartBinImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceCode, deviceCode) ||
                other.deviceCode == deviceCode) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalCapsCollected, totalCapsCollected) ||
                other.totalCapsCollected == totalCapsCollected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    deviceCode,
    location,
    district,
    status,
    totalCapsCollected,
  );

  /// Create a copy of SmartBin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmartBinImplCopyWith<_$SmartBinImpl> get copyWith =>
      __$$SmartBinImplCopyWithImpl<_$SmartBinImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmartBinImplToJson(this);
  }
}

abstract class _SmartBin implements SmartBin {
  const factory _SmartBin({
    required final int id,
    required final String deviceCode,
    required final String location,
    required final String district,
    required final String status,
    required final int totalCapsCollected,
  }) = _$SmartBinImpl;

  factory _SmartBin.fromJson(Map<String, dynamic> json) =
      _$SmartBinImpl.fromJson;

  @override
  int get id;
  @override
  String get deviceCode;
  @override
  String get location;
  @override
  String get district;
  @override
  String get status;
  @override
  int get totalCapsCollected;

  /// Create a copy of SmartBin
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmartBinImplCopyWith<_$SmartBinImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
