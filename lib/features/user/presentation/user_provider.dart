import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/models/update_profile_request.dart';
import '../data/models/user_profile.dart';
import '../data/user_api.dart';
import '../data/user_repository.dart';

// ── Cadena de dependencias ────────────────────────────────────────────────────

final userApiProvider = Provider<UserApi>((ref) {
  return UserApi(ref.watch(apiClientProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(userApiProvider));
});

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Gestiona el estado del perfil del usuario autenticado.
/// `build()` se llama automáticamente al observar el provider.
/// Uso en pantallas:
///   ref.watch(userNotifierProvider).when(loading, error, data)
final userNotifierProvider = AsyncNotifierProvider<UserNotifier, UserProfile?>(
  () => UserNotifier(),
);

class UserNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    return _fetchProfile();
  }

  // ── Carga de perfil ───────────────────────────────────────────────────────

  Future<UserProfile?> _fetchProfile() async {
    try {
      return await ref.read(userRepositoryProvider).getProfile();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        // JwtInterceptor ya borró el token; sincronizamos el estado de auth
        // para que el router redirija a /login.
        await ref.read(authNotifierProvider).logout();
        return null;
      }
      rethrow;
    }
  }

  // ── Actualizar perfil ─────────────────────────────────────────────────────

  /// Actualiza los campos editables del perfil.
  /// Retorna null si fue exitoso, o el mensaje de error si falló.
  Future<String?> updateProfile({
    required String fullName,
    required String phone,
    required String district,
  }) async {
    try {
      final updated = await ref
          .read(userRepositoryProvider)
          .updateProfile(
            UpdateProfileRequest(
              fullName: fullName.trim(),
              phone: phone.trim(),
              district: district.trim(),
            ),
          );
      state = AsyncData(updated);
      return null; // éxito
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await ref.read(authNotifierProvider).logout();
        return null;
      }
      return _mapUpdateError(e);
    } catch (_) {
      return 'Error inesperado. Intenta de nuevo.';
    }
  }

  // ── Refresco manual ───────────────────────────────────────────────────────

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchProfile);
  }

  // ── Mapeo de errores ──────────────────────────────────────────────────────

  String _mapUpdateError(ApiException e) => switch (e.type) {
    ApiErrorType.networkError => 'Sin conexión. Verifica tu internet.',
    ApiErrorType.badRequest => 'Verifica los datos ingresados.',
    _ => e.message,
  };
}
