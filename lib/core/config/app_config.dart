import 'env.dart';

class AppConfig {
  static String get apiBaseUrl => Env.apiBaseUrl;
  static String get appName => Env.appName;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
