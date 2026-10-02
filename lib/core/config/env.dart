import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  /// URL de la API inyectada en la compilación web con `--dart-define API_BASE_URL=...`.
  static const _webApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    // Web: la app se sirve desde el mismo origen que la API (Caddy), así que por
    // defecto usa `Uri.base.origin`. El `.env` no interviene (no se incluye en la web).
    if (kIsWeb) {
      return _webApiBaseUrl.isNotEmpty
          ? _webApiBaseUrl
          : '${Uri.base.origin}/api/v1';
    }

    final configured =
        dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api/v1';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return configured.replaceFirst('localhost', '10.0.2.2');
    }

    return configured;
  }

  static String get appName => dotenv.env['APP_NAME'] ?? 'SIDRU';
}
