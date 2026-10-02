import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/google_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'auth_provider.dart';

/// Separador "o" + botón de Google. Solo aparece si el backend declara Google en
/// GET /authentication/providers; si la consulta falla o no hay client ID, no ocupa nada
/// y la pantalla queda solo con correo y contraseña.
class GoogleSignInSection extends ConsumerStatefulWidget {
  const GoogleSignInSection({super.key});

  @override
  ConsumerState<GoogleSignInSection> createState() =>
      _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends ConsumerState<GoogleSignInSection> {
  String? _initializedFor;

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(authProvidersProvider).valueOrNull;
    if (providers == null || !providers.hasGoogle) {
      return const SizedBox.shrink();
    }
    final clientId = providers.googleClientId!;
    if (_initializedFor != clientId) {
      _initializedFor = clientId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(authNotifierProvider).initGoogle(clientId);
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.borderSubtle)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('o', style: AppTextStyles.bodySmall),
              ),
              const Expanded(child: Divider(color: AppColors.borderSubtle)),
            ],
          ),
          const SizedBox(height: 16),
          buildGoogleButton(
            onPressed:
                () => ref.read(authNotifierProvider).startGoogleNative(),
          ),
        ],
      ),
    );
  }
}
