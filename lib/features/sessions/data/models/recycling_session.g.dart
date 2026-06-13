// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recycling_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecyclingSessionImpl _$$RecyclingSessionImplFromJson(
  Map<String, dynamic> json,
) => _$RecyclingSessionImpl(
  id: (json['id'] as num).toInt(),
  smartBinId: (json['smartBinId'] as num).toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  capCount: (json['capCount'] as num).toInt(),
  weightGrams: (json['weightGrams'] as num).toDouble(),
  pointsEarned: (json['pointsEarned'] as num).toInt(),
  qrToken: json['qrToken'] as String,
  status: $enumDecode(_$RecyclingSessionStatusEnumMap, json['status']),
  expiresAt:
      json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
  confirmedAt:
      json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
  blockchainTxHash: json['blockchainTxHash'] as String?,
);

Map<String, dynamic> _$$RecyclingSessionImplToJson(
  _$RecyclingSessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'smartBinId': instance.smartBinId,
  'userId': instance.userId,
  'capCount': instance.capCount,
  'weightGrams': instance.weightGrams,
  'pointsEarned': instance.pointsEarned,
  'qrToken': instance.qrToken,
  'status': _$RecyclingSessionStatusEnumMap[instance.status]!,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'confirmedAt': instance.confirmedAt?.toIso8601String(),
  'blockchainTxHash': instance.blockchainTxHash,
};

const _$RecyclingSessionStatusEnumMap = {
  RecyclingSessionStatus.pending: 'PENDING',
  RecyclingSessionStatus.confirmed: 'CONFIRMED',
  RecyclingSessionStatus.expired: 'EXPIRED',
  RecyclingSessionStatus.cancelled: 'CANCELLED',
};
