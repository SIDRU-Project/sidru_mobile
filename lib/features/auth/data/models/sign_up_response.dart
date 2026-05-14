import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_response.freezed.dart';
part 'sign_up_response.g.dart';

/// Respuesta de POST /authentication/sign-up
/// { "id": 1, "email": "...", "token": "jwt..." }
@freezed
class SignUpResponse with _$SignUpResponse {
  const factory SignUpResponse({
    required int id,
    required String email,
    required String token,
  }) = _SignUpResponse;

  factory SignUpResponse.fromJson(Map<String, dynamic> json) =>
      _$SignUpResponseFromJson(json);
}
