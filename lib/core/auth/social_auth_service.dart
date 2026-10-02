import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Envuelve google_sign_in. Solo entrega el ID token de Google; canjearlo por el JWT de
/// SIDRU es trabajo de AuthRepository. El client ID lo da el backend (no va compilado).
///
/// Web: el SDK (GIS) solo inicia sesión con su botón oficial; el token llega por
/// `authenticationEvents`. Nativo: [authenticate] abre el selector de cuentas.
class SocialAuthService {
  bool _initialized = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _sub;

  bool get isInitialized => _initialized;

  /// Inicializa una sola vez y empieza a escuchar. [onIdToken] recibe cada token nuevo;
  /// [onError] los fallos del SDK (no incluye la cancelación del usuario).
  Future<void> init(
    String clientId, {
    required void Function(String idToken) onIdToken,
    required void Function(Object error) onError,
  }) async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      // En web basta clientId; en Android el idToken exige serverClientId (el client ID web).
      clientId: kIsWeb ? clientId : null,
      serverClientId: kIsWeb ? null : clientId,
    );
    _initialized = true;
    _sub = GoogleSignIn.instance.authenticationEvents.listen(
      (event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          final token = event.user.authentication.idToken;
          if (token != null) onIdToken(token);
        }
      },
      onError: (Object e) {
        if (e is GoogleSignInException &&
            e.code == GoogleSignInExceptionCode.canceled) {
          return;
        }
        onError(e);
      },
    );
  }

  /// Solo plataformas nativas: abre el selector de cuentas. El token sale por [init].onIdToken.
  Future<void> authenticate() async {
    if (!_initialized || !GoogleSignIn.instance.supportsAuthenticate()) return;
    try {
      await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) rethrow;
    }
  }

  /// Best-effort: cierra la sesión de Google para que el siguiente acceso pida cuenta.
  Future<void> signOut() async {
    if (!_initialized) return;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
