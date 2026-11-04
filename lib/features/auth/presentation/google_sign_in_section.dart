import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/outline_button.dart';
import 'auth_provider.dart';

/// Separador "o" + botón "Continuar con Google". Solo aparece si el backend declara Google en
/// GET /authentication/providers; si la consulta falla o no hay client ID, no ocupa nada
/// y la pantalla queda solo con correo y contraseña.
///
/// Solo web: el botón es propio (mismo estilo que "Iniciar sesión") y sale por redirección a Google
/// (OIDC `response_type=id_token`); la vuelta la resuelve `/auth/google/callback`. En nativo Google
/// exige un client ID Android con el SHA-1 del keystore (Fase 5, sin hacer), así que no se muestra.
class GoogleSignInSection extends ConsumerWidget {
  const GoogleSignInSection({super.key, bool? isWeb}) : isWeb = isWeb ?? kIsWeb;

  final bool isWeb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isWeb) return const SizedBox.shrink();
    final providers = ref.watch(authProvidersProvider).valueOrNull;
    if (providers == null || !providers.hasGoogle) {
      return const SizedBox.shrink();
    }
    final clientId = providers.googleClientId!;

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
          OutlineButton(
            label: 'Continuar con Google',
            // Tema claro oficial de Google; el resto de botones de la app no cambia.
            background: const Color(0xFFFFFFFF),
            borderColor: const Color(0xFF747775),
            textColor: const Color(0xFF1F1F1F),
            pressedColor: const Color(0xFFF2F2F2),
            leading: Image.asset(
              'assets/images/google_g.png',
              width: 20,
              height: 20,
            ),
            onTap: () => ref.read(googleRedirectFlowProvider).start(clientId),
          ),
        ],
      ),
    );
  }
}
