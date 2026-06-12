import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/status_chip.dart';

/// Card de la última sesión de reciclaje.
/// Empty state: texto centrado simple como en el prototipo.
/// Con sesión: card con id, bin, peso, puntos, estado y fecha.
/// Phase 6 conectará SessionProvider y pasará datos reales.
class LastSessionCard extends StatelessWidget {
  final VoidCallback? onScanTap;
  final VoidCallback? onDetailTap;
  final LastSessionData? session;

  const LastSessionCard({
    super.key,
    this.onScanTap,
    this.onDetailTap,
    this.session,
  });

  @override
  Widget build(BuildContext context) {
    if (session != null) {
      return _SessionPreview(session: session!, onTap: onDetailTap);
    }
    return _EmptySessionCard(onScanTap: onScanTap);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
// Estilo del prototipo: card glass con texto centrado simple

class _EmptySessionCard extends StatelessWidget {
  final VoidCallback? onScanTap;
  const _EmptySessionCard({this.onScanTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onScanTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF131829),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: const Text(
          'Aún no tienes sesiones. ¡Escanea tu primer QR!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}

// ── Preview de sesión ─────────────────────────────────────────────────────────
// Estilo del prototipo: id · bin, peso grande + pts, fecha, StatusChip, chevron

class _SessionPreview extends StatelessWidget {
  final LastSessionData session;
  final VoidCallback? onTap;
  const _SessionPreview({required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF131829),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // id · binId
                  Text(
                    '${session.id} · '
                    'BIN-${session.smartBinId.toString().padLeft(3, '0')}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // peso + puntos en baseline
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        session.weightKg,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '+${session.pointsEarned} pts',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.date,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status: session.status),
                const SizedBox(height: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// DTO para pasar datos al widget sin depender de RecyclingSession directamente.
/// Phase 6 creará una conversión RecyclingSession → LastSessionData.
class LastSessionData {
  final String id;
  final int smartBinId;
  final String weightKg;
  final int pointsEarned;
  final String status;
  final String date;

  const LastSessionData({
    required this.id,
    required this.smartBinId,
    required this.weightKg,
    required this.pointsEarned,
    required this.status,
    required this.date,
  });
}
