import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_request.freezed.dart';
part 'sign_up_request.g.dart';

/// Body de POST /authentication/sign-up
/// roles siempre es ["ROLE_CITIZEN"] para la app móvil ciudadana.
@freezed
class SignUpRequest with _$SignUpRequest {
  const factory SignUpRequest({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String district,
    @Default(['ROLE_CITIZEN']) List<String> roles,
  }) = _SignUpRequest;

  factory SignUpRequest.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestFromJson(json);
}
