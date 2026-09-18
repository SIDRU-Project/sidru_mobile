// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WalletSummary _$WalletSummaryFromJson(Map<String, dynamic> json) {
  return _WalletSummary.fromJson(json);
}

/// @nodoc
mixin _$WalletSummary {
  int get pointsBalance => throw _privateConstructorUsedError;
  String get ctcEquivalent => throw _privateConstructorUsedError;
  String get solesEquivalent => throw _privateConstructorUsedError;
  String get network => throw _privateConstructorUsedError;
  String get explorerBaseUrl => throw _privateConstructorUsedError;
  String? get linkedWallet => throw _privateConstructorUsedError;
  int get minWithdrawalPoints => throw _privateConstructorUsedError;
  bool get withdrawalsEnabled => throw _privateConstructorUsedError;
  bool get hasWithdrawalInProgress => throw _privateConstructorUsedError;

  /// Serializes this WalletSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletSummaryCopyWith<WalletSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletSummaryCopyWith<$Res> {
  factory $WalletSummaryCopyWith(
    WalletSummary value,
    $Res Function(WalletSummary) then,
  ) = _$WalletSummaryCopyWithImpl<$Res, WalletSummary>;
  @useResult
  $Res call({
    int pointsBalance,
    String ctcEquivalent,
    String solesEquivalent,
    String network,
    String explorerBaseUrl,
    String? linkedWallet,
    int minWithdrawalPoints,
    bool withdrawalsEnabled,
    bool hasWithdrawalInProgress,
  });
}

