import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Tarjeta de estadística individual: label + valor numérico.
/// Se usa en HomeScreen y HistoryScreen.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: borderColor ?? AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.labelMono),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.monoLarge.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
