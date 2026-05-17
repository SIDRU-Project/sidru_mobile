import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/models/user_profile.dart';
import 'user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const LoadingState(),
        error:
            (e, _) => ErrorState(
              message: 'No se pudo cargar el perfil.',
              onRetry: () => ref.read(userNotifierProvider.notifier).refresh(),
            ),
        data:
            (profile) =>
                profile == null
                    ? const LoadingState()
                    : _ProfileContent(profile: profile),
      ),
    );
  }
}

// ── Contenido ─────────────────────────────────────────────────────────────────

class _ProfileContent extends ConsumerWidget {
  final UserProfile profile;
  const _ProfileContent({required this.profile});

  String get _initial =>
      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Espacio inferior para que el bottom nav flotante no tape el contenido.
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;
    return Stack(
      children: [
        Positioned(
          right: -100,
          top: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              bottomPad,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Perfil',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Avatar + nombre ─────────────────────────────────────────
                Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(profile.fullName, style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      profile.district,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Stats ───────────────────────────────────────────────────
                _StatsRow(profile: profile),
                const SizedBox(height: AppSpacing.lg),

                // ── Info card ───────────────────────────────────────────────
                _InfoCard(profile: profile),
                const SizedBox(height: AppSpacing.xl),

                // ── Acciones ────────────────────────────────────────────────
                GradientButton(
                  label: 'Editar perfil',
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF0A0E1A),
                    size: 18,
                  ),
                  onPressed: () => context.push(RouteNames.profileEdit),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Cerrar sesión',
                  isDanger: true,
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  onPressed: () async {
                    final confirmed = await ConfirmationDialog.show(
                      context,
                      title: 'Cerrar sesión',
                      description:
                          '¿Seguro que deseas cerrar sesión? Se eliminará tu sesión activa.',
                      confirmLabel: 'Cerrar sesión',
                      cancelLabel: 'Cancelar',
                      isDanger: true,
                    );
                    if (confirmed == true) {
                      await ref.read(authNotifierProvider).logout();
                    }
                  },
                ),

                // ── Footer versión ──────────────────────────────────────────
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text('SIDRU · v1.0.0', style: AppTextStyles.labelMono),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final UserProfile profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          _Stat(label: 'Puntos', value: profile.totalPoints.toString()),
          _Divider(),
          _Stat(label: 'Chapas', value: profile.totalCaps.toString()),
          _Divider(),
          _Stat(label: 'Sesiones', value: profile.totalSessions.toString()),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.labelMono),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.borderSubtle);
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final UserProfile profile;
  const _InfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Nombre', value: profile.fullName),
          _InfoRow(label: 'Teléfono', value: profile.phone, mono: true),
          _InfoRow(label: 'Distrito', value: profile.district, isLast: true),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : const Border(
                  bottom: BorderSide(color: AppColors.borderSubtle),
                ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Flexible(
            child: Text(
              value,
              style:
                  mono
                      ? AppTextStyles.monoMedium
                      : AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
