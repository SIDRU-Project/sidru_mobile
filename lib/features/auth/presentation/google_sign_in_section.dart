import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/google_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'auth_provider.dart';

/// Separador "o" + botón de Google. Solo aparece si el backend declara Google en
/// GET /authentication/providers; si la consulta falla o no hay client ID, no ocupa nada
/// y la pantalla queda solo con correo y contraseña.
///
/// Solo web: en nativo Google exige un client ID Android con el SHA-1 del keystore (Fase 5,
/// sin hacer), así que no se muestra nada ni se inicializa el SDK. El código nativo
/// (botón stub, serverClientId) queda listo para esa fase.
class GoogleSignInSection extends ConsumerStatefulWidget {
  const GoogleSignInSection({super.key, @visibleForTesting bool? isWeb})
    : isWeb = isWeb ?? kIsWeb;

  final bool isWeb;

  @override
  ConsumerState<GoogleSignInSection> createState() =>
      _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends ConsumerState<GoogleSignInSection> {
  String? _initializedFor;
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isWeb) return const SizedBox.shrink();
    final providers = ref.watch(authProvidersProvider).valueOrNull;
    if (providers == null || !providers.hasGoogle) {
      return const SizedBox.shrink();
    }
    final clientId = providers.googleClientId!;
    if (_initializedFor != clientId) {
      _initializedFor = clientId;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final ok = await ref.read(authNotifierProvider).initGoogle(clientId);
        if (mounted) setState(() => _ready = ok);
      });
    }
    // El botón web exige el SDK ya inicializado: hasta entonces no se dibuja nada.
    if (!_ready) return const SizedBox.shrink();

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
            onPressed: () => ref.read(authNotifierProvider).startGoogleNative(),
          ),
        ],
      ),
    );
  }
}
