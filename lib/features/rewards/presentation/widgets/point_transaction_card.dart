import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/point_transaction.dart';

/// Ítem del historial de transacciones de puntos.
/// EARN en verde con "+", REDEEM en rojo con "-".
class PointTransactionCard extends StatelessWidget {
  final PointTransaction transaction;

  const PointTransactionCard({super.key, required this.transaction});

  bool get _isEarn => transaction.type == PointTransactionType.earn;

  String get _date =>
      DateFormat('dd MMM yyyy · HH:mm', 'es').format(transaction.createdAt);

  @override
  Widget build(BuildContext context) {
    final color = _isEarn ? AppColors.primary : AppColors.error;
    final sign = _isEarn ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          // Ícono según tipo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Icon(
              _isEarn
                  ? Icons.add_circle_outline_rounded
                  : Icons.card_giftcard_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Descripción + fecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _date,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Puntos
          Text(
            '$sign${transaction.points}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