/// @nodoc
class _$WalletSummaryCopyWithImpl<$Res, $Val extends WalletSummary>
    implements $WalletSummaryCopyWith<$Res> {
  _$WalletSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pointsBalance = null,
    Object? ctcEquivalent = null,
    Object? solesEquivalent = null,
    Object? network = null,
    Object? explorerBaseUrl = null,
    Object? linkedWallet = freezed,
    Object? minWithdrawalPoints = null,
    Object? withdrawalsEnabled = null,
    Object? hasWithdrawalInProgress = null,
  }) {
    return _then(
      _value.copyWith(
            pointsBalance:
                null == pointsBalance
                    ? _value.pointsBalance
                    : pointsBalance // ignore: cast_nullable_to_non_nullable
                        as int,
            ctcEquivalent:
                null == ctcEquivalent
                    ? _value.ctcEquivalent
                    : ctcEquivalent // ignore: cast_nullable_to_non_nullable
                        as String,
            solesEquivalent:
                null == solesEquivalent
                    ? _value.solesEquivalent
                    : solesEquivalent // ignore: cast_nullable_to_non_nullable
                        as String,
            network:
                null == network
                    ? _value.network
                    : network // ignore: cast_nullable_to_non_nullable
                        as String,
            explorerBaseUrl:
                null == explorerBaseUrl
                    ? _value.explorerBaseUrl
                    : explorerBaseUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            linkedWallet:
                freezed == linkedWallet
                    ? _value.linkedWallet
                    : linkedWallet // ignore: cast_nullable_to_non_nullable
                        as String?,
            minWithdrawalPoints:
                null == minWithdrawalPoints
                    ? _value.minWithdrawalPoints
                    : minWithdrawalPoints // ignore: cast_nullable_to_non_nullable
                        as int,
            withdrawalsEnabled:
                null == withdrawalsEnabled
                    ? _value.withdrawalsEnabled
                    : withdrawalsEnabled // ignore: cast_nullable_to_non_nullable
                        as bool,
            hasWithdrawalInProgress:
                null == hasWithdrawalInProgress
                    ? _value.hasWithdrawalInProgress
                    : hasWithdrawalInProgress // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WalletSummaryImplCopyWith<$Res>
    implements $WalletSummaryCopyWith<$Res> {
  factory _$$WalletSummaryImplCopyWith(
    _$WalletSummaryImpl value,
    $Res Function(_$WalletSummaryImpl) then,
  ) = __$$WalletSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int pointsBalance,
    String ctcEquivalent,
    String solesEquivalent,
    String network,
    String explorerBaseUrl,
    String? linkedWallet,
    int minWithdrawalPoints,
    bool withdrawalsEnabled,
    bool hasWithdrawalInProgress,
  });
}

/// @nodoc
class __$$WalletSummaryImplCopyWithImpl<$Res>
    extends _$WalletSummaryCopyWithImpl<$Res, _$WalletSummaryImpl>
    implements _$$WalletSummaryImplCopyWith<$Res> {
  __$$WalletSummaryImplCopyWithImpl(
    _$WalletSummaryImpl _value,
    $Res Function(_$WalletSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WalletSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pointsBalance = null,
    Object? ctcEquivalent = null,
    Object? solesEquivalent = null,
    Object? network = null,
    Object? explorerBaseUrl = null,
    Object? linkedWallet = freezed,
    Object? minWithdrawalPoints = null,
    Object? withdrawalsEnabled = null,
    Object? hasWithdrawalInProgress = null,
  }) {
    return _then(
      _$WalletSummaryImpl(
        pointsBalance:
            null == pointsBalance
                ? _value.pointsBalance
                : pointsBalance // ignore: cast_nullable_to_non_nullable
                    as int,
        ctcEquivalent:
            null == ctcEquivalent
                ? _value.ctcEquivalent
                : ctcEquivalent // ignore: cast_nullable_to_non_nullable
                    as String,
        solesEquivalent:
            null == solesEquivalent
                ? _value.solesEquivalent
                : solesEquivalent // ignore: cast_nullable_to_non_nullable
                    as String,
        network:
            null == network
                ? _value.network
                : network // ignore: cast_nullable_to_non_nullable
                    as String,
        explorerBaseUrl:
            null == explorerBaseUrl
                ? _value.explorerBaseUrl
                : explorerBaseUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        linkedWallet:
            freezed == linkedWallet
                ? _value.linkedWallet
                : linkedWallet // ignore: cast_nullable_to_non_nullable
                    as String?,
        minWithdrawalPoints:
            null == minWithdrawalPoints
                ? _value.minWithdrawalPoints
                : minWithdrawalPoints // ignore: cast_nullable_to_non_nullable
                    as int,
        withdrawalsEnabled:
            null == withdrawalsEnabled
                ? _value.withdrawalsEnabled
                : withdrawalsEnabled // ignore: cast_nullable_to_non_nullable
                    as bool,
        hasWithdrawalInProgress:
            null == hasWithdrawalInProgress
                ? _value.hasWithdrawalInProgress
                : hasWithdrawalInProgress // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletSummaryImpl implements _WalletSummary {
  const _$WalletSummaryImpl({
    required this.pointsBalance,
    required this.ctcEquivalent,
    required this.solesEquivalent,
    required this.network,
    required this.explorerBaseUrl,
    this.linkedWallet,
    required this.minWithdrawalPoints,
    required this.withdrawalsEnabled,
    required this.hasWithdrawalInProgress,
  });

  factory _$WalletSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletSummaryImplFromJson(json);

  @override
  final int pointsBalance;
  @override
  final String ctcEquivalent;
  @override
  final String solesEquivalent;
  @override
  final String network;
  @override
  final String explorerBaseUrl;
  @override
  final String? linkedWallet;
  @override
  final int minWithdrawalPoints;
  @override
  final bool withdrawalsEnabled;
  @override
  final bool hasWithdrawalInProgress;

  @override
  String toString() {
    return 'WalletSummary(pointsBalance: $pointsBalance, ctcEquivalent: $ctcEquivalent, solesEquivalent: $solesEquivalent, network: $network, explorerBaseUrl: $explorerBaseUrl, linkedWallet: $linkedWallet, minWithdrawalPoints: $minWithdrawalPoints, withdrawalsEnabled: $withdrawalsEnabled, hasWithdrawalInProgress: $hasWithdrawalInProgress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletSummaryImpl &&
            (identical(other.pointsBalance, pointsBalance) ||
                other.pointsBalance == pointsBalance) &&
            (identical(other.ctcEquivalent, ctcEquivalent) ||
                other.ctcEquivalent == ctcEquivalent) &&
            (identical(other.solesEquivalent, solesEquivalent) ||
                other.solesEquivalent == solesEquivalent) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.explorerBaseUrl, explorerBaseUrl) ||
                other.explorerBaseUrl == explorerBaseUrl) &&
            (identical(other.linkedWallet, linkedWallet) ||
                other.linkedWallet == linkedWallet) &&
            (identical(other.minWithdrawalPoints, minWithdrawalPoints) ||
                other.minWithdrawalPoints == minWithdrawalPoints) &&
            (identical(other.withdrawalsEnabled, withdrawalsEnabled) ||
                other.withdrawalsEnabled == withdrawalsEnabled) &&
            (identical(
                  other.hasWithdrawalInProgress,
                  hasWithdrawalInProgress,
                ) ||
                other.hasWithdrawalInProgress == hasWithdrawalInProgress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pointsBalance,
    ctcEquivalent,
    solesEquivalent,
    network,
    explorerBaseUrl,
    linkedWallet,
    minWithdrawalPoints,
    withdrawalsEnabled,
    hasWithdrawalInProgress,
  );

  /// Create a copy of WalletSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletSummaryImplCopyWith<_$WalletSummaryImpl> get copyWith =>
      __$$WalletSummaryImplCopyWithImpl<_$WalletSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletSummaryImplToJson(this);
  }
}

abstract class _WalletSummary implements WalletSummary {
  const factory _WalletSummary({
    required final int pointsBalance,
    required final String ctcEquivalent,
    required final String solesEquivalent,
    required final String network,
    required final String explorerBaseUrl,
    final String? linkedWallet,
    required final int minWithdrawalPoints,
    required final bool withdrawalsEnabled,
    required final bool hasWithdrawalInProgress,
  }) = _$WalletSummaryImpl;

  factory _WalletSummary.fromJson(Map<String, dynamic> json) =
      _$WalletSummaryImpl.fromJson;

  @override
  int get pointsBalance;
  @override
  String get ctcEquivalent;
  @override
  String get solesEquivalent;
  @override
  String get network;
  @override
  String get explorerBaseUrl;
  @override
  String? get linkedWallet;
  @override
  int get minWithdrawalPoints;
  @override
  bool get withdrawalsEnabled;
  @override
  bool get hasWithdrawalInProgress;

  /// Create a copy of WalletSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletSummaryImplCopyWith<_$WalletSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
