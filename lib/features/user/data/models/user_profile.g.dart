// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      district: json['district'] as String,
      totalPoints: (json['totalPoints'] as num).toInt(),
      totalCaps: (json['totalCaps'] as num).toInt(),
      totalSessions: (json['totalSessions'] as num).toInt(),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'district': instance.district,
      'totalPoints': instance.totalPoints,
      'totalCaps': instance.totalCaps,
      'totalSessions': instance.totalSessions,
    };
