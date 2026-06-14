// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletBalanceImpl _$$WalletBalanceImplFromJson(Map<String, dynamic> json) =>
    _$WalletBalanceImpl(
      address: json['address'] as String,
      network: json['network'] as String,
      balanceCtc: json['balanceCtc'] as String,
      balanceWei: json['balanceWei'] as String,
      solesRef: json['solesRef'] as String,
      linkedWallet: json['linkedWallet'] as String?,
    );

Map<String, dynamic> _$$WalletBalanceImplToJson(_$WalletBalanceImpl instance) =>
    <String, dynamic>{
      'address': instance.address,
      'network': instance.network,
      'balanceCtc': instance.balanceCtc,
      'balanceWei': instance.balanceWei,
      'solesRef': instance.solesRef,
      'linkedWallet': instance.linkedWallet,
    };
