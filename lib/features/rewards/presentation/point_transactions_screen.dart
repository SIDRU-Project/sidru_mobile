import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_state.dart';
import 'rewards_provider.dart';
import 'widgets/point_transaction_card.dart';

class PointTransactionsScreen extends ConsumerWidget {
  const PointTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Historial de puntos',
              showBack: true,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: txAsync.when(
                loading: () => const LoadingState(),
                error:
                    (e, _) => ErrorState(
                      message:
                          e.toString().contains('Sin conexión')
                              ? 'Sin conexión. Verifica tu internet.'
                              : 'No se pudo cargar el historial de puntos.',
                      onRetry:
                          () =>
                              ref.read(transactionsProvider.notifier).refresh(),
                    ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const EmptyState(
                      title: 'Sin movimientos',
                      subtitle: 'Aquí verás tus puntos ganados y canjeados.',
                      icon: Icons.receipt_long_outlined,
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad),
                    itemCount: transactions.length,
                    itemBuilder:
                        (context, i) =>
                            PointTransactionCard(transaction: transactions[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
