enum ApiErrorType {
  unauthorized, // 401 – token inválido o expirado
  forbidden, // 403 – sin permisos
  notFound, // 404 – recurso no encontrado
  conflict, // 409 – estado conflictivo (QR ya confirmado, sin stock…)
  badRequest, // 400 – datos inválidos
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

  @override
  String toString() => 'ApiException[$type|$statusCode]: $message';
}
