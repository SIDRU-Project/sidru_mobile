// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_bin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmartBinImpl _$$SmartBinImplFromJson(Map<String, dynamic> json) =>
    _$SmartBinImpl(
      id: (json['id'] as num).toInt(),
      deviceCode: json['deviceCode'] as String,
      location: json['location'] as String,
      district: json['district'] as String,
      status: json['status'] as String,
      totalCapsCollected: (json['totalCapsCollected'] as num).toInt(),
    );

Map<String, dynamic> _$$SmartBinImplToJson(_$SmartBinImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceCode': instance.deviceCode,
      'location': instance.location,
      'district': instance.district,
      'status': instance.status,
      'totalCapsCollected': instance.totalCapsCollected,
    };
