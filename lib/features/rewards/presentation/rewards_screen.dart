import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../user/presentation/user_provider.dart';
import 'rewards_provider.dart';
import 'widgets/reward_card.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardsListProvider);
    final points = ref.watch(userNotifierProvider).valueOrNull?.totalPoints;
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recompensas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  // Acceso a historial de transacciones
                  GestureDetector(
                    onTap: () => context.push(RouteNames.rewardsTransactions),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.textSecondary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Banner de puntos disponibles ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PointsBanner(points: points),
            ),
            const SizedBox(height: 16),

            // ── Catálogo ───────────────────────────────────────────────────
            Expanded(
              child: rewardsAsync.when(
                loading: () => const LoadingState(),
                error:
                    (e, _) => ErrorState(
                      message:
                          e.toString().contains('Sin conexión')
                              ? 'Sin conexión. Verifica tu internet.'
                              : 'No se pudieron cargar las recompensas.',
                      onRetry:
                          () =>
                              ref.read(rewardsListProvider.notifier).refresh(),
                    ),
                data: (rewards) {
                  if (rewards.isEmpty) {
                    return const EmptyState(
                      title: 'Sin recompensas',
                      subtitle:
                          'Aún no hay recompensas disponibles. Vuelve pronto.',
                      icon: Icons.card_giftcard_outlined,
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
                    itemCount: rewards.length,
                    itemBuilder: (context, i) {
                      final r = rewards[i];
                      return RewardCard(
                        reward: r,
                        onTap: () => context.push('/rewards/${r.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsBanner extends StatelessWidget {
  final int? points;
  const _PointsBanner({this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            const Color(0x05FFFFFF),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Puntos disponibles',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            points?.toString() ?? '—',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
