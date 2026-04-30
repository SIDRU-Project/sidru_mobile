import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

/// Interceptor de Dio que:
/// 1. Inyecta `Authorization: Bearer <token>` en cada request privado.
/// 2. Detecta respuestas 401 y dispara el callback `onUnauthorized`
///    (que en Phase 4 limpia el JWT y redirige a /login).
class JwtInterceptor extends Interceptor {
  final SecureStorage _storage;

  /// Callback invocado cuando el backend responde 401.
  /// Se conecta al router en Phase 4.
  final void Function()? onUnauthorized;

  JwtInterceptor(this._storage, {this.onUnauthorized});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.deleteToken();
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
