import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_error_mapper.dart';
import 'models/impact_metrics.dart';

/// Datasource HTTP de métricas globales e impacto (US-36).
class MetricsApi {
  final ApiClient _client;

  MetricsApi(this._client);

  /// GET /metrics — métricas globales de la plataforma.
  Future<ImpactMetrics> getMetrics() async {
    try {
      final res = await _client.get('/metrics');
      return ImpactMetrics.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }
}
