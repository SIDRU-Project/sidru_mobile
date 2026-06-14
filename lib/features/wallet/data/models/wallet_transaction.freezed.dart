// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) {
  return _WalletTransaction.fromJson(json);
}

/// @nodoc
mixin _$WalletTransaction {
  @JsonKey(unknownEnumValue: WalletTransactionType.unknown)
  WalletTransactionType get type => throw _privateConstructorUsedError;
  String get txHash => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get explorerUrl => throw _privateConstructorUsedError;

  /// Serializes this WalletTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletTransactionCopyWith<WalletTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletTransactionCopyWith<$Res> {
  factory $WalletTransactionCopyWith(
    WalletTransaction value,
    $Res Function(WalletTransaction) then,
  ) = _$WalletTransactionCopyWithImpl<$Res, WalletTransaction>;
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: WalletTransactionType.unknown)
    WalletTransactionType type,
    String txHash,
    String status,
    String explorerUrl,
  });
}

/// @nodoc
class _$WalletTransactionCopyWithImpl<$Res, $Val extends WalletTransaction>
    implements $WalletTransactionCopyWith<$Res> {
  _$WalletTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? txHash = null,
    Object? status = null,
    Object? explorerUrl = null,
  }) {
    return _then(
      _value.copyWith(
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as WalletTransactionType,
            txHash:
                null == txHash
                    ? _value.txHash
                    : txHash // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            explorerUrl:
                null == explorerUrl
                    ? _value.explorerUrl
                    : explorerUrl // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WalletTransactionImplCopyWith<$Res>
    implements $WalletTransactionCopyWith<$Res> {
  factory _$$WalletTransactionImplCopyWith(
    _$WalletTransactionImpl value,
    $Res Function(_$WalletTransactionImpl) then,
  ) = __$$WalletTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(unknownEnumValue: WalletTransactionType.unknown)
    WalletTransactionType type,
    String txHash,
    String status,
    String explorerUrl,
  });
}

/// @nodoc
class __$$WalletTransactionImplCopyWithImpl<$Res>
    extends _$WalletTransactionCopyWithImpl<$Res, _$WalletTransactionImpl>
    implements _$$WalletTransactionImplCopyWith<$Res> {
  __$$WalletTransactionImplCopyWithImpl(
    _$WalletTransactionImpl _value,
    $Res Function(_$WalletTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? txHash = null,
    Object? status = null,
    Object? explorerUrl = null,
  }) {
    return _then(
      _$WalletTransactionImpl(
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as WalletTransactionType,
        txHash:
            null == txHash
                ? _value.txHash
                : txHash // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        explorerUrl:
            null == explorerUrl
                ? _value.explorerUrl
                : explorerUrl // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletTransactionImpl implements _WalletTransaction {
  const _$WalletTransactionImpl({
    @JsonKey(unknownEnumValue: WalletTransactionType.unknown)
    required this.type,
    required this.txHash,
    required this.status,
    required this.explorerUrl,
  });

  factory _$WalletTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletTransactionImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: WalletTransactionType.unknown)
  final WalletTransactionType type;
  @override
  final String txHash;
  @override
  final String status;
  @override
  final String explorerUrl;

  @override
  String toString() {
    return 'WalletTransaction(type: $type, txHash: $txHash, status: $status, explorerUrl: $explorerUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletTransactionImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.txHash, txHash) || other.txHash == txHash) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.explorerUrl, explorerUrl) ||
                other.explorerUrl == explorerUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, txHash, status, explorerUrl);

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletTransactionImplCopyWith<_$WalletTransactionImpl> get copyWith =>
      __$$WalletTransactionImplCopyWithImpl<_$WalletTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletTransactionImplToJson(this);
  }
}

abstract class _WalletTransaction implements WalletTransaction {
  const factory _WalletTransaction({
    @JsonKey(unknownEnumValue: WalletTransactionType.unknown)
    required final WalletTransactionType type,
    required final String txHash,
    required final String status,
    required final String explorerUrl,
  }) = _$WalletTransactionImpl;

  factory _WalletTransaction.fromJson(Map<String, dynamic> json) =
      _$WalletTransactionImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: WalletTransactionType.unknown)
  WalletTransactionType get type;
  @override
  String get txHash;
  @override
  String get status;
  @override
  String get explorerUrl;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletTransactionImplCopyWith<_$WalletTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
