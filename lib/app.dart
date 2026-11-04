import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

class SidruApp extends ConsumerWidget {
  const SidruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'SIDRU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      // En pantallas anchas (PC) la app se ve como un teléfono centrado.
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        if (MediaQuery.sizeOf(context).width <= 520) return child;
        return ColoredBox(
          color: AppColors.backgroundDark,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
