import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_state.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ref.read(authNotifierProvider).clearError();
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider)
        .signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider).state;

    // Muestra spinner mientras la app restaura sesión al arrancar
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
          // ── Auras de fondo ────────────────────────────────────────────────
          Positioned(
            left: -120,
            top: -150,
            child: _GlowCircle(
              size: 380,
              color: AppColors.primary.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            right: -100,
            bottom: -80,
            child: _GlowCircle(
              size: 300,
              color: AppColors.secondary.withValues(alpha: 0.16),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────────────────
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),

                          // Logo
                          _SidruBrand(),

                          const SizedBox(height: 32),

                          // Títulos
                          Text(
                            'Bienvenido de vuelta',
                            style: AppTextStyles.displayLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Inicia sesión para reciclar y ganar puntos.',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 28),

                          // Banner de error del servidor
                          if (auth.errorMessage != null)
                            _ErrorBanner(message: auth.errorMessage!),

                          // Campos
                          AppTextField(
                            label: 'Correo',
                            hint: 'user@email.com',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              size: 18,
                            ),
                            validator: Validators.email,
                          ),
                          AppTextField(
                            label: 'Contraseña',
                            hint: '••••••••',
                            controller: _passwordCtrl,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(
                              Icons.key_outlined,
                              size: 18,
                            ),
                            validator: Validators.password,
                            onFieldSubmitted: (_) => _submit(),
                          ),

                          // ¿Olvidaste tu contraseña?
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showForgotPasswordToast(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.secondary,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36),
                              ),
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Botón principal
                          GradientButton(
                            label: 'Iniciar sesión',
                            onPressed: _submit,
                            isLoading: auth.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Footer ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta? ',
                          style: AppTextStyles.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.register),
                          child: ShaderMask(
                            shaderCallback:
                                (bounds) => AppColors.primaryGradient
                                    .createShader(bounds),
                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Te enviaremos un enlace de recuperación')),
    );
  }
}

// ── Widgets privados ──────────────────────────────────────────────────────────

class _SidruBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo SIDRU
        Image.asset(
          'assets/images/logo_mark.png',
          width: 48,
          height: 48,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIDRU',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            Text('RECICLA · GANA · REPITE', style: AppTextStyles.labelMono),
          ],
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

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
