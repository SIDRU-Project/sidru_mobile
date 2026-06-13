import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/weight_formatter.dart';
import '../../data/models/recycling_session.dart';
import 'session_status_chip.dart';

/// Ítem de lista para [RecyclingSession] en HistoryScreen.
/// Alineado al prototipo: ícono verde, datos en columna, puntos a la derecha.
class SessionCard extends StatelessWidget {
  final RecyclingSession session;
  final VoidCallback onTap;

  const SessionCard({super.key, required this.session, required this.onTap});

  String get _weightKg => WeightFormatter.gramsToKg(session.weightGrams);

  String get _displayId => '#${session.id}';

  String get _binLabel =>
      'BIN-${session.smartBinId.toString().padLeft(3, '0')}';

  String get _date {
    final dt = session.confirmedAt ?? session.expiresAt;
    if (dt == null) return '—';
    return DateFormat('dd MMM · HH:mm', 'es').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final hasPoints = session.pointsEarned > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF131829),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            // ── Ícono verde ───────────────────────────────────────────────
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Icons.recycling_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // ── Datos principales ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID + chip de estado
                  Row(
                    children: [
                      Text(
                        _displayId,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SessionStatusChip(status: session.status),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Fecha · BIN
                  Text(
                    '$_date · $_binLabel',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Peso · chapas
                  Row(
                    children: [
                      Text(
                        _weightKg,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${session.capCount} caps',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Puntos ────────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${session.pointsEarned}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        hasPoints ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
                const Text(
                  'pts',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
