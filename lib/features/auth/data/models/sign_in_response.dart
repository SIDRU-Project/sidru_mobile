import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_response.freezed.dart';
part 'sign_in_response.g.dart';

/// Respuesta de POST /authentication/sign-in
/// { "id": 1, "email": "...", "token": "jwt..." }
@freezed
class SignInResponse with _$SignInResponse {
  const factory SignInResponse({
    required int id,
    required String email,
    required String token,
  }) = _SignInResponse;

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}
