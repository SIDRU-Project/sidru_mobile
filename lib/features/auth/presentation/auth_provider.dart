import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/notifications/fcm_handler.dart';
import '../../../core/router/app_router.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';

// ── Providers de la cadena de dependencias ────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage);
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authApiProvider),
    ref.watch(secureStorageProvider),
  );
});

/// Provider principal de autenticación.
/// GoRouter lo usa como refreshListenable para disparar redirects.
final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(fcmHandlerProvider),
  );
});

// ── Estado de autenticación ────────────────────────────────────────────────────

class AuthNotifierState {
  final bool isAuthenticated;

  /// true mientras la app verifica el token guardado al arrancar.
  final bool isInitializing;

  /// true mientras se ejecuta signIn o signUp.
  final bool isLoading;

  /// Mensaje de error del último intento (null si no hay error).
  final String? errorMessage;

  /// Email del usuario autenticado (disponible tras signIn exitoso).
  final String? email;

  const AuthNotifierState({
    this.isAuthenticated = false,
    this.isInitializing = false,
    this.isLoading = false,
    this.errorMessage,
    this.email,
  });

  AuthNotifierState withLoading() => AuthNotifierState(
    isAuthenticated: isAuthenticated,
    isInitializing: isInitializing,
    isLoading: true,
    email: email,
  );

  AuthNotifierState withError(String message) => AuthNotifierState(
    isAuthenticated: isAuthenticated,
    isInitializing: isInitializing,
    isLoading: false,
    errorMessage: message,
    email: email,
  );

  AuthNotifierState withAuthenticated(String userEmail) => AuthNotifierState(
    isAuthenticated: true,
    isInitializing: false,
    isLoading: false,
    email: userEmail,
  );

  AuthNotifierState cleared() => const AuthNotifierState(
    isAuthenticated: false,
    isInitializing: false,
    isLoading: false,
  );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

/// Gestiona el ciclo de vida de autenticación.
/// Extiende ChangeNotifier para que GoRouter lo use como refreshListenable.
///
/// Flujo:
///   Arranque → _restoreSession() → si hay token válido, isAuthenticated = true
///   signIn()  → POST /authentication/sign-in → guarda JWT → isAuthenticated = true
///   signUp()  → POST /authentication/sign-up → devuelve bool (UI navega a login)
///   logout()  → borra JWT → isAuthenticated = false
class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repository;
  final FcmHandler _fcmHandler;
  AuthNotifierState _state = const AuthNotifierState(isInitializing: true);

  AuthNotifierState get state => _state;

  AuthNotifier(this._repository, this._fcmHandler) {
    _restoreSession();
  }

  void _update(AuthNotifierState newState) {
    _state = newState;
    notifyListeners();
  }

  // ── Restaurar sesión al arrancar ──────────────────────────────────────────

  Future<void> _restoreSession() async {
    try {
      final profile = await _repository.tryRestoreSession();
      if (profile != null) {
        _update(_state.withAuthenticated(profile.fullName));
        // FCM: suscribe al ciudadano a su topic user-{userId} (best-effort).
        unawaited(_fcmHandler.subscribeToUser(profile.userId));
      } else {
        _update(_state.cleared());
      }
    } catch (_) {
      _update(_state.cleared());
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    _update(_state.withLoading());
    try {
      final response = await _repository.signIn(email, password);
      _update(_state.withAuthenticated(response.email));
      // FCM: suscribe al ciudadano a su topic user-{userId} (best-effort).
      unawaited(_fcmHandler.subscribeToUser(response.id));
    } on ApiException catch (e) {
      _update(_state.withError(_mapSignInError(e)));
    } catch (_) {
      _update(_state.withError('Error inesperado. Intenta de nuevo.'));
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  /// Retorna true si el registro fue exitoso.
  /// La UI es responsable de navegar a Login tras true.
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String district,
  }) async {
    _update(_state.withLoading());
    try {
      await _repository.signUp(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        district: district,
      );
      _update(_state.cleared());
      return true;
    } on ApiException catch (e) {
      _update(_state.withError(_mapSignUpError(e)));
      return false;
    } catch (_) {
      _update(_state.withError('Error inesperado. Intenta de nuevo.'));
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // FCM: desuscribe del topic del usuario antes de limpiar la sesión (best-effort).
    unawaited(_fcmHandler.unsubscribeCurrent());
    await _repository.logout();
    _update(_state.cleared());
  }

  // ── Utilidades ───────────────────────────────────────────────────────────

  void clearError() {
    if (_state.errorMessage != null) {
      _update(
        AuthNotifierState(
          isAuthenticated: _state.isAuthenticated,
          isInitializing: _state.isInitializing,
          isLoading: false,
          email: _state.email,
        ),
      );
    }
  }

  // ── Mapeo de errores a mensajes de UI ────────────────────────────────────

  String _mapSignInError(ApiException e) {
    return switch (e.type) {
      ApiErrorType.unauthorized =>
        'Credenciales incorrectas. Verifica tus datos.',
      ApiErrorType.networkError =>
        'Sin conexión con el servidor. Verifica tu internet.',
      ApiErrorType.badRequest => 'Correo o contraseña inválidos.',
      _ => e.message,
    };
  }

  String _mapSignUpError(ApiException e) {
    return switch (e.type) {
      ApiErrorType.conflict => 'Este correo ya está registrado.',
      ApiErrorType.networkError =>
        'Sin conexión con el servidor. Verifica tu internet.',
      ApiErrorType.badRequest => 'Verifica los datos ingresados.',
      _ => e.message,
    };
  }
}
