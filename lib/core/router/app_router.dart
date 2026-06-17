import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../storage/secure_storage.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/sessions/data/models/recycling_session.dart';
import '../../features/sessions/presentation/history/history_screen.dart';
import '../../features/sessions/presentation/history/session_detail_screen.dart';
import '../../features/sessions/presentation/scan/qr_scanner_screen.dart';
import '../../features/sessions/presentation/scan/manual_qr_screen.dart';
import '../../features/sessions/presentation/scan/session_summary_screen.dart';
import '../../features/sessions/presentation/scan/confirm_session_screen.dart';
import '../../features/sessions/presentation/scan/session_result_screen.dart';
import '../../features/sessions/presentation/scan/scan_error_screen.dart';
import '../../features/sessions/presentation/session_provider.dart';
import '../../features/user/presentation/user_provider.dart';
import '../../features/rewards/presentation/rewards_provider.dart';
import '../../features/rewards/data/models/reward.dart';
import '../../features/rewards/presentation/rewards_screen.dart';
import '../../features/rewards/presentation/reward_detail_screen.dart';
import '../../features/rewards/presentation/reward_redeem_result_screen.dart';
import '../../features/rewards/presentation/point_transactions_screen.dart';
import '../../features/user/presentation/profile_screen.dart';
import '../../features/user/presentation/edit_profile_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../shared/widgets/sidru_bottom_nav.dart';
import 'route_names.dart';

// ── Provider compartido de SecureStorage ─────────────────────────────────────
final secureStorageProvider = Provider<SecureStorage>((_) => SecureStorage());

// ── GoRouter ─────────────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: RouteNames.onboarding,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = authNotifier.state;
      if (authState.isInitializing) return null;
      final isAuth = authState.isAuthenticated;
      final loc = state.matchedLocation;
      // Rutas públicas accesibles sin sesión.
      final isPublicRoute =
          loc == RouteNames.onboarding ||
          loc == RouteNames.login ||
          loc == RouteNames.register;
      if (!isAuth && !isPublicRoute) return RouteNames.onboarding;
      if (isAuth && isPublicRoute) return RouteNames.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Tabs principales (con bottom navigation) ────────────────────────
      ShellRoute(
        builder: (_, __, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.history,
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: RouteNames.rewards,
            builder: (_, __) => const RewardsScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Sub-páginas fullscreen (sin bottom nav, como el prototipo) ──────
      GoRoute(
        path: RouteNames.wallet,
        builder: (_, __) => const WalletScreen(),
      ),
      GoRoute(
        path: RouteNames.historyDetail,
        builder:
            (_, s) => SessionDetailScreen(
              sessionId: int.tryParse(s.pathParameters['id'] ?? '') ?? 0,
            ),
      ),
      GoRoute(
        path: RouteNames.profileEdit,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.rewardsTransactions,
        builder: (_, __) => const PointTransactionsScreen(),
      ),
      GoRoute(
        path: RouteNames.rewardRedeemResult,
        builder: (_, state) {
          final reward = state.extra;
          if (reward is! Reward) return const RewardsScreen();
          return RewardRedeemResultScreen(reward: reward);
        },
      ),
      GoRoute(
        path: RouteNames.rewardDetail,
        builder:
            (_, s) => RewardDetailScreen(
              rewardId: int.tryParse(s.pathParameters['id'] ?? '') ?? 0,
            ),
      ),

      // ── Flujo QR (fullscreen, fuera del shell) ──────────────────────────
      GoRoute(
        path: RouteNames.scan,
        builder: (_, __) => const QrScannerScreen(),
      ),
      GoRoute(
        path: RouteNames.scanManual,
        builder: (_, __) => const ManualQrScreen(),
      ),
      GoRoute(
        path: RouteNames.scanSummary,
        builder: (_, state) {
          final session = state.extra;
          if (session is! RecyclingSession) return const QrScannerScreen();
          return SessionSummaryScreen(session: session);
        },
      ),
      GoRoute(
        path: RouteNames.scanConfirm,
        builder: (_, state) {
          final session = state.extra;
          if (session is! RecyclingSession) return const QrScannerScreen();
          return ConfirmSessionScreen(session: session);
        },
      ),
      GoRoute(
        path: RouteNames.scanResult,
        builder: (_, state) {
          final session = state.extra;
          if (session is! RecyclingSession) return const QrScannerScreen();
          return SessionResultScreen(session: session);
        },
      ),
      GoRoute(
        path: RouteNames.scanError,
        builder: (_, state) {
          final type =
              state.extra is ScanErrorType
                  ? state.extra as ScanErrorType
                  : ScanErrorType.serverError;
          return ScanErrorScreen(type: type);
        },
      ),
    ],
  );
});

// ── Shell con SidruBottomNav flotante ─────────────────────────────────────────

class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  static const _tabs = [
    RouteNames.home,
    RouteNames.history,
    RouteNames.scan,
    RouteNames.rewards,
    RouteNames.profile,
  ];

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  /// Invalida los providers de datos del tab destino para que se re-consulten al
  /// entrar. Sin esto, Riverpod muestra el valor cacheado de la visita anterior.
  void _refreshTabData(WidgetRef ref, String target) {
    if (target == RouteNames.home) {
      ref.invalidate(userNotifierProvider);
      ref.invalidate(sessionListProvider);
    } else if (target == RouteNames.history) {
      ref.invalidate(sessionListProvider);
    } else if (target == RouteNames.rewards) {
      ref.invalidate(rewardsListProvider);
    } else if (target == RouteNames.profile) {
      ref.invalidate(userNotifierProvider);
    }
    // 'scan' es un flujo aparte, sin datos de tab que refrescar.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = _tabIndex(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: SidruBottomNav(
        currentIndex: idx,
        onTap: (i) {
          final target = _tabs[i];
          _refreshTabData(ref, target); // datos frescos al cambiar de tab
          context.go(target);
        },
      ),
    );
  }
}
