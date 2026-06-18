import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../sessions/data/models/recycling_session.dart';
import '../../sessions/presentation/session_provider.dart';
import '../../user/data/models/user_profile.dart';
import '../../user/presentation/user_provider.dart';
import 'widgets/home_summary_card.dart';
import 'widgets/last_session_card.dart';
import 'widgets/quick_action_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: profileAsync.when(
        loading: () => const LoadingState(),
        error:
            (e, _) => ErrorState(
              message:
                  e.toString().contains('Sin conexión')
                      ? 'Sin conexión con el servidor.\nVerifica tu internet.'
                      : 'No se pudo cargar tu perfil.',
              onRetry: () => ref.read(userNotifierProvider.notifier).refresh(),
            ),
        data:
            (profile) =>
                profile == null
                    ? const LoadingState()
                    : _HomeContent(profile: profile),
      ),
    );
  }
}

// ── Helper: RecyclingSession → LastSessionData ────────────────────────────────

LastSessionData? _toLastSessionData(RecyclingSession? s) {
  if (s == null) return null;
  final dtFmt = DateFormat('dd MMM · HH:mm', 'es');
  final dt = s.confirmedAt ?? s.expiresAt;
  return LastSessionData(
    id: '#${s.id}',
    smartBinId: s.smartBinId,
    weightKg: WeightFormatter.gramsToKg(s.weightGrams),
    pointsEarned: s.pointsEarned,
    status: s.status.name.toUpperCase(),
    date: dt != null ? dtFmt.format(dt) : '—',
  );
}

// ── Contenido principal ───────────────────────────────────────────────────────

class _HomeContent extends ConsumerWidget {
  final UserProfile profile;
  const _HomeContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Última sesión desde SessionProvider — fallo silencioso (no rompe Home)
    final lastSession = _toLastSessionData(
      ref.watch(sessionListProvider).valueOrNull?.firstOrNull,
    );

    // Altura estimada del nav flotante + safeArea bottom
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;

    return Stack(
      children: [
        // ── Auras de fondo (como el prototipo) ───────────────────────────────
        Positioned(
          right: -80,
          top: -80,
          child: _GlowOrb(
            size: 300,
            color: AppColors.primary.withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          left: -100,
          bottom: 200,
          child: _GlowOrb(
            size: 280,
            color: AppColors.secondary.withValues(alpha: 0.10),
          ),
        ),

        // ── Scroll principal ─────────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _HomeHeader(profile: profile)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Stats: puntos + chapas ─────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: HomeSummaryCard(
                            label: 'Puntos',
                            value: profile.totalPoints.toLocaleString(),
                            subtitle: 'acumulados',
                            accentColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HomeSummaryCard(
                            label: 'Chapas',
                            value: profile.totalCaps.toString(),
                            subtitle: 'depositadas',
                            accentColor: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Wallet card (placeholder — C4 preparado) ──────────
                    const _WalletPreviewCard(),
                    const SizedBox(height: 10),

                    // ── Impacto ambiental ──────────────────────────────────
                    const _ImpactPreviewCard(),
                    const SizedBox(height: 14),

                    // ── CTA Escanear QR ────────────────────────────────────
                    _GradientQrButton(onTap: () => context.go(RouteNames.scan)),
                    const SizedBox(height: 18),

                    // ── Última sesión ──────────────────────────────────────
                    _SectionHeader(
                      label: 'Última sesión',
                      actionLabel: 'Ver historial',
                      onAction: () => context.go(RouteNames.history),
                    ),
                    const SizedBox(height: 8),
                    LastSessionCard(
                      session: lastSession,
                      onScanTap: () => context.go(RouteNames.scan),
                      onDetailTap:
                          lastSession != null
                              ? () => context.push(
                                '/history/${ref.read(sessionListProvider).valueOrNull?.firstOrNull?.id}',
                              )
                              : null,
                    ),
                    const SizedBox(height: 14),

                    // ── Accesos rápidos ────────────────────────────────────
                    _SectionHeader(label: 'Accesos rápidos'),
                    const SizedBox(height: 8),
                    _QuickGrid(totalSessions: profile.totalSessions),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final UserProfile profile;
  const _HomeHeader({required this.profile});

  String get _initial =>
      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U';

  String get _firstName => profile.fullName.split(' ').first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          // Avatar circular con doble anillo gradiente
          // `go` (no `push`): /profile es un tab del ShellRoute; cambiar de rama
          // del shell se hace con go, igual que el bottom nav y los demás botones
          // del home. Con push el shell no cambia de tab y se queda en home.
          GestureDetector(
            onTap: () => context.go(RouteNames.profile),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B2138),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HOLA',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  _firstName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // Botón de notificaciones (placeholder)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF131829),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wallet card ───────────────────────────────────────────────────────────────
// Acceso rápido a la WalletScreen (ya implementada): ícono + texto + chip "Activa".
// Navega a RouteNames.wallet al tocar.

class _WalletPreviewCard extends StatelessWidget {
  const _WalletPreviewCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.wallet),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF131829),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            // Ícono wallet (verde = disponible)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.success,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // Texto
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Toca para ver tu balance de CTC',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Chip estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'Activa',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Impacto ambiental card ────────────────────────────────────────────────────
// Acceso a la pantalla de impacto global (US-36). Navega a RouteNames.impact.

class _ImpactPreviewCard extends StatelessWidget {
  const _ImpactPreviewCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.impact),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF131829),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.eco_outlined,
                color: AppColors.secondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Impacto ambiental',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'CO₂ evitado y plástico reciclado',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Botón Escanear QR ─────────────────────────────────────────────────────────
// Alto 60, gradiente, sin borde, glow verde sutil

class _GradientQrButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GradientQrButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              color: Color(0xFF0A0E1A),
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Escanear QR',
              style: TextStyle(
                color: Color(0xFF0A0E1A),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header de sección ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.label, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
            letterSpacing: 0.8,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.secondary,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Grid de acciones rápidas (2 cards como el prototipo) ──────────────────────

class _QuickGrid extends StatelessWidget {
  final int totalSessions;
  const _QuickGrid({required this.totalSessions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QuickActionCard(
            icon: Icons.history_rounded,
            label: 'Historial',
            subtitle: '$totalSessions sesiones',
            iconColor: AppColors.secondary,
            onTap: () => context.go(RouteNames.history),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: QuickActionCard(
            icon: Icons.card_giftcard_outlined,
            label: 'Recompensas',
            subtitle: 'Canjear puntos',
            iconColor: AppColors.primary,
            onTap: () => context.go(RouteNames.rewards),
          ),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

extension on int {
  String toLocaleString() {
    final s = toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
