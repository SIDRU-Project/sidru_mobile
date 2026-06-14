// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PointTransactionImpl _$$PointTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$PointTransactionImpl(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  type: $enumDecode(_$PointTransactionTypeEnumMap, json['type']),
  points: (json['points'] as num).toInt(),
  description: json['description'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$PointTransactionImplToJson(
  _$PointTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': _$PointTransactionTypeEnumMap[instance.type]!,
  'points': instance.points,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$PointTransactionTypeEnumMap = {
  PointTransactionType.earn: 'EARN',
  PointTransactionType.redeem: 'REDEEM',
};
