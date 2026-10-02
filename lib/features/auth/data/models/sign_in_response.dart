import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_response.freezed.dart';
part 'sign_in_response.g.dart';

/// Respuesta de POST /authentication/sign-in
/// { "id": 1, "email": "...", "token": "jwt...", "newUser": false }
/// `newUser` solo viene en el login social (true si la cuenta se acaba de crear).
@freezed
class SignInResponse with _$SignInResponse {
  const factory SignInResponse({
    required int id,
    required String email,
    required String token,
    @Default(false) bool newUser,
  }) = _SignInResponse;

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}
