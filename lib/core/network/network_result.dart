import 'api_exception.dart';

/// Resultado sellado para operaciones de red.
/// Los repositorios devuelven `Success<T>` o `Failure<T>`.
sealed class NetworkResult<T> {
  const NetworkResult();
}

final class Success<T> extends NetworkResult<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends NetworkResult<T> {
  final ApiException exception;
  const Failure(this.exception);
}

extension NetworkResultX<T> on NetworkResult<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(data: final d) => d,
    Failure<T>() => null,
  };

  ApiException? get errorOrNull => switch (this) {
    Failure<T>(exception: final e) => e,
    Success<T>() => null,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) => switch (this) {
    Success<T>(data: final d) => success(d),
    Failure<T>(exception: final e) => failure(e),
  };
}
