import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusFormatter {
  static String label(String status) => switch (status.toUpperCase()) {
    'PENDING' => 'Pendiente',
    'CONFIRMED' => 'Confirmada',
    'EXPIRED' => 'Expirada',
    'CANCELLED' => 'Cancelada',
    _ => status,
  };

  static Color color(String status) => switch (status.toUpperCase()) {
    'PENDING' => AppColors.sessionPending,
    'CONFIRMED' => AppColors.sessionConfirmed,
    'EXPIRED' => AppColors.sessionExpired,
    'CANCELLED' => AppColors.sessionCancelled,
    _ => AppColors.textTertiary,
  };

  /// Label para tipo de transacción de puntos
  static String transactionLabel(String type) => switch (type.toUpperCase()) {
    'EARN' => 'Ganados',
    'REDEEM' => 'Canjeados',
    _ => type,
  };

  static Color transactionColor(String type) => switch (type.toUpperCase()) {
    'EARN' => AppColors.sessionConfirmed,
    'REDEEM' => AppColors.sessionCancelled,
    _ => AppColors.textSecondary,
  };

  static String transactionSign(String type) =>
      type.toUpperCase() == 'EARN' ? '+' : '-';
}
