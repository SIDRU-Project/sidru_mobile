import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_error_mapper.dart';
import '../../user/data/models/user_profile.dart';
import 'models/sign_in_request.dart';
import 'models/sign_in_response.dart';
import 'models/sign_up_request.dart';
import 'models/sign_up_response.dart';

/// Datasource de autenticación.
/// Sólo hace llamadas HTTP y mapea respuestas crudas a modelos.
/// No guarda estado ni JWT — eso es responsabilidad de AuthRepository.
class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  /// POST /authentication/sign-in
  Future<SignInResponse> signIn(SignInRequest request) async {
    try {
      final res = await _client.post(
        '/authentication/sign-in',
        data: request.toJson(),
      );
      return SignInResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// POST /authentication/sign-up
  Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      final res = await _client.post(
        '/authentication/sign-up',
        data: request.toJson(),
      );
      return SignUpResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /profiles/me — usado solo para validar/restaurar sesión.
  /// La carga completa de perfil ocurre en UserApi (Phase 5).
  Future<UserProfile> getMyProfile() async {
    try {
      final res = await _client.get('/profiles/me');
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }
}
