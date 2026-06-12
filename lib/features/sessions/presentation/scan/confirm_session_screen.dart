import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/weight_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../data/models/recycling_session.dart';
import '../session_provider.dart';

/// Confirmación final antes de reclamar los puntos de la sesión.
class ConfirmSessionScreen extends ConsumerStatefulWidget {
  final RecyclingSession session;
  const ConfirmSessionScreen({super.key, required this.session});

  @override
  ConsumerState<ConfirmSessionScreen> createState() =>
      _ConfirmSessionScreenState();
}

class _ConfirmSessionScreenState extends ConsumerState<ConfirmSessionScreen> {
  bool _loading = false;

  String get _weightKg => WeightFormatter.gramsToKg(widget.session.weightGrams);

  String get _binCode =>
      'BIN-${widget.session.smartBinId.toString().padLeft(3, '0')}';

  Future<void> _confirm() async {
    setState(() => _loading = true);

    final outcome = await ref
        .read(sessionScanControllerProvider)
        .confirmSessionByQr(widget.session.qrToken);
    if (!mounted) return;

    if (outcome is ConfirmSuccess) {
      context.go(RouteNames.scanResult, extra: outcome.session);
    } else if (outcome is ConfirmFailure) {
      context.go(RouteNames.scanError, extra: outcome.type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final bottomPad = MediaQuery.of(context).padding.bottom + 24;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPad),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _loading ? null : () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Ícono
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Confirmar entrega',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Confirmo que entregué las chapas de esta sesión '
                '(${session.capCount} chapas · $_weightKg) en el $_binCode.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Resumen puntos
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Puntos a reclamar',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '+${session.pointsEarned}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GradientButton(
                label: 'Confirmar y reclamar puntos',
                onPressed: _confirm,
                isLoading: _loading,
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Cancelar',
                onPressed: _loading ? null : () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
