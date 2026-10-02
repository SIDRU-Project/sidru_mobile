import 'package:flutter/material.dart';
import '../../../shared/widgets/outline_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../auth/presentation/google_sign_in_section.dart';

/// Pantalla de bienvenida (landing) para usuarios no autenticados.
/// Presenta la marca y los 3 caminos: crear cuenta, iniciar sesión y wallet.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key, @visibleForTesting this.googleIsWeb});

  /// Solo pruebas: fuerza web/nativo en la sección de Google (null = plataforma real).
  final bool? googleIsWeb;

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
          // Aura superior de marca
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

          // Contenido
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
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
                            Text(
                              'V0.1.0 · BETA · LIMA',
                              style: AppTextStyles.labelMono,
                            ),

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
                              onPressed:
                                  () => context.push(RouteNames.register),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            OutlineButton(
                              label: 'Iniciar sesión',
                              onTap: () => context.push(RouteNames.login),
                            ),
                            // "o" + botón de Google: solo web y solo si /providers trae google.
                            // Tras entrar, el router (redirect por sesión) manda a /complete-profile o
                            // /home igual que desde /login: no depende de la ruta actual.
                            GoogleSignInSection(isWeb: googleIsWeb),
                            const SizedBox(height: AppSpacing.xxl),
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

// Hero title: "Chapa / Tu Cripto." con "Cripto." en gradiente

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

// Aura radial reutilizada del estilo de auth

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
