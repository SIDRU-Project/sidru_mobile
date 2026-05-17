import 'models/update_profile_request.dart';
import 'models/user_profile.dart';
import 'user_api.dart';

/// Abstrae las operaciones de perfil de usuario.
/// Lanza [ApiException] ante errores del backend o de red.
class UserRepository {
  final UserApi _api;

  UserRepository(this._api);

  /// Carga el perfil del usuario autenticado.
  Future<UserProfile> getProfile() => _api.getProfile();

  /// Actualiza el perfil con los campos editables.
  Future<UserProfile> updateProfile(UpdateProfileRequest request) =>
      _api.updateProfile(request);
}
