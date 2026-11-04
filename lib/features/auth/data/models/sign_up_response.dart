import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_response.freezed.dart';
part 'sign_up_response.g.dart';

/// Respuesta de POST /authentication/sign-up.
/// El backend devuelve el UserResource creado, SIN token:
/// { "id": 1, "email": "...", "roles": ["ROLE_USER"] }
/// El login es un paso aparte (sign-in), por eso aquí no hay JWT.
@freezed
class SignUpResponse with _$SignUpResponse {
  const factory SignUpResponse({
    required int id,
    required String email,
    @Default(<String>[]) List<String> roles,
  }) = _SignUpResponse;

  factory SignUpResponse.fromJson(Map<String, dynamic> json) =>
      _$SignUpResponseFromJson(json);
}
