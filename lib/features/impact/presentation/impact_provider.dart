import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/impact_repository.dart';
import '../data/metrics_api.dart';
import '../data/models/impact_metrics.dart';

// ── Cadena de dependencias ────────────────────────────────────────────────────

final metricsApiProvider = Provider<MetricsApi>((ref) {
  return MetricsApi(ref.watch(apiClientProvider));
});

final impactRepositoryProvider = Provider<ImpactRepository>((ref) {
  return ImpactRepository(ref.watch(metricsApiProvider));
});

/// Métricas globales de impacto. autoDispose: se re-consulta al reabrir la pantalla.
final impactProvider = FutureProvider.autoDispose<ImpactMetrics>((ref) {
  return ref.watch(impactRepositoryProvider).getMetrics();
});
