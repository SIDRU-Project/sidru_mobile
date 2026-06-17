import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../auth/presentation/auth_provider.dart';

/// Pantalla de bienvenida (landing) para usuarios no autenticados.
/// Presenta la marca y los 3 caminos: crear cuenta, iniciar sesión y wallet.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider).state;

    // Mientras la app restaura sesión, evita parpadear el onboarding antes de
    // redirigir al home (el router decide a dónde ir cuando termina).
    if (auth.isInitializing) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingState(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Aura superior de marca ────────────────────────────────────────
          Positioned(
            top: -160,
            left: 0,
            right: 0,
            child: Center(
              child: _GlowCircle(
                size: 420,
                color: AppColors.primary.withValues(alpha: 0.20),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -120,
            child: _GlowCircle(
              size: 300,
              color: AppColors.secondary.withValues(alpha: 0.14),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────────────────
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                  const SizedBox(height: 24),

                  // Marca
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_mark.png',
                        width: 40,
                        height: 40,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SIDRU',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('V0.1.0 · BETA · LIMA', style: AppTextStyles.labelMono),

                  const Spacer(flex: 2),

                  // Hero
                  const _HeroTitle(),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Recicla chapas en Smart Bins de Lima.\n'
                    'Gana eco-tokens on-chain. Repite.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // CTAs
                  GradientButton(
                    label: 'Crear cuenta',
                    onPressed: () => context.push(RouteNames.register),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _OutlineButton(
                    label: 'Iniciar sesión',
                    onTap: () => context.push(RouteNames.login),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                  ),
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero title: "Chapa / Tu Cripto." con "Cripto." en gradiente ───────────────

class _HeroTitle extends StatelessWidget {
  const _HeroTitle();

  @override
  Widget build(BuildContext context) {
    const hero = TextStyle(
      fontSize: 64,
      fontWeight: FontWeight.w800,
      height: 1.0,
      letterSpacing: -2.0,
      color: AppColors.textPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chapa', style: hero),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text('Tu ', style: hero),
            ShaderMask(
              shaderCallback:
                  (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: const Text('Cripto.', style: hero),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Botón secundario (superficie + borde) ─────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(color: AppColors.borderMedium),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Aura radial reutilizada del estilo de auth ────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
