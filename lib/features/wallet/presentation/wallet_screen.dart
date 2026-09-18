import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../data/models/wallet_summary.dart';
import '../data/models/wallet_transaction.dart';
import '../utils/wallet_formatters.dart';
import 'wallet_provider.dart';
import 'widgets/withdraw_sheet.dart';

/// WalletScreen — saldo en puntos (spec sidru-mainnet: emisión al retirar) y
/// enlace al retiro en CTC/USDC, con historial de retiros.
///
/// Consume el backend vía la cadena C4 (Provider → Repository → Api → ApiClient).
/// El saldo es `UserProfile.totalPoints` (US-MN-05): la app no calcula ni inventa
/// un balance on-chain, solo muestra las equivalencias que ya entrega el backend.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  Future<void> _openUrl(BuildContext context, String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (context.mounted) {
        _toast(context, 'No se pudo abrir el explorador.');
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _openWithdrawSheet(
    BuildContext context,
    WidgetRef ref,
    WalletSummary summary,
  ) async {
    final transaction = await WithdrawSheet.show(
      context,
      pointsBalance: summary.pointsBalance,
      minWithdrawalPoints: summary.minWithdrawalPoints,
    );
    if (transaction == null || !context.mounted) return;

    if (transaction.status == 'EN_PROCESO') {
      _toast(context, 'Retiro en proceso. Te avisaremos cuando confirme.');
      // Fire-and-forget: no bloquea la pantalla mientras se espera la cadena.
      unawaited(_pollAndNotify(context, ref, transaction.id));
    } else {
      _toast(
        context,
        transaction.status == 'COMPLETADO'
            ? 'Retiro completado.'
            : 'No se pudo completar el retiro.',
      );
    }
  }

  Future<void> _pollAndNotify(
    BuildContext context,
    WidgetRef ref,
    int withdrawalId,
  ) async {
    final result = await ref
        .read(walletWithdrawControllerProvider)
        .pollWithdrawal(withdrawalId);
    if (!context.mounted) return;

    switch (result) {
      case WithdrawPollResolved(:final transaction):
        _toast(
          context,
          transaction.status == 'COMPLETADO'
              ? 'Retiro completado.'
              : 'No se pudo completar el retiro.',
        );
      case WithdrawPollTimedOut():
        _toast(context, 'Seguimos procesando tu retiro, te avisaremos.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Aura celeste de fondo
          Positioned(
            left: -100,
            top: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppHeader(
                  title: 'Mi Wallet',
                  subtitle: walletAsync.value?.summary.network ?? '',
                  showBack: context.canPop(),
                  onBack: context.canPop() ? () => context.pop() : null,
                ),
                Expanded(
                  child: walletAsync.when(
                    loading: () => const LoadingState(),
                    error:
                        (err, _) => ErrorState(
                          message:
                              err is ApiException
                                  ? err.message
                                  : 'No se pudo cargar tu wallet.',
                          onRetry:
                              () => ref.read(walletProvider.notifier).refresh(),
                        ),
                    data: (snapshot) {
                      if (snapshot == null) {
                        return ErrorState(
                          message: 'No se pudo cargar tu wallet.',
                          onRetry:
                              () => ref.read(walletProvider.notifier).refresh(),
                        );
                      }
                      // Sin conexión se muestra el último resumen conocido,
                      // señalado como tal para no hacerlo pasar por el saldo
                      // vigente (CP019).
                      final summary = snapshot.summary;
                      return RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onRefresh: () async {
                          await ref.read(walletProvider.notifier).refresh();
                          ref.invalidate(walletWithdrawalsProvider);
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad),
                          children: [
                            if (snapshot.fromCache) const _OfflineBanner(),
                            _BalanceCard(summary: summary),
                            const SizedBox(height: 14),
                            if (summary.linkedWallet != null &&
                                summary.linkedWallet!.isNotEmpty) ...[
                              _LinkedWalletRow(address: summary.linkedWallet!),
                              const SizedBox(height: 14),
                            ],
                            _WithdrawButton(
                              enabled: summary.withdrawalsEnabled,
                              onTap:
                                  () => _openWithdrawSheet(
                                    context,
                                    ref,
                                    summary,
                                  ),
                            ),
                            const SizedBox(height: 22),
                            const _SectionLabel('RETIROS'),
                            const SizedBox(height: 10),
                            _WithdrawalList(
                              onOpen: (url) => _openUrl(context, url),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Card hero de saldo

/// Indicador de modo offline: el saldo mostrado es el último conocido, no el
/// vigente (CP019, paso 4).
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('wallet-offline-banner'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sin conexión. Mostrando tu último saldo conocido.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final WalletSummary summary;

  const _BalanceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PUNTOS DISPONIBLES',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: ShaderMask(
                  shaderCallback:
                      (b) => AppColors.primaryGradient.createShader(b),
                  child: Text(
                    '${summary.pointsBalance}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'pts',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '≈ ${summary.ctcEquivalent} CTC · S/ ${summary.solesEquivalent}',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textTertiary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mínimo de retiro: ${summary.minWithdrawalPoints} puntos',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Wallet vinculada

class _LinkedWalletRow extends StatelessWidget {
  final String address;
  const _LinkedWalletRow({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.link_rounded,
              color: AppColors.secondary,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Wallet vinculada',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            WalletFormatters.truncate(address),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Botón de retiro

class _WithdrawButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _WithdrawButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    enabled
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.borderSubtle,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? onTap : null,
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.north_east_rounded,
                        color:
                            enabled
                                ? AppColors.primary
                                : AppColors.textTertiary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Retirar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color:
                              enabled
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!enabled) ...[
          const SizedBox(height: 6),
          const Text(
            'Los retiros están temporalmente deshabilitados.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }
}

// Historial de retiros

class _WithdrawalList extends ConsumerWidget {
  final void Function(String? url) onOpen;
  const _WithdrawalList({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalsAsync = ref.watch(walletWithdrawalsProvider);

    return withdrawalsAsync.when(
      loading:
          () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: LoadingState(),
          ),
      error:
          (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ErrorState(
              message:
                  err is ApiException
                      ? err.message
                      : 'No se pudieron cargar tus retiros.',
              onRetry: () => ref.invalidate(walletWithdrawalsProvider),
            ),
          ),
      data: (withdrawals) {
        if (withdrawals.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Aún no tienes retiros',
              subtitle:
                  'Cuando retires puntos a CTC o USDC, aparecerán aquí con su '
                  'estado y enlace al explorador.',
            ),
          );
        }
        return Column(
          children: [
            for (final withdrawal in withdrawals) ...[
              _WithdrawalTile(
                withdrawal: withdrawal,
                onOpen: () => onOpen(withdrawal.explorerUrl),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _WithdrawalTile extends StatelessWidget {
  final WalletTransaction withdrawal;
  final VoidCallback onOpen;

  const _WithdrawalTile({required this.withdrawal, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.north_east_rounded,
              color: AppColors.secondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${withdrawal.points} pts · ${withdrawal.mode}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: withdrawal.status),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  withdrawal.failureReason ??
                      (withdrawal.txHash != null
                          ? WalletFormatters.truncate(
                            withdrawal.txHash!,
                            head: 10,
                            tail: 8,
                          )
                          : 'Sin confirmar aún'),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (withdrawal.explorerUrl != null)
            _IconAction(
              icon: Icons.open_in_new_rounded,
              tooltip: 'Ver en el explorador',
              onTap: onOpen,
            ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: AppColors.secondary, size: 17),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final upper = status.toUpperCase();
    final (Color color, String text) = switch (upper) {
      'COMPLETADO' => (AppColors.success, 'Completado'),
      'EN_PROCESO' => (AppColors.warning, 'En proceso'),
      'FALLIDO' => (AppColors.error, 'Fallido'),
      _ => (AppColors.textTertiary, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// Misc

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}
