// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WalletBalance _$WalletBalanceFromJson(Map<String, dynamic> json) {
  return _WalletBalance.fromJson(json);
}

/// @nodoc
mixin _$WalletBalance {
  String get address => throw _privateConstructorUsedError;
  String get network => throw _privateConstructorUsedError;
  String get balanceCtc => throw _privateConstructorUsedError;
  String get balanceWei => throw _privateConstructorUsedError;
  String get solesRef => throw _privateConstructorUsedError;
  String? get linkedWallet => throw _privateConstructorUsedError;

  /// Serializes this WalletBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletBalanceCopyWith<WalletBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletBalanceCopyWith<$Res> {
  factory $WalletBalanceCopyWith(
    WalletBalance value,
    $Res Function(WalletBalance) then,
  ) = _$WalletBalanceCopyWithImpl<$Res, WalletBalance>;
  @useResult
  $Res call({
    String address,
    String network,
    String balanceCtc,
    String balanceWei,
    String solesRef,
    String? linkedWallet,
  });
}

/// @nodoc
class _$WalletBalanceCopyWithImpl<$Res, $Val extends WalletBalance>
    implements $WalletBalanceCopyWith<$Res> {
  _$WalletBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? network = null,
    Object? balanceCtc = null,
    Object? balanceWei = null,
    Object? solesRef = null,
    Object? linkedWallet = freezed,
  }) {
    return _then(
      _value.copyWith(
            address:
                null == address
                    ? _value.address
                    : address // ignore: cast_nullable_to_non_nullable
                        as String,
            network:
                null == network
                    ? _value.network
                    : network // ignore: cast_nullable_to_non_nullable
                        as String,
            balanceCtc:
                null == balanceCtc
                    ? _value.balanceCtc
                    : balanceCtc // ignore: cast_nullable_to_non_nullable
                        as String,
            balanceWei:
                null == balanceWei
                    ? _value.balanceWei
                    : balanceWei // ignore: cast_nullable_to_non_nullable
                        as String,
            solesRef:
                null == solesRef
                    ? _value.solesRef
                    : solesRef // ignore: cast_nullable_to_non_nullable
                        as String,
            linkedWallet:
                freezed == linkedWallet
                    ? _value.linkedWallet
                    : linkedWallet // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WalletBalanceImplCopyWith<$Res>
    implements $WalletBalanceCopyWith<$Res> {
  factory _$$WalletBalanceImplCopyWith(
    _$WalletBalanceImpl value,
    $Res Function(_$WalletBalanceImpl) then,
  ) = __$$WalletBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String address,
    String network,
    String balanceCtc,
    String balanceWei,
    String solesRef,
    String? linkedWallet,
  });
}

/// @nodoc
class __$$WalletBalanceImplCopyWithImpl<$Res>
    extends _$WalletBalanceCopyWithImpl<$Res, _$WalletBalanceImpl>
    implements _$$WalletBalanceImplCopyWith<$Res> {
  __$$WalletBalanceImplCopyWithImpl(
    _$WalletBalanceImpl _value,
    $Res Function(_$WalletBalanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WalletBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? address = null,
    Object? network = null,
    Object? balanceCtc = null,
    Object? balanceWei = null,
    Object? solesRef = null,
    Object? linkedWallet = freezed,
  }) {
    return _then(
      _$WalletBalanceImpl(
        address:
            null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String,
        network:
            null == network
                ? _value.network
                : network // ignore: cast_nullable_to_non_nullable
                    as String,
        balanceCtc:
            null == balanceCtc
                ? _value.balanceCtc
                : balanceCtc // ignore: cast_nullable_to_non_nullable
                    as String,
        balanceWei:
            null == balanceWei
                ? _value.balanceWei
                : balanceWei // ignore: cast_nullable_to_non_nullable
                    as String,
        solesRef:
            null == solesRef
                ? _value.solesRef
                : solesRef // ignore: cast_nullable_to_non_nullable
                    as String,
        linkedWallet:
            freezed == linkedWallet
                ? _value.linkedWallet
                : linkedWallet // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletBalanceImpl implements _WalletBalance {
  const _$WalletBalanceImpl({
    required this.address,
    required this.network,
    required this.balanceCtc,
    required this.balanceWei,
    required this.solesRef,
    this.linkedWallet,
  });

  factory _$WalletBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletBalanceImplFromJson(json);

  @override
  final String address;
  @override
  final String network;
  @override
  final String balanceCtc;
  @override
  final String balanceWei;
  @override
  final String solesRef;
  @override
  final String? linkedWallet;

  @override
  String toString() {
    return 'WalletBalance(address: $address, network: $network, balanceCtc: $balanceCtc, balanceWei: $balanceWei, solesRef: $solesRef, linkedWallet: $linkedWallet)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletBalanceImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.balanceCtc, balanceCtc) ||
                other.balanceCtc == balanceCtc) &&
            (identical(other.balanceWei, balanceWei) ||
                other.balanceWei == balanceWei) &&
            (identical(other.solesRef, solesRef) ||
                other.solesRef == solesRef) &&
            (identical(other.linkedWallet, linkedWallet) ||
                other.linkedWallet == linkedWallet));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    address,
    network,
    balanceCtc,
    balanceWei,
    solesRef,
    linkedWallet,
  );

  /// Create a copy of WalletBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletBalanceImplCopyWith<_$WalletBalanceImpl> get copyWith =>
      __$$WalletBalanceImplCopyWithImpl<_$WalletBalanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletBalanceImplToJson(this);
  }
}

abstract class _WalletBalance implements WalletBalance {
  const factory _WalletBalance({
    required final String address,
    required final String network,
    required final String balanceCtc,
    required final String balanceWei,
    required final String solesRef,
    final String? linkedWallet,
  }) = _$WalletBalanceImpl;

  factory _WalletBalance.fromJson(Map<String, dynamic> json) =
      _$WalletBalanceImpl.fromJson;

  @override
  String get address;
  @override
  String get network;
  @override
  String get balanceCtc;
  @override
  String get balanceWei;
  @override
  String get solesRef;
  @override
  String? get linkedWallet;

  /// Create a copy of WalletBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletBalanceImplCopyWith<_$WalletBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
