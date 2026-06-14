// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RewardImpl _$$RewardImplFromJson(Map<String, dynamic> json) => _$RewardImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  pointsCost: (json['pointsCost'] as num).toInt(),
  stock: (json['stock'] as num).toInt(),
  active: json['active'] as bool,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$$RewardImplToJson(_$RewardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'pointsCost': instance.pointsCost,
      'stock': instance.stock,
      'active': instance.active,
      'imageUrl': instance.imageUrl,
    };
