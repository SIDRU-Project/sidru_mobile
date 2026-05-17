import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_error_mapper.dart';
import 'models/update_profile_request.dart';
import 'models/user_profile.dart';

/// Datasource HTTP del perfil de usuario.
/// Solo mapea llamadas HTTP a modelos de dominio.
class UserApi {
  final ApiClient _client;

  UserApi(this._client);

  /// GET /profiles/me
  Future<UserProfile> getProfile() async {
    try {
      final res = await _client.get('/profiles/me');
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// PUT /profiles/me
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    try {
      final res = await _client.put('/profiles/me', data: request.toJson());
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }
}
