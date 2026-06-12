import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../session_provider.dart';

/// Pantalla de escaneo de QR del Smart Bin.
/// Cadena: QrScannerScreen → SessionScanController → SessionRepository → ApiClient.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (raw == null || raw.trim().isEmpty) return;
    await _handleToken(raw.trim());
  }

  Future<void> _handleToken(String token) async {
    if (_processing) return;
    setState(() => _processing = true);
    await _controller.stop();

    final outcome = await ref
        .read(sessionScanControllerProvider)
        .getSessionByQr(token);
    if (!mounted) return;

    if (outcome is QrLookupSuccess) {
      await context.push(RouteNames.scanSummary, extra: outcome.session);
    } else if (outcome is QrLookupFailure) {
      await context.push(RouteNames.scanError, extra: outcome.type);
    }

    // Al regresar al scanner, reanudar la cámara.
    if (!mounted) return;
    setState(() => _processing = false);
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // ── Cámara ───────────────────────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder:
                (context, error, child) => _CameraError(onManual: _goManual),
          ),

          // ── Oscurecido + recuadro ────────────────────────────────────────
          const _ScannerOverlay(),

          // ── UI superior / inferior ───────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.close_rounded,
                        onTap: () => context.go(RouteNames.home),
                      ),
                      const Spacer(),
                      const Text(
                        'ESCANEANDO QR',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      _CircleButton(
                        icon: Icons.flashlight_on_outlined,
                        onTap: () => _controller.toggleTorch(),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Instrucción
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    'Apunta al QR del Smart Bin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'El código aparece en la pantalla del contenedor al cerrar tu sesión.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                const Spacer(),

                // Estado + ingreso manual
                if (_processing)
                  const _ProcessingPill()
                else
                  const _SearchingPill(),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _processing ? null : _goManual,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface.withValues(
                          alpha: 0.7,
                        ),
                        side: const BorderSide(color: AppColors.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_outlined,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                      label: const Text(
                        'Ingresar código manualmente',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goManual() async {
    setState(() => _processing = true);
    await _controller.stop();
    if (!mounted) return;
    await context.push(RouteNames.scanManual);
    if (!mounted) return;
    setState(() => _processing = false);
    await _controller.start();
  }
}

// ── Overlay con recuadro y esquinas gradiente ─────────────────────────────────

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.9),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchingPill extends StatelessWidget {
  const _SearchingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Buscando código…',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingPill extends StatelessWidget {
  const _ProcessingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Consultando sesión…',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }
}

// ── Estado de permiso denegado / error de cámara ──────────────────────────────

class _CameraError extends StatelessWidget {
  final VoidCallback onManual;
  const _CameraError({required this.onManual});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundDark,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.no_photography_outlined,
                  color: AppColors.warning,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cámara no disponible',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'No pudimos acceder a la cámara. Otorga el permiso o ingresa el código manualmente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onManual,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  label: const Text(
                    'Ingresar código manualmente',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
