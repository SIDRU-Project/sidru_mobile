// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'redeem_reward_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RedeemRewardRequest _$RedeemRewardRequestFromJson(Map<String, dynamic> json) {
  return _RedeemRewardRequest.fromJson(json);
}

/// @nodoc
mixin _$RedeemRewardRequest {
  int get rewardId => throw _privateConstructorUsedError;

  /// Serializes this RedeemRewardRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedeemRewardRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedeemRewardRequestCopyWith<RedeemRewardRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedeemRewardRequestCopyWith<$Res> {
  factory $RedeemRewardRequestCopyWith(
    RedeemRewardRequest value,
    $Res Function(RedeemRewardRequest) then,
  ) = _$RedeemRewardRequestCopyWithImpl<$Res, RedeemRewardRequest>;
  @useResult
  $Res call({int rewardId});
}

/// @nodoc
class _$RedeemRewardRequestCopyWithImpl<$Res, $Val extends RedeemRewardRequest>
    implements $RedeemRewardRequestCopyWith<$Res> {
  _$RedeemRewardRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedeemRewardRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rewardId = null}) {
    return _then(
      _value.copyWith(
            rewardId:
                null == rewardId
                    ? _value.rewardId
                    : rewardId // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RedeemRewardRequestImplCopyWith<$Res>
    implements $RedeemRewardRequestCopyWith<$Res> {
  factory _$$RedeemRewardRequestImplCopyWith(
    _$RedeemRewardRequestImpl value,
    $Res Function(_$RedeemRewardRequestImpl) then,
  ) = __$$RedeemRewardRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rewardId});
}

/// @nodoc
class __$$RedeemRewardRequestImplCopyWithImpl<$Res>
    extends _$RedeemRewardRequestCopyWithImpl<$Res, _$RedeemRewardRequestImpl>
    implements _$$RedeemRewardRequestImplCopyWith<$Res> {
  __$$RedeemRewardRequestImplCopyWithImpl(
    _$RedeemRewardRequestImpl _value,
    $Res Function(_$RedeemRewardRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RedeemRewardRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rewardId = null}) {
    return _then(
      _$RedeemRewardRequestImpl(
        rewardId:
            null == rewardId
                ? _value.rewardId
                : rewardId // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RedeemRewardRequestImpl implements _RedeemRewardRequest {
  const _$RedeemRewardRequestImpl({required this.rewardId});

  factory _$RedeemRewardRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedeemRewardRequestImplFromJson(json);

  @override
  final int rewardId;

  @override
  String toString() {
    return 'RedeemRewardRequest(rewardId: $rewardId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedeemRewardRequestImpl &&
            (identical(other.rewardId, rewardId) ||
                other.rewardId == rewardId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rewardId);

  /// Create a copy of RedeemRewardRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedeemRewardRequestImplCopyWith<_$RedeemRewardRequestImpl> get copyWith =>
      __$$RedeemRewardRequestImplCopyWithImpl<_$RedeemRewardRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RedeemRewardRequestImplToJson(this);
  }
}

abstract class _RedeemRewardRequest implements RedeemRewardRequest {
  const factory _RedeemRewardRequest({required final int rewardId}) =
      _$RedeemRewardRequestImpl;

  factory _RedeemRewardRequest.fromJson(Map<String, dynamic> json) =
      _$RedeemRewardRequestImpl.fromJson;

  @override
  int get rewardId;

  /// Create a copy of RedeemRewardRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedeemRewardRequestImplCopyWith<_$RedeemRewardRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
