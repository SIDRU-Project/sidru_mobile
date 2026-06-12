import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../session_provider.dart';

/// Pantalla de error del flujo de escaneo / confirmación.
/// Cada [ScanErrorType] define ícono, color, título, mensaje y acción primaria.
class ScanErrorScreen extends StatelessWidget {
  final ScanErrorType type;
  const ScanErrorScreen({super.key, required this.type});

  _ErrorConfig _config() => switch (type) {
    ScanErrorType.invalid => const _ErrorConfig(
      icon: Icons.qr_code_2_rounded,
      color: AppColors.error,
      title: 'QR no válido',
      message:
          'Este código no corresponde a ninguna sesión de SIDRU. '
          'Verifica que escaneaste el QR del Smart Bin.',
      primaryLabel: 'Volver a escanear',
      primary: _PrimaryAction.rescan,
    ),
    ScanErrorType.alreadyRedeemed => const _ErrorConfig(
      icon: Icons.verified_outlined,
      color: AppColors.warning,
      title: 'QR ya canjeado',
      message:
          'Esta sesión ya fue confirmada anteriormente. '
          'Cada QR solo puede canjearse una vez.',
      primaryLabel: 'Ver historial',
      primary: _PrimaryAction.history,
    ),
    ScanErrorType.expired => const _ErrorConfig(
      icon: Icons.timer_off_outlined,
      color: AppColors.sessionExpired,
      title: 'Sesión expirada',
      message:
          'El tiempo para confirmar esta sesión ya venció. '
          'Genera una nueva sesión en el Smart Bin.',
      primaryLabel: 'Volver al inicio',
      primary: _PrimaryAction.home,
    ),
    ScanErrorType.cancelled => const _ErrorConfig(
      icon: Icons.cancel_outlined,
      color: AppColors.error,
      title: 'Sesión cancelada',
      message: 'Esta sesión fue cancelada y no puede confirmarse.',
      primaryLabel: 'Volver al inicio',
      primary: _PrimaryAction.home,
    ),
    ScanErrorType.noBackend => const _ErrorConfig(
      icon: Icons.wifi_off_rounded,
      color: AppColors.error,
      title: 'Sin conexión',
      message:
          'No se pudo conectar con el servidor. '
          'Revisa tu conexión e inténtalo nuevamente.',
      primaryLabel: 'Reintentar',
      primary: _PrimaryAction.rescan,
    ),
    ScanErrorType.confirmError => const _ErrorConfig(
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
      title: 'Error al confirmar',
      message:
          'No pudimos completar la confirmación de la sesión. '
          'Tus puntos están seguros; inténtalo de nuevo.',
      primaryLabel: 'Volver a escanear',
      primary: _PrimaryAction.rescan,
    ),
    ScanErrorType.serverError => const _ErrorConfig(
      icon: Icons.cloud_off_rounded,
      color: AppColors.error,
      title: 'Error del servidor',
      message:
          'Ocurrió un problema en el servidor. Intenta de nuevo más tarde.',
      primaryLabel: 'Reintentar',
      primary: _PrimaryAction.rescan,
    ),
  };

  void _runPrimary(BuildContext context, _PrimaryAction action) {
    switch (action) {
      case _PrimaryAction.rescan:
        context.go(RouteNames.scan);
      case _PrimaryAction.history:
        context.go(RouteNames.history);
      case _PrimaryAction.home:
        context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config();
    final bottomPad = MediaQuery.of(context).padding.bottom + 24;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPad),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.go(RouteNames.home),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: cfg.color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: cfg.color.withValues(alpha: 0.33)),
                ),
                child: Icon(cfg.icon, color: cfg.color, size: 40),
              ),
              const SizedBox(height: 24),

              Text(
                cfg.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                cfg.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),

              const Spacer(),

              GradientButton(
                label: cfg.primaryLabel,
                onPressed: () => _runPrimary(context, cfg.primary),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Volver al inicio',
                onPressed: () => context.go(RouteNames.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PrimaryAction { rescan, history, home }

class _ErrorConfig {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String primaryLabel;
  final _PrimaryAction primary;

  const _ErrorConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.primary,
  });
}
