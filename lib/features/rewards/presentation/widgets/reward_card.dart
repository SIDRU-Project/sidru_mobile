import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/reward.dart';

/// Ítem del catálogo de recompensas.
/// Imagen (o placeholder) a la izquierda, datos a la derecha.
/// Estado atenuado y chip "Sin stock" cuando stock == 0.
class RewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback onTap;

  const RewardCard({super.key, required this.reward, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final outOfStock = reward.stock <= 0;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: outOfStock ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              RewardImage(imageUrl: reward.imageUrl, size: 60),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reward.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Costo en puntos
                        Text(
                          '${reward.pointsCost}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'pts',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        // Stock
                        if (outOfStock)
                          _Chip(label: 'Sin stock', color: AppColors.error)
                        else
                          Text(
                            'Stock: ${reward.stock}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Imagen de recompensa con placeholder cuando no hay URL.
class RewardImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double radius;

  const RewardImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Icon(
        Icons.card_giftcard_rounded,
        color: AppColors.primary.withValues(alpha: 0.7),
        size: size * 0.4,
      ),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
