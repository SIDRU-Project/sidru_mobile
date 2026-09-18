enum ApiErrorType {
  unauthorized, // 401 – token inválido o expirado
  forbidden, // 403 – sin permisos
  notFound, // 404 – recurso no encontrado
  conflict, // 409 – estado conflictivo (QR ya confirmado, sin stock, retiro en curso…)
  badRequest, // 400 – datos inválidos
  unprocessableEntity, // 422 – la petición es válida pero no se puede procesar (p. ej. puntos insuficientes)
  serviceUnavailable, // 503 – funcionalidad temporalmente deshabilitada (p. ej. retiros)
  serverError, // 500 – error interno del servidor
  networkError, // timeout / sin conexión
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;

  const ApiException({
    required this.message,
    this.statusCode,
    required this.type,
  });

  bool get isUnauthorized => type == ApiErrorType.unauthorized;
  bool get isNetworkError => type == ApiErrorType.networkError;
  bool get isNotFound => type == ApiErrorType.notFound;
  bool get isConflict => type == ApiErrorType.conflict;
  bool get isUnprocessableEntity => type == ApiErrorType.unprocessableEntity;
  bool get isServiceUnavailable => type == ApiErrorType.serviceUnavailable;

  @override
  String toString() => 'ApiException[$type|$statusCode]: $message';
}
