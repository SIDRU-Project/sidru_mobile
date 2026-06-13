import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/weight_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../data/models/recycling_session.dart';

/// Resultado exitoso de la confirmación de sesión.
class SessionResultScreen extends ConsumerWidget {
  final RecyclingSession session;
  const SessionResultScreen({super.key, required this.session});

  String get _weightKg => WeightFormatter.gramsToKg(session.weightGrams);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasHash =
        session.blockchainTxHash != null &&
        session.blockchainTxHash!.isNotEmpty;
    final bottomPad = MediaQuery.of(context).padding.bottom + 24;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Glow de fondo verde
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPad),
              child: Column(
                children: [
                  const Spacer(),

                  // Check animado
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF0A0E1A),
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Sesión confirmada',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tus puntos fueron acreditados a tu cuenta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Card de resultado
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        _Row(
                          'Puntos acreditados',
                          '+${session.pointsEarned}',
                          valueColor: AppColors.primary,
                        ),
                        _Row('Chapas', '${session.capCount} caps'),
                        _Row('Peso', _weightKg),
                        _Row('Estado', 'Confirmada'),
                        if (hasHash)
                          _Row(
                            'Hash blockchain',
                            session.blockchainTxHash!,
                            mono: true,
                            small: true,
                            isLast: true,
                          )
                        else
                          _Row(
                            'Blockchain',
                            'Sin registro',
                            valueColor: AppColors.textTertiary,
                            isLast: true,
                          ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  GradientButton(
                    label: 'Volver al inicio',
                    onPressed: () => context.go(RouteNames.home),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'Ver detalle',
                    onPressed: () => context.go('/history/${session.id}'),
                  ),
                ],
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
  final bool mono;
  final bool small;
  final bool isLast;

  const _Row(
    this.label,
    this.value, {
    this.valueColor,
    this.mono = false,
    this.small = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
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
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: mono ? 'monospace' : null,
                fontSize: small ? 11 : 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
