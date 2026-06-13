import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../session_provider.dart';

/// Ingreso manual del token QR cuando la cámara falla o no está disponible.
class ManualQrScreen extends ConsumerStatefulWidget {
  const ManualQrScreen({super.key});

  @override
  ConsumerState<ManualQrScreen> createState() => _ManualQrScreenState();
}

class _ManualQrScreenState extends ConsumerState<ManualQrScreen> {
  final TextEditingController _ctrl = TextEditingController();
  bool _loading = false;
  String? _fieldError;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _ctrl.text.trim();
    if (token.isEmpty) {
      setState(() => _fieldError = 'Ingresa el código del Smart Bin.');
      return;
    }
    setState(() {
      _fieldError = null;
      _loading = true;
    });

    final outcome = await ref
        .read(sessionScanControllerProvider)
        .getSessionByQr(token);
    if (!mounted) return;
    setState(() => _loading = false);

    if (outcome is QrLookupSuccess) {
      context.pushReplacement(RouteNames.scanSummary, extra: outcome.session);
    } else if (outcome is QrLookupFailure) {
      context.pushReplacement(RouteNames.scanError, extra: outcome.type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: 'Código manual',
              showBack: true,
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingresa el código que aparece bajo el QR en la pantalla del Smart Bin.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card de entrada
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _fieldError != null
                                ? AppColors.error.withValues(alpha: 0.5)
                                : AppColors.borderSubtle,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CÓDIGO DEL BIN',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _ctrl,
                          autofocus: true,
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.text,
                          onSubmitted: (_) => _submit(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.5,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: 'QR-SESION-DEMO',
                            hintStyle: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 18,
                              color: AppColors.textTertiary,
                              letterSpacing: 1,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) {
                            if (_fieldError != null) {
                              setState(() => _fieldError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          color:
                              _fieldError != null
                                  ? AppColors.error
                                  : AppColors.borderSubtle,
                        ),
                        if (_fieldError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _fieldError!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  GradientButton(
                    label: 'Consultar sesión',
                    onPressed: _submit,
                    isLoading: _loading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
