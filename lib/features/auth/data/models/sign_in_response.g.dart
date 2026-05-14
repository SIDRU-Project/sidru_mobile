// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignInResponseImpl _$$SignInResponseImplFromJson(Map<String, dynamic> json) =>
    _$SignInResponseImpl(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$$SignInResponseImplToJson(
  _$SignInResponseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'token': instance.token,
};
