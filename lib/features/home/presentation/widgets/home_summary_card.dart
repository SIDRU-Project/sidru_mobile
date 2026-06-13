import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Card de estadística individual alineada al prototipo SIDRU.
/// Gradiente 135deg desde accent con 12% opacidad → surface casi transparente.
/// Número grande en mono 30/600, label mono pequeño, subtítulo secundario.
class HomeSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color accentColor;

  const HomeSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.12),
            const Color(0x05FFFFFF), // rgba(255,255,255,0.02)
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: accentColor,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
