import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/weight_formatter.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../data/models/recycling_session.dart';
import '../session_provider.dart';
import '../widgets/session_status_chip.dart';

class SessionDetailScreen extends ConsumerWidget {
  final int sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: sessionAsync.when(
        loading: () => const LoadingState(),
        error:
            (e, _) => ErrorState(
              message: 'No se pudo cargar el detalle de la sesión.',
              onRetry: () => ref.invalidate(sessionDetailProvider(sessionId)),
            ),
        data: (session) => _DetailContent(session: session),
      ),
    );
  }
}

// ── Contenido ─────────────────────────────────────────────────────────────────

class _DetailContent extends ConsumerWidget {
  final RecyclingSession session;
  const _DetailContent({required this.session});

  static final _dtFmt = DateFormat('dd MMM yyyy · HH:mm', 'es');

  String _fmt(DateTime? dt) => dt != null ? _dtFmt.format(dt) : '—';

  String get _weightKg => WeightFormatter.gramsToKg(session.weightGrams);

  String get _binCode =>
      'BIN-${session.smartBinId.toString().padLeft(3, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Smart bin carga silenciosa — fallo no rompe pantalla
    final binAsync = ref.watch(smartBinProvider(session.smartBinId));
    final bottomPad = MediaQuery.of(context).padding.bottom + 100.0;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalle de sesión',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          '#${session.id}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SessionStatusChip(status: session.status),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Cards de stats principales ─────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Puntos generados',
                        value: '${session.pointsEarned}',
                        valueColor: AppColors.primary,
                        gradient: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Chapas',
                        value: '${session.capCount}',
                        valueColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Sección: datos de la sesión ────────────────────────
                _SectionLabel('Datos de la sesión'),
                const SizedBox(height: 8),
                _InfoCard(
                  rows: [
                    _Row('ID de sesión', '#${session.id}'),
                    _Row('Smart Bin', _binCode),
                    _Row('Peso acumulado', _weightKg),
                    _Row('Chapas registradas', '${session.capCount} caps'),
                    _Row('Token QR', session.qrToken, mono: true, small: true),
                    _Row('Expira', _fmt(session.expiresAt)),
                    _Row('Confirmada', _fmt(session.confirmedAt)),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Sección: Smart Bin (si carga OK) ──────────────────
                binAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data:
                      (bin) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('Smart Bin'),
                          const SizedBox(height: 8),
                          _InfoCard(
                            rows: [
                              _Row('Código', bin.deviceCode, mono: true),
                              _Row('Ubicación', bin.location),
                              _Row('Distrito', bin.district),
                              _Row('Estado', bin.status),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                ),

                // ── Sección: Blockchain ────────────────────────────────
                _SectionLabel('Blockchain'),
                const SizedBox(height: 8),
                _BlockchainCard(txHash: session.blockchainTxHash),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets privados ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool gradient;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131829),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: AppColors.textTertiary,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          if (gradient)
            ShaderMask(
              shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// Row data para InfoCard
class _Row {
  final String key;
  final String value;
  final bool mono;
  final bool small;
  const _Row(this.key, this.value, {this.mono = false, this.small = false});
}

class _InfoCard extends StatelessWidget {
  final List<_Row> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131829),
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
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    r.value,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: r.mono ? 'monospace' : null,
                      fontSize: r.small ? 11 : 13,
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

class _BlockchainCard extends StatelessWidget {
  final String? txHash;
  const _BlockchainCard({this.txHash});

  @override
  Widget build(BuildContext context) {
    final hasHash = txHash != null && txHash!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131829),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              hasHash
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasHash
                    ? Icons.check_circle_outline_rounded
                    : Icons.hourglass_empty_rounded,
                color: hasHash ? AppColors.primary : AppColors.textTertiary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                hasHash ? 'Transacción confirmada' : 'Sin registro blockchain',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: hasHash ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (hasHash) ...[
            const SizedBox(height: 10),
            const Text(
              'Hash de transacción',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: AppColors.textTertiary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              txHash!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                color: AppColors.textPrimary,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'Esta sesión aún no tiene transacción blockchain registrada.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF131829),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }
}
