import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'gradient_button.dart';
import 'app_button.dart';

/// Bottom sheet modal de confirmación.
/// Recibe título, descripción y callbacks para confirmar / cancelar.
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDanger;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    required this.onConfirm,
    this.onCancel,
    this.isDanger = false,
  });

  /// Muestra el diálogo como bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String description,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDanger = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => ConfirmationDialog(
            title: title,
            description: description,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            isDanger: isDanger,
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Ícono
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color:
                  isDanger
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDanger
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              color: isDanger ? AppColors.error : AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(title, style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          GradientButton(label: confirmLabel, onPressed: onConfirm),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: cancelLabel,
            onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
