/// Métricas globales de la plataforma + impacto ambiental estimado (US-36).
/// Modelo plano (sin codegen): el backend devuelve `impact` anidado, aquí se aplana.
class ImpactMetrics {
  final int totalSessions;
  final int confirmedSessions;
  final int capsRecycled;
  final double weightKg;
  final int ctcMinted;
  final int registeredUsers;
  final int activeBins;
  final double co2AvoidedKg;
  final double energySavedKwh;

  const ImpactMetrics({
    required this.totalSessions,
    required this.confirmedSessions,
    required this.capsRecycled,
    required this.weightKg,
    required this.ctcMinted,
    required this.registeredUsers,
    required this.activeBins,
    required this.co2AvoidedKg,
    required this.energySavedKwh,
  });

  factory ImpactMetrics.fromJson(Map<String, dynamic> json) {
    final impact = (json['impact'] as Map<String, dynamic>?) ?? const {};
    return ImpactMetrics(
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      confirmedSessions: (json['confirmedSessions'] as num?)?.toInt() ?? 0,
      capsRecycled: (json['capsRecycled'] as num?)?.toInt() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      ctcMinted: (json['ctcMinted'] as num?)?.toInt() ?? 0,
      registeredUsers: (json['registeredUsers'] as num?)?.toInt() ?? 0,
      activeBins: (json['activeBins'] as num?)?.toInt() ?? 0,
      co2AvoidedKg: (impact['co2AvoidedKg'] as num?)?.toDouble() ?? 0,
      energySavedKwh: (impact['energySavedKwh'] as num?)?.toDouble() ?? 0,
    );
  }
}
