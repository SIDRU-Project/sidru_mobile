import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/gradient_button.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    _districtCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    ref.read(authNotifierProvider).clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authNotifierProvider)
        .signUp(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          phone: _phoneCtrl.text.trim(),
          district: _districtCtrl.text.trim(),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada! Ahora inicia sesión.'),
          backgroundColor: AppColors.surface,
        ),
      );
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider).state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Aura celeste top-right
          Positioned(
            right: -100,
            top: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header con back
                  AppHeader(
                    title: 'Crear cuenta',
                    subtitle: 'Regístrate para empezar a reciclar',
                    showBack: true,
                    onBack: () => context.pop(),
                  ),

                  // Formulario scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.sm,
                        AppSpacing.xl,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        children: [
                          // Banner de error del servidor
                          if (auth.errorMessage != null)
                            _ErrorBanner(message: auth.errorMessage!),

                          AppTextField(
                            label: 'Nombre completo',
                            hint: 'Nombre y apellido',
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              size: 18,
                            ),
                            validator: Validators.required,
                          ),
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
                            hint: 'Mínimo 6 caracteres',
                            controller: _passwordCtrl,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(
                              Icons.key_outlined,
                              size: 18,
                            ),
                            validator: Validators.password,
                          ),
                          // Confirmar contraseña — valida contra _passwordCtrl
                          _ConfirmPasswordField(
                            controller: _confirmPasswordCtrl,
                            passwordController: _passwordCtrl,
                          ),
                          AppTextField(
                            label: 'Teléfono',
                            hint: '999999999',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 18,
                            ),
                            validator: Validators.phone,
                          ),
                          AppTextField(
                            label: 'Distrito',
                            hint: 'San Miguel',
                            controller: _districtCtrl,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                            ),
                            validator: Validators.required,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 8),

                          // Términos
                          _TermsRow(),

                          const SizedBox(height: 20),

                          GradientButton(
                            label: 'Registrarme',
                            onPressed: _submit,
                            isLoading: auth.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: AppTextStyles.bodySmall,
                        ),
                        GestureDetector(
                          onTap: () => context.go(RouteNames.login),
                          child: ShaderMask(
                            shaderCallback:
                                (b) =>
                                    AppColors.primaryGradient.createShader(b),
                            child: const Text(
                              'Iniciar sesión',
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
}

// ── Widgets privados ──────────────────────────────────────────────────────────

/// Campo de confirmación de contraseña que valida contra el campo original.
/// Se implementa como StatefulWidget para leer el valor actualizado del
/// controller de contraseña en el momento de la validación.
class _ConfirmPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;

  const _ConfirmPasswordField({
    required this.controller,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Confirmar contraseña',
      hint: 'Repite tu contraseña',
      controller: controller,
      obscureText: true,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.key_outlined, size: 18),
      validator:
          (value) => Validators.confirmPassword(value, passwordController.text),
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

class _TermsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.primary,
            size: 12,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Acepto los términos de uso y la política de datos de SIDRU.',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
