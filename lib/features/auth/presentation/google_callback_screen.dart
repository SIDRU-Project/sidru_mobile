import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/google_redirect_flow.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_provider.dart';

/// Destino de la redirección de Google (`/auth/google/callback`). Lee el fragmento de la URL,
/// valida `state`, y canjea el id_token (con su nonce) por la sesión de SIDRU. Corre una sola vez.
class GoogleCallbackScreen extends ConsumerStatefulWidget {
  const GoogleCallbackScreen({super.key});

  @override
  ConsumerState<GoogleCallbackScreen> createState() =>
      _GoogleCallbackScreenState();
}

class _GoogleCallbackScreenState extends ConsumerState<GoogleCallbackScreen> {
  bool _started = false;

  Future<void> _run() async {
    final auth = ref.read(authNotifierProvider);
    final result = ref.read(googleRedirectFlowProvider).consumeCallback();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);

    // Ya había sesión (p. ej. recarga con sesión viva): no hay nada que canjear.
    if (auth.state.isAuthenticated) {
      router.go(RouteNames.home);
      return;
    }
    switch (result) {
      case GoogleCallbackSuccess(:final idToken, :final nonce):
        await auth.signInWithGoogle(idToken, nonce: nonce);
        if (!mounted) return;
        // Éxito: el redirect del router manda a /complete-profile o /home. Error: al login,
        // donde se muestra el mensaje.
        if (!auth.state.isAuthenticated) router.go(RouteNames.login);
      case GoogleCallbackCancelled():
        router.go(RouteNames.onboarding);
      case GoogleCallbackInvalid():
        messenger?.showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo verificar el inicio de sesión. Inténtalo de nuevo.',
            ),
          ),
        );
        router.go(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initializing = ref.watch(authNotifierProvider).state.isInitializing;
    if (!initializing && !_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _run();
      });
    }
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
