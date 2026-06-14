// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletTransactionImpl _$$WalletTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$WalletTransactionImpl(
  type: $enumDecode(
    _$WalletTransactionTypeEnumMap,
    json['type'],
    unknownValue: WalletTransactionType.unknown,
  ),
  txHash: json['txHash'] as String,
  status: json['status'] as String,
  explorerUrl: json['explorerUrl'] as String,
);

Map<String, dynamic> _$$WalletTransactionImplToJson(
  _$WalletTransactionImpl instance,
) => <String, dynamic>{
  'type': _$WalletTransactionTypeEnumMap[instance.type]!,
  'txHash': instance.txHash,
  'status': instance.status,
  'explorerUrl': instance.explorerUrl,
};

const _$WalletTransactionTypeEnumMap = {
  WalletTransactionType.mint: 'MINT',
  WalletTransactionType.withdraw: 'WITHDRAW',
  WalletTransactionType.unknown: 'UNKNOWN',
};
