import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../user/presentation/user_provider.dart';
import '../data/models/reward.dart';
import 'rewards_provider.dart';
import 'widgets/reward_card.dart';

class RewardDetailScreen extends ConsumerStatefulWidget {
  final int rewardId;
  const RewardDetailScreen({super.key, required this.rewardId});

  @override
  ConsumerState<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends ConsumerState<RewardDetailScreen> {
  bool _redeeming = false;

  Future<void> _confirmAndRedeem(Reward reward) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Confirmar canje',
      description: '¿Canjear "${reward.name}" por ${reward.pointsCost} puntos?',
      confirmLabel: 'Canjear',
      cancelLabel: 'Cancelar',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _redeeming = true);
    final outcome = await ref.read(redeemControllerProvider).redeem(reward.id);
    if (!mounted) return;
    setState(() => _redeeming = false);

    if (outcome is RedeemSuccess) {
      context.go(RouteNames.rewardRedeemResult, extra: reward);
    } else if (outcome is RedeemFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(outcome.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rewardAsync = ref.watch(rewardDetailProvider(widget.rewardId));
    final userPoints =
        ref.watch(userNotifierProvider).valueOrNull?.totalPoints ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: rewardAsync.when(
          loading: () => const LoadingState(),
          error:
              (e, _) => ErrorState(
                message: 'No se pudo cargar la recompensa.',
                onRetry:
                    () => ref.invalidate(rewardDetailProvider(widget.rewardId)),
              ),
          data:
              (reward) => _Content(
                reward: reward,
                userPoints: userPoints,
                redeeming: _redeeming,
                onRedeem: () => _confirmAndRedeem(reward),
              ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Reward reward;
  final int userPoints;
  final bool redeeming;
  final VoidCallback onRedeem;

  const _Content({
    required this.reward,
    required this.userPoints,
    required this.redeeming,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = reward.stock <= 0;
    final insufficient = userPoints < reward.pointsCost;
    final canRedeem = !outOfStock && !insufficient;
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;

    return Column(
      children: [
        AppHeader(
          title: 'Recompensa',
          showBack: true,
          onBack: () => context.pop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen grande
                Center(
                  child: RewardImage(
                    imageUrl: reward.imageUrl,
                    size: 160,
                    radius: 20,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  reward.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward.description,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Costo + stock
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      _Row(
                        'Costo',
                        '${reward.pointsCost} pts',
                        valueColor: AppColors.primary,
                      ),
                      _Row(
                        'Stock disponible',
                        outOfStock ? 'Agotado' : '${reward.stock}',
                        valueColor:
                            outOfStock
                                ? AppColors.error
                                : AppColors.textPrimary,
                      ),
                      _Row('Tus puntos', '$userPoints pts', isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Mensaje de bloqueo
                if (outOfStock)
                  const _Notice(
                    icon: Icons.inventory_2_outlined,
                    text: 'Esta recompensa no tiene stock disponible.',
                  )
                else if (insufficient)
                  _Notice(
                    icon: Icons.info_outline_rounded,
                    text:
                        'Puntos insuficientes. Te faltan '
                        '${reward.pointsCost - userPoints} puntos.',
                  ),

                if (outOfStock || insufficient) const SizedBox(height: 12),

                GradientButton(
                  label: 'Canjear',
                  isDisabled: !canRedeem,
                  isLoading: redeeming,
                  onPressed: canRedeem ? onRedeem : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Notice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
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

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _Row(this.label, this.value, {this.valueColor, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
