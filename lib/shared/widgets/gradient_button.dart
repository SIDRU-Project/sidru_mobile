import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Botón principal de la app con gradiente verde → celeste.
/// Soporta estado loading (muestra spinner) y disabled.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double height;
  final Widget? leading;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 52,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final active = !isDisabled && !isLoading && onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          color: active ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: active ? null : Border.all(color: AppColors.borderSubtle),
          boxShadow:
              active
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: active ? onPressed : null,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF0A0E1A)),
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (leading != null) ...[
                            leading!,
                            const SizedBox(width: 8),
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  active
                                      ? const Color(0xFF0A0E1A)
                                      : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
