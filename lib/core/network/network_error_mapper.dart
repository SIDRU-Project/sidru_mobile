import 'package:dio/dio.dart';
import 'api_exception.dart';

class NetworkErrorMapper {
  static ApiException map(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Sin conexión con el servidor. Verifica tu internet.',
          type: ApiErrorType.networkError,
        );
      case DioExceptionType.badResponse:
        return _fromStatus(e.response?.statusCode, e.response?.data);
      default:
        return ApiException(
          message: e.message ?? 'Error desconocido.',
          type: ApiErrorType.unknown,
        );
    }
  }

  static ApiException _fromStatus(int? code, dynamic data) {
    final msg = _extractMessage(data);
    switch (code) {
      case 400:
        return ApiException(
          message: msg ?? 'Datos inválidos. Verifica la información.',
          statusCode: code,
          type: ApiErrorType.badRequest,
        );
      case 401:
        return ApiException(
          message: msg ?? 'Sesión expirada. Inicia sesión nuevamente.',
          statusCode: code,
          type: ApiErrorType.unauthorized,
        );
      case 403:
        return ApiException(
          message: msg ?? 'No tienes permiso para esta acción.',
          statusCode: code,
          type: ApiErrorType.forbidden,
        );
      case 404:
        return ApiException(
          message: msg ?? 'Recurso no encontrado.',
          statusCode: code,
          type: ApiErrorType.notFound,
        );
      case 409:
        return ApiException(
          message: msg ?? 'Conflicto con el estado actual.',
          statusCode: code,
          type: ApiErrorType.conflict,
        );
      default:
        return ApiException(
          message: msg ?? 'Error del servidor. Intenta de nuevo.',
          statusCode: code,
          type: ApiErrorType.serverError,
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error']) as String?;
    }
    return null;
  }
}
