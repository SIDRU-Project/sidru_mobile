import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/weight_formatter.dart';
import '../../data/models/recycling_session.dart';

/// Card de resumen numérico en la parte superior del HistoryScreen.
/// Muestra: total de sesiones, peso total, puntos totales.
/// Alineada al prototipo: tres columnas con divisores verticales.
class SessionSummaryCard extends StatelessWidget {
  final List<RecyclingSession> sessions;

  const SessionSummaryCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final total = sessions.length;
    final totalGrams = sessions.fold(0.0, (sum, s) => sum + s.weightGrams);
    final totalPoints = sessions.fold(0, (sum, s) => sum + s.pointsEarned);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131829),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          _Stat(label: 'Sesiones', value: total.toString()),
          _Divider(),
          _Stat(label: 'Peso', value: WeightFormatter.gramsToKg(totalGrams)),
          _Divider(),
          _Stat(
            label: 'Puntos',
            value: totalPoints.toString(),
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Stat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.borderSubtle,
    );
  }
}
