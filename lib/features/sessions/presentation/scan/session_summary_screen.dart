import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/weight_formatter.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../data/models/recycling_session.dart';
import '../widgets/session_status_chip.dart';

/// Resumen de la sesión consultada por QR.
/// Solo permite confirmar si status == PENDING.
class SessionSummaryScreen extends ConsumerWidget {
  final RecyclingSession session;
  const SessionSummaryScreen({super.key, required this.session});

  static final _dtFmt = DateFormat('dd MMM yyyy · HH:mm', 'es');

  String _fmt(DateTime? dt) => dt != null ? _dtFmt.format(dt) : '—';

  String get _weightKg => WeightFormatter.gramsToKg(session.weightGrams);

  String get _binCode =>
      'BIN-${session.smartBinId.toString().padLeft(3, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = session.status == RecyclingSessionStatus.pending;
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Resumen de sesión',
              subtitle: 'QR detectado correctamente',
              showBack: true,
              onBack: () => context.go(RouteNames.scan),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Hero: puntos estimados ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.18),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            const Color(0x05FFFFFF),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          // Badge de estado
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPending
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.info_outline_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isPending ? 'SESIÓN VÁLIDA' : 'NO DISPONIBLE',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ShaderMask(
                            shaderCallback:
                                (b) =>
                                    AppColors.primaryGradient.createShader(b),
                            child: Text(
                              '${session.pointsEarned}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'PUNTOS ESTIMADOS',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: AppColors.textTertiary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Detalle ────────────────────────────────────────────
                    _InfoCard(
                      rows: [
                        _Row('ID de sesión', '#${session.id}'),
                        _Row('Smart Bin', _binCode),
                        _Row('Chapas registradas', '${session.capCount} caps'),
                        _Row('Peso acumulado', _weightKg),
                        _StatusRow(status: session.status),
                        _Row('Expira', _fmt(session.expiresAt)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── Acción según estado ────────────────────────────────
                    if (isPending)
                      GradientButton(
                        label: 'Confirmar entrega',
                        onPressed:
                            () => context.push(
                              RouteNames.scanConfirm,
                              extra: session,
                            ),
                      )
                    else
                      _BlockedNotice(status: session.status),

                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: TextButton(
                        onPressed: () => context.go(RouteNames.home),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets privados ──────────────────────────────────────────────────────────

class _Row {
  final String key;
  final String value;
  const _Row(this.key, this.value);
}

class _StatusRow extends _Row {
  final RecyclingSessionStatus status;
  const _StatusRow({required this.status}) : super('Estado', '');
}

class _InfoCard extends StatelessWidget {
  final List<_Row> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final r = rows[i];
          final isLast = i == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border:
                  isLast
                      ? null
                      : const Border(
                        bottom: BorderSide(color: AppColors.borderSubtle),
                      ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  r.key,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (r is _StatusRow)
                  SessionStatusChip(status: r.status)
                else
                  Flexible(
                    child: Text(
                      r.value,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Aviso cuando la sesión no es PENDING (no se puede confirmar).
class _BlockedNotice extends StatelessWidget {
  final RecyclingSessionStatus status;
  const _BlockedNotice({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.warning, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta sesión no está pendiente, por lo que no puede confirmarse.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
