import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'jwt_interceptor.dart';

/// Cliente HTTP único de la app.
/// Toda comunicación con el backend pasa por aquí.
/// Las pantallas nunca deben usar Dio directamente.
class ApiClient {
  late final Dio _dio;

  ApiClient(SecureStorage storage, {void Function()? onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      JwtInterceptor(storage, onUnauthorized: onUnauthorized),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}
