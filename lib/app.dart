import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
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
    );
  }
}
