import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl {
    final configured =
        dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api/v1';

    if (kIsWeb) {
      return configured.replaceFirst('10.0.2.2', 'localhost');
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return configured.replaceFirst('localhost', '10.0.2.2');
    }

    return configured;
  }

  static String get appName => dotenv.env['APP_NAME'] ?? 'SIDRU';
}
