// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WithdrawalStatusImpl _$$WithdrawalStatusImplFromJson(
  Map<String, dynamic> json,
) => _$WithdrawalStatusImpl(
  id: (json['id'] as num).toInt(),
  toAddress: json['toAddress'] as String,
  amountWei: json['amountWei'] as String,
  status: json['status'] as String,
  txHash: json['txHash'] as String?,
  explorerUrl: json['explorerUrl'] as String?,
);

Map<String, dynamic> _$$WithdrawalStatusImplToJson(
  _$WithdrawalStatusImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'toAddress': instance.toAddress,
  'amountWei': instance.amountWei,
  'status': instance.status,
  'txHash': instance.txHash,
  'explorerUrl': instance.explorerUrl,
};
