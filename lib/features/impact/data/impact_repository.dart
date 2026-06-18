import 'metrics_api.dart';
import 'models/impact_metrics.dart';

class ImpactRepository {
  final MetricsApi _api;

  ImpactRepository(this._api);

  Future<ImpactMetrics> getMetrics() => _api.getMetrics();
}
