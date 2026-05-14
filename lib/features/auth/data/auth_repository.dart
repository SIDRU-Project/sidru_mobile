import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../../user/data/models/user_profile.dart';
import 'auth_api.dart';
import 'models/sign_in_request.dart';
import 'models/sign_in_response.dart';
import 'models/sign_up_request.dart';
import 'models/sign_up_response.dart';

/// Abstrae las operaciones de autenticación.
/// Guarda/elimina el JWT en SecureStorage.
/// Lanza [ApiException] ante errores del backend o de red.
class AuthRepository {
  final AuthApi _api;
  final SecureStorage _storage;

  AuthRepository(this._api, this._storage);

  /// Autentica al usuario y persiste el JWT en SecureStorage.
  Future<SignInResponse> signIn(String email, String password) async {
    final response = await _api.signIn(
      SignInRequest(email: email.trim(), password: password),
    );
    await _storage.saveToken(response.token);
    return response;
  }

  /// Registra un nuevo ciudadano reciclador.
  /// NO guarda JWT — el usuario debe hacer login explícito tras registrarse.
  Future<SignUpResponse> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String district,
  }) async {
    return _api.signUp(
      SignUpRequest(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        phone: phone.trim(),
        district: district.trim(),
      ),
    );
  }

  /// Elimina el JWT. Llamado en logout y al recibir 401.
  Future<void> logout() async {
    await _storage.deleteToken();
  }

  /// Intenta restaurar la sesión leyendo el token guardado.
  /// Retorna el perfil si el token es válido.
  /// Retorna null si no hay token, expiró (401) o hay error de red.
  Future<UserProfile?> tryRestoreSession() async {
    final hasToken = await _storage.hasToken();
    if (!hasToken) return null;

    try {
      return await _api.getMyProfile();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _storage.deleteToken();
      }
      return null;
    } catch (_) {
      // Error de red: mantenemos el token para que el usuario reintente al abrir de nuevo.
      return null;
    }
  }
}
