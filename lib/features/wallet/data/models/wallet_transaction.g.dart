// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletTransactionImpl _$$WalletTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$WalletTransactionImpl(
  id: (json['id'] as num).toInt(),
  mode: json['mode'] as String,
  points: (json['points'] as num).toInt(),
  amountWei: json['amountWei'] as String,
  toAddress: json['toAddress'] as String,
  status: json['status'] as String,
  txHash: json['txHash'] as String?,
  explorerUrl: json['explorerUrl'] as String?,
  failureReason: json['failureReason'] as String?,
  reserveOut: json['reserveOut'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$WalletTransactionImplToJson(
  _$WalletTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'mode': instance.mode,
  'points': instance.points,
  'amountWei': instance.amountWei,
  'toAddress': instance.toAddress,
  'status': instance.status,
  'txHash': instance.txHash,
  'explorerUrl': instance.explorerUrl,
  'failureReason': instance.failureReason,
  'reserveOut': instance.reserveOut,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
