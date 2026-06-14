import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../data/models/wallet_balance.dart';
import '../data/models/wallet_transaction.dart';
import '../utils/wallet_formatters.dart';
import 'wallet_provider.dart';
import 'widgets/withdraw_sheet.dart';

/// WalletScreen — saldo CTC on-chain, dirección custodial, red activa y
/// transacciones recientes con acceso al explorador (RF-19, US-BC-04/05/06).
///
/// Consume el backend vía la cadena C4 (Provider → Repository → Api → ApiClient).
/// No inventa saldo ni monto de transacciones: el balance es `balanceOf` y las
/// transacciones NO traen monto.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const _explorerBase = 'https://amoy.polygonscan.com';

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (context.mounted) {
        _toast(context, 'No se pudo abrir el explorador.');
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    _toast(context, '$label copiada');
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
                  title: 'Mi Wallet CTC',
                  subtitle: 'Polygon Amoy',
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
                    data: (wallet) {
                      if (wallet == null) {
                        return ErrorState(
                          message: 'No se pudo cargar tu wallet.',
                          onRetry:
                              () => ref.read(walletProvider.notifier).refresh(),
                        );
                      }
                      return RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onRefresh: () async {
                          await ref.read(walletProvider.notifier).refresh();
                          ref.invalidate(walletTransactionsProvider);
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad),
                          children: [
                            _BalanceCard(
                              wallet: wallet,
                              onCopyAddress:
                                  () => _copy(
                                    context,
                                    wallet.address,
                                    'Dirección',
                                  ),
                              onOpenAddress:
                                  () => _openUrl(
                                    context,
                                    '$_explorerBase/address/${wallet.address}',
                                  ),
                            ),
                            const SizedBox(height: 14),
                            if (wallet.linkedWallet != null &&
                                wallet.linkedWallet!.isNotEmpty) ...[
                              _LinkedWalletRow(address: wallet.linkedWallet!),
                              const SizedBox(height: 14),
                            ],
                            _WithdrawButton(
                              onTap: () async {
                                await WithdrawSheet.show(
                                  context,
                                  balanceCtc: wallet.balanceCtc,
                                );
                              },
                            ),
                            const SizedBox(height: 22),
                            const _SectionLabel('MOVIMIENTOS RECIENTES'),
                            const SizedBox(height: 10),
                            _TransactionList(
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

// ── Card hero de balance ──────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final WalletBalance wallet;
  final VoidCallback onCopyAddress;
  final VoidCallback onOpenAddress;

  const _BalanceCard({
    required this.wallet,
    required this.onCopyAddress,
    required this.onOpenAddress,
  });

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
            'SALDO DISPONIBLE',
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
                    wallet.balanceCtc,
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
                  'CTC',
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
            '≈ S/ ${wallet.solesRef} (estimado)',
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
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.textTertiary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    WalletFormatters.truncate(wallet.address),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _IconAction(
                  icon: Icons.copy_rounded,
                  tooltip: 'Copiar dirección',
                  onTap: onCopyAddress,
                ),
                const SizedBox(width: 4),
                _IconAction(
                  icon: Icons.open_in_new_rounded,
                  tooltip: 'Ver en Polygonscan',
                  onTap: onOpenAddress,
                ),
              ],
            ),
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

// ── Wallet vinculada ──────────────────────────────────────────────────────────

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

// ── Botón de retiro ───────────────────────────────────────────────────────────

class _WithdrawButton extends StatelessWidget {
  final VoidCallback onTap;
  const _WithdrawButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.north_east_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Retirar a mi wallet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Lista de transacciones ────────────────────────────────────────────────────

class _TransactionList extends ConsumerWidget {
  final void Function(String url) onOpen;
  const _TransactionList({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(walletTransactionsProvider);

    return txAsync.when(
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
                      : 'No se pudieron cargar tus movimientos.',
              onRetry: () => ref.invalidate(walletTransactionsProvider),
            ),
          ),
      data: (txs) {
        if (txs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Aún no tienes movimientos',
              subtitle:
                  'Cuando recicles o retires CTC, tus transacciones aparecerán '
                  'aquí con enlace a Polygonscan.',
            ),
          );
        }
        return Column(
          children: [
            for (final tx in txs) ...[
              _TransactionTile(tx: tx, onOpen: () => onOpen(tx.explorerUrl)),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction tx;
  final VoidCallback onOpen;

  const _TransactionTile({required this.tx, required this.onOpen});

  bool get _isMint => tx.type == WalletTransactionType.mint;

  @override
  Widget build(BuildContext context) {
    final color = _isMint ? AppColors.primary : AppColors.secondary;
    final icon = _isMint ? Icons.south_west_rounded : Icons.north_east_rounded;
    final label = switch (tx.type) {
      WalletTransactionType.mint => 'Recompensa',
      WalletTransactionType.withdraw => 'Retiro',
      WalletTransactionType.unknown => 'Transacción',
    };

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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: tx.status),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  WalletFormatters.truncate(tx.txHash, head: 10, tail: 8),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _IconAction(
            icon: Icons.open_in_new_rounded,
            tooltip: 'Ver en Polygonscan',
            onTap: onOpen,
          ),
        ],
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
      'COMPLETADO' ||
      'CONFIRMED' ||
      'CONFIRMADO' => (AppColors.success, 'Confirmada'),
      'EN_PROCESO' ||
      'PENDING' ||
      'PENDIENTE' => (AppColors.warning, 'Pendiente'),
      'FALLIDO' || 'FAILED' || 'ERROR' => (AppColors.error, 'Fallida'),
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

// ── Misc ──────────────────────────────────────────────────────────────────────

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
