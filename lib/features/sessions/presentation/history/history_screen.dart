import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../data/models/recycling_session.dart';
import '../session_provider.dart';
import '../widgets/session_card.dart';
import '../widgets/session_summary_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  RecyclingSessionStatus? _filter; // null = todas

  static const _filters = <RecyclingSessionStatus?>[
    null,
    RecyclingSessionStatus.confirmed,
    RecyclingSessionStatus.pending,
    RecyclingSessionStatus.expired,
    RecyclingSessionStatus.cancelled,
  ];

  static const _filterLabels = <RecyclingSessionStatus?, String>{
    null: 'Todas',
    RecyclingSessionStatus.confirmed: 'Confirmadas',
    RecyclingSessionStatus.pending: 'Pendientes',
    RecyclingSessionStatus.expired: 'Expiradas',
    RecyclingSessionStatus.cancelled: 'Canceladas',
  };

  List<RecyclingSession> _applyFilter(List<RecyclingSession> all) {
    if (_filter == null) return all;
    return all.where((s) => s.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionListProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: sessionsAsync.when(
        loading: () => const LoadingState(),
        error:
            (e, _) => ErrorState(
              message:
                  e.toString().contains('Sin conexión')
                      ? 'Sin conexión. Verifica tu internet.'
                      : 'No se pudo cargar el historial.',
              onRetry: () => ref.read(sessionListProvider.notifier).refresh(),
            ),
        data: (sessions) {
          final filtered = _applyFilter(sessions);
          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Historial',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${sessions.length} sesiones de reciclaje',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Resumen numérico
                        if (sessions.isNotEmpty)
                          SessionSummaryCard(sessions: sessions),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // ── Filtros horizontales ─────────────────────────────────
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final f = _filters[i];
                        final isActive = _filter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? AppColors.primary.withValues(
                                        alpha: 0.10,
                                      )
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color:
                                    isActive
                                        ? AppColors.primary.withValues(
                                          alpha: 0.30,
                                        )
                                        : AppColors.borderSubtle,
                              ),
                            ),
                            child: Text(
                              _filterLabels[f]!,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11.5,
                                color:
                                    isActive
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                fontWeight:
                                    isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // ── Lista ────────────────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad),
                  sliver:
                      filtered.isEmpty
                          ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: EmptyState(
                                title:
                                    sessions.isEmpty
                                        ? 'Sin sesiones aún'
                                        : 'Sin resultados',
                                subtitle:
                                    sessions.isEmpty
                                        ? 'Escanea el QR de un Smart Bin para registrar tu primera sesión.'
                                        : 'No hay sesiones con el filtro seleccionado.',
                                icon: Icons.recycling_outlined,
                              ),
                            ),
                          )
                          : SliverList(
                            delegate: SliverChildBuilderDelegate((context, i) {
                              final s = filtered[i];
                              return SessionCard(
                                session: s,
                                onTap: () => context.push('/history/${s.id}'),
                              );
                            }, childCount: filtered.length),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
