// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletSummaryImpl _$$WalletSummaryImplFromJson(Map<String, dynamic> json) =>
    _$WalletSummaryImpl(
      pointsBalance: (json['pointsBalance'] as num).toInt(),
      ctcEquivalent: json['ctcEquivalent'] as String,
      solesEquivalent: json['solesEquivalent'] as String,
      network: json['network'] as String,
      explorerBaseUrl: json['explorerBaseUrl'] as String,
      linkedWallet: json['linkedWallet'] as String?,
      minWithdrawalPoints: (json['minWithdrawalPoints'] as num).toInt(),
      withdrawalsEnabled: json['withdrawalsEnabled'] as bool,
      hasWithdrawalInProgress: json['hasWithdrawalInProgress'] as bool,
    );

Map<String, dynamic> _$$WalletSummaryImplToJson(_$WalletSummaryImpl instance) =>
    <String, dynamic>{
      'pointsBalance': instance.pointsBalance,
      'ctcEquivalent': instance.ctcEquivalent,
      'solesEquivalent': instance.solesEquivalent,
      'network': instance.network,
      'explorerBaseUrl': instance.explorerBaseUrl,
      'linkedWallet': instance.linkedWallet,
      'minWithdrawalPoints': instance.minWithdrawalPoints,
      'withdrawalsEnabled': instance.withdrawalsEnabled,
      'hasWithdrawalInProgress': instance.hasWithdrawalInProgress,
    };
