// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdrawal_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WithdrawalStatus _$WithdrawalStatusFromJson(Map<String, dynamic> json) {
  return _WithdrawalStatus.fromJson(json);
}

/// @nodoc
mixin _$WithdrawalStatus {
  int get id => throw _privateConstructorUsedError;
  String get toAddress => throw _privateConstructorUsedError;
  String get amountWei => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get txHash => throw _privateConstructorUsedError;
  String? get explorerUrl => throw _privateConstructorUsedError;

  /// Serializes this WithdrawalStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WithdrawalStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WithdrawalStatusCopyWith<WithdrawalStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WithdrawalStatusCopyWith<$Res> {
  factory $WithdrawalStatusCopyWith(
    WithdrawalStatus value,
    $Res Function(WithdrawalStatus) then,
  ) = _$WithdrawalStatusCopyWithImpl<$Res, WithdrawalStatus>;
  @useResult
  $Res call({
    int id,
    String toAddress,
    String amountWei,
    String status,
    String? txHash,
    String? explorerUrl,
  });
}

/// @nodoc
class _$WithdrawalStatusCopyWithImpl<$Res, $Val extends WithdrawalStatus>
    implements $WithdrawalStatusCopyWith<$Res> {
  _$WithdrawalStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WithdrawalStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? toAddress = null,
    Object? amountWei = null,
    Object? status = null,
    Object? txHash = freezed,
    Object? explorerUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            toAddress:
                null == toAddress
                    ? _value.toAddress
                    : toAddress // ignore: cast_nullable_to_non_nullable
                        as String,
            amountWei:
                null == amountWei
                    ? _value.amountWei
                    : amountWei // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            txHash:
                freezed == txHash
                    ? _value.txHash
                    : txHash // ignore: cast_nullable_to_non_nullable
                        as String?,
            explorerUrl:
                freezed == explorerUrl
                    ? _value.explorerUrl
                    : explorerUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WithdrawalStatusImplCopyWith<$Res>
    implements $WithdrawalStatusCopyWith<$Res> {
  factory _$$WithdrawalStatusImplCopyWith(
    _$WithdrawalStatusImpl value,
    $Res Function(_$WithdrawalStatusImpl) then,
  ) = __$$WithdrawalStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String toAddress,
    String amountWei,
    String status,
    String? txHash,
    String? explorerUrl,
  });
}

/// @nodoc
class __$$WithdrawalStatusImplCopyWithImpl<$Res>
    extends _$WithdrawalStatusCopyWithImpl<$Res, _$WithdrawalStatusImpl>
    implements _$$WithdrawalStatusImplCopyWith<$Res> {
  __$$WithdrawalStatusImplCopyWithImpl(
    _$WithdrawalStatusImpl _value,
    $Res Function(_$WithdrawalStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WithdrawalStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? toAddress = null,
    Object? amountWei = null,
    Object? status = null,
    Object? txHash = freezed,
    Object? explorerUrl = freezed,
  }) {
    return _then(
      _$WithdrawalStatusImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        toAddress:
            null == toAddress
                ? _value.toAddress
                : toAddress // ignore: cast_nullable_to_non_nullable
                    as String,
        amountWei:
            null == amountWei
                ? _value.amountWei
                : amountWei // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        txHash:
            freezed == txHash
                ? _value.txHash
                : txHash // ignore: cast_nullable_to_non_nullable
                    as String?,
        explorerUrl:
            freezed == explorerUrl
                ? _value.explorerUrl
                : explorerUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WithdrawalStatusImpl implements _WithdrawalStatus {
  const _$WithdrawalStatusImpl({
    required this.id,
    required this.toAddress,
    required this.amountWei,
    required this.status,
    this.txHash,
    this.explorerUrl,
  });

  factory _$WithdrawalStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$WithdrawalStatusImplFromJson(json);

  @override
  final int id;
  @override
  final String toAddress;
  @override
  final String amountWei;
  @override
  final String status;
  @override
  final String? txHash;
  @override
  final String? explorerUrl;

  @override
  String toString() {
    return 'WithdrawalStatus(id: $id, toAddress: $toAddress, amountWei: $amountWei, status: $status, txHash: $txHash, explorerUrl: $explorerUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WithdrawalStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.toAddress, toAddress) ||
                other.toAddress == toAddress) &&
            (identical(other.amountWei, amountWei) ||
                other.amountWei == amountWei) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.txHash, txHash) || other.txHash == txHash) &&
            (identical(other.explorerUrl, explorerUrl) ||
                other.explorerUrl == explorerUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    toAddress,
    amountWei,
    status,
    txHash,
    explorerUrl,
  );

  /// Create a copy of WithdrawalStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WithdrawalStatusImplCopyWith<_$WithdrawalStatusImpl> get copyWith =>
      __$$WithdrawalStatusImplCopyWithImpl<_$WithdrawalStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WithdrawalStatusImplToJson(this);
  }
}

abstract class _WithdrawalStatus implements WithdrawalStatus {
  const factory _WithdrawalStatus({
    required final int id,
    required final String toAddress,
    required final String amountWei,
    required final String status,
    final String? txHash,
    final String? explorerUrl,
  }) = _$WithdrawalStatusImpl;

  factory _WithdrawalStatus.fromJson(Map<String, dynamic> json) =
      _$WithdrawalStatusImpl.fromJson;

  @override
  int get id;
  @override
  String get toAddress;
  @override
  String get amountWei;
  @override
  String get status;
  @override
  String? get txHash;
  @override
  String? get explorerUrl;

  /// Create a copy of WithdrawalStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WithdrawalStatusImplCopyWith<_$WithdrawalStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
