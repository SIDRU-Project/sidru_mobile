import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/notifications/fcm_handler.dart';
import '../../../core/router/app_router.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';

// Providers de la cadena de dependencias

// Tipo anotado explícitamente: el callback onUnauthorized referencia
// authNotifierProvider (api → repository → notifier → api), lo que crearía un
// ciclo de INFERENCIA de tipos. Anotar el tipo lo saca del grafo de inferencia
// y rompe el ciclo; en runtime no hay ciclo porque el callback es diferido.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  // El callback es diferido (solo se invoca cuando llega un 401): para entonces
  // authNotifierProvider ya está construido, así que el ref.read no genera ciclo.
  return ApiClient(
    storage,
    onUnauthorized:
        () => ref.read(authNotifierProvider.notifier).handleSessionExpired(),
  );
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

// Estado de autenticación

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

// Notifier

/// Gestiona el ciclo de vida de autenticación.
/// Extiende ChangeNotifier para que GoRouter lo use como refreshListenable.
///
/// Flujo:
///   Arranque → _restoreSession() → si hay token válido, isAuthenticated = true
///   signIn()  → POST /authentication/sign-in → guarda JWT → isAuthenticated = true
///   signUp()  → POST /authentication/sign-up → devuelve bool (UI navega a login)
///   logout()  → borra JWT → isAuthenticated = false
///
/// Cada vez que una sesión empieza o termina (signIn/restauración exitosos, logout,
/// expiración) se incrementa [sessionEpoch]. Los providers por-usuario lo observan junto
/// a isAuthenticated para reconstruirse en cada cambio de sesión, incluso si isAuthenticated
/// no cambia entre dos sesiones consecutivas.
class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repository;
  final FcmHandler _fcmHandler;
  AuthNotifierState _state = const AuthNotifierState(isInitializing: true);
  int _sessionEpoch = 0;

  AuthNotifierState get state => _state;
  int get sessionEpoch => _sessionEpoch;

  AuthNotifier(this._repository, this._fcmHandler) {
    _restoreSession();
  }

  void _update(AuthNotifierState newState) {
    _state = newState;
    notifyListeners();
  }

  // Restaurar sesión al arrancar

  Future<void> _restoreSession() async {
    try {
      final profile = await _repository.tryRestoreSession();
      if (profile != null) {
        _sessionEpoch++;
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

  // Sign In

  Future<void> signIn(String email, String password) async {
    _update(_state.withLoading());
    try {
      final response = await _repository.signIn(email, password);
      _sessionEpoch++;
      _update(_state.withAuthenticated(response.email));
      // FCM: suscribe al ciudadano a su topic user-{userId} (best-effort).
      unawaited(_fcmHandler.subscribeToUser(response.id));
    } on ApiException catch (e) {
      _update(_state.withError(_mapSignInError(e)));
    } catch (_) {
      _update(_state.withError('Error inesperado. Intenta de nuevo.'));
    }
  }

  // Sign Up

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

  // Sesión expirada (401 en request autenticado)

  /// Llamado por el [JwtInterceptor] cuando un request autenticado recibe 401
  /// (el token ya fue borrado por el interceptor). Refleja la expiración en el
  /// estado para que el router redirija y el usuario vea el motivo al volver a
  /// login. Ignora los 401 de sign-in/sign-up (aún no autenticado): esos los
  /// maneja cada flujo con su propio banner, sin pisarlos aquí.
  Future<void> handleSessionExpired() async {
    // La guarda + el incremento de epoch + _update van síncronos, antes del primer await:
    // cierran la ventana de "autenticado" de inmediato, así que dos 401 en cadena (o un
    // logout concurrente) no pueden pasar ambos la guarda y duplicar el borrado/epoch.
    if (!_state.isAuthenticated) return;
    unawaited(_fcmHandler.unsubscribeCurrent());
    _sessionEpoch++;
    _update(
      const AuthNotifierState(
        errorMessage: 'Tu sesión expiró. Inicia sesión de nuevo.',
      ),
    );
    // El interceptor ya borró el JWT; falta el resto del caché por-usuario (wallet, etc.).
    await _repository.logout();
  }

  // Logout

  Future<void> logout() async {
    // Idempotente: la guarda + el incremento de epoch + _update van síncronos, antes del
    // primer await, para cerrar la ventana de inmediato. Si no, dos logout() concurrentes
    // (o un 401 en cadena junto a un logout manual) pasarían ambos la guarda y producirían
    // dos borrados y dos epochs.
    if (!_state.isAuthenticated) return;
    // FCM: desuscribe del topic del usuario antes de limpiar la sesión (best-effort).
    unawaited(_fcmHandler.unsubscribeCurrent());
    _sessionEpoch++;
    _update(_state.cleared());
    await _repository.logout();
  }

  // Utilidades

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

  // Mapeo de errores a mensajes de UI

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
