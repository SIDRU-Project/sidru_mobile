import 'dart:convert';
import 'dart:math';

import 'browser_session.dart';

/// Resultado de leer la vuelta de Google en `/auth/google/callback`.
sealed class GoogleCallbackResult {
  const GoogleCallbackResult();
}

/// `state` válido e `id_token` presente: [nonce] es el que se guardó al salir.
class GoogleCallbackSuccess extends GoogleCallbackResult {
  final String idToken;
  final String nonce;
  const GoogleCallbackSuccess(this.idToken, this.nonce);
}

/// El usuario canceló en Google (`error=access_denied`): se vuelve al onboarding sin mensaje.
class GoogleCallbackCancelled extends GoogleCallbackResult {
  const GoogleCallbackCancelled();
}

/// `state` ausente o distinto, otro error o sin token: mensaje y vuelta al onboarding.
class GoogleCallbackInvalid extends GoogleCallbackResult {
  const GoogleCallbackInvalid();
}

/// Login con Google por OpenID Connect con redirección (`response_type=id_token`, design §3.3).
/// No usa client secret. `state` evita el login CSRF y `nonce` liga el token a esta sesión del
/// navegador; ambos viven en sessionStorage y se consumen siempre, salga bien o mal.
class GoogleRedirectFlow {
  static const callbackPath = '/auth/google/callback';
  static const stateKey = 'sidru.google.state';
  static const nonceKey = 'sidru.google.nonce';

  final BrowserSession _browser;
  final Random _random;
  bool _callbackConsumed = false;

  GoogleRedirectFlow(this._browser, {Random? random})
    : _random = random ?? Random.secure();

  /// 32 bytes aleatorios en base64url sin relleno.
  String _newToken() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String get redirectUri => '${_browser.origin}$callbackPath';

  /// URL de autorización de Google. Los espacios van como %20 (no como +).
  String authorizationUrl({
    required String clientId,
    required String state,
    required String nonce,
  }) {
    final params = <String, String>{
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'id_token',
      'scope': 'openid email profile',
      'state': state,
      'nonce': nonce,
      'prompt': 'select_account',
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return 'https://accounts.google.com/o/oauth2/v2/auth?$query';
  }

  /// Genera `state` y `nonce`, los guarda en sessionStorage y sale hacia Google.
  void start(String clientId) {
    final state = _newToken();
    final nonce = _newToken();
    _browser.setItem(stateKey, state);
    _browser.setItem(nonceKey, nonce);
    _browser.navigate(
      authorizationUrl(clientId: clientId, state: state, nonce: nonce),
    );
  }

  /// Lee la vuelta de Google: borra el fragmento del historial en el acto, compara y CONSUME
  /// `state` y `nonce` (se borran siempre). Solo la primera llamada lee datos: una segunda (o una
  /// recarga, donde ya no hay fragmento ni state) no puede reutilizarlos.
  GoogleCallbackResult consumeCallback() {
    final fragment = _callbackConsumed ? '' : _browser.initialFragment;
    _callbackConsumed = true;
    _browser.clearUrlFragment();

    final savedState = _browser.getItem(stateKey);
    final savedNonce = _browser.getItem(nonceKey);
    _browser.removeItem(stateKey);
    _browser.removeItem(nonceKey);

    Map<String, String> params;
    try {
      params = fragment.isEmpty ? const {} : Uri.splitQueryString(fragment);
    } on FormatException {
      return const GoogleCallbackInvalid();
    }

    final state = params['state'];
    if (savedState == null ||
        state == null ||
        !_constantTimeEquals(savedState, state)) {
      return const GoogleCallbackInvalid();
    }
    final error = params['error'];
    if (error != null) {
      return error == 'access_denied'
          ? const GoogleCallbackCancelled()
          : const GoogleCallbackInvalid();
    }
    final idToken = params['id_token'];
    if (idToken == null || idToken.isEmpty || savedNonce == null) {
      return const GoogleCallbackInvalid();
    }
    return GoogleCallbackSuccess(idToken, savedNonce);
  }

  static bool _constantTimeEquals(String a, String b) {
    final x = utf8.encode(a);
    final y = utf8.encode(b);
    if (x.length != y.length) return false;
    var diff = 0;
    for (var i = 0; i < x.length; i++) {
      diff |= x[i] ^ y[i];
    }
    return diff == 0;
  }
}
