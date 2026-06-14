import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../user/presentation/user_provider.dart';
import '../data/models/point_transaction.dart';
import '../data/models/redeem_reward_request.dart';
import '../data/models/reward.dart';
import '../data/reward_api.dart';
import '../data/reward_repository.dart';

// ── Cadena de dependencias ────────────────────────────────────────────────────

final rewardApiProvider = Provider<RewardApi>((ref) {
  return RewardApi(ref.watch(apiClientProvider));
});

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepository(ref.watch(rewardApiProvider));
});

// ── Catálogo de recompensas ───────────────────────────────────────────────────

final rewardsListProvider =
    AsyncNotifierProvider<RewardsNotifier, List<Reward>>(
      () => RewardsNotifier(),
    );

class RewardsNotifier extends AsyncNotifier<List<Reward>> {
  @override
  Future<List<Reward>> build() async => _load();

  Future<List<Reward>> _load() async {
    try {
      return await ref.read(rewardRepositoryProvider).getRewards();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await ref.read(authNotifierProvider).logout();
        return [];
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

// ── Detalle de recompensa ─────────────────────────────────────────────────────

final rewardDetailProvider = FutureProvider.family<Reward, int>((
  ref,
  id,
) async {
  return ref.read(rewardRepositoryProvider).getReward(id);
});

// ── Historial de transacciones ────────────────────────────────────────────────

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<PointTransaction>>(
      () => TransactionsNotifier(),
    );

class TransactionsNotifier extends AsyncNotifier<List<PointTransaction>> {
  @override
  Future<List<PointTransaction>> build() async => _load();

  Future<List<PointTransaction>> _load() async {
    try {
      final list = await ref.read(rewardRepositoryProvider).getMyTransactions();
      // Más recientes primero
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await ref.read(authNotifierProvider).logout();
        return [];
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

// ── Canje de recompensa ───────────────────────────────────────────────────────

enum RedeemErrorKind { conflict, network, server }

sealed class RedeemOutcome {
  const RedeemOutcome();
}

class RedeemSuccess extends RedeemOutcome {
  final PointTransaction transaction;
  const RedeemSuccess(this.transaction);
}

class RedeemFailure extends RedeemOutcome {
  final RedeemErrorKind kind;
  final String message;
  const RedeemFailure(this.kind, this.message);
}

/// Controlador imperativo del canje.
/// Las pantallas llaman a este provider (nunca al repositorio directamente).
final redeemControllerProvider = Provider<RedeemController>((ref) {
  return RedeemController(ref);
});

class RedeemController {
  final Ref _ref;
  RedeemController(this._ref);

  /// Canjea la recompensa y refresca perfil, transacciones y catálogo.
  Future<RedeemOutcome> redeem(int rewardId) async {
    final repo = _ref.read(rewardRepositoryProvider);
    try {
      final tx = await repo.redeem(RedeemRewardRequest(rewardId: rewardId));
      // Reglas: tras canjear, refrescar puntos del perfil, historial y stock.
      await _ref.read(userNotifierProvider.notifier).refresh();
      await _ref.read(transactionsProvider.notifier).refresh();
      await _ref.read(rewardsListProvider.notifier).refresh();
      return RedeemSuccess(tx);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _ref.read(authNotifierProvider).logout();
        return const RedeemFailure(
          RedeemErrorKind.server,
          'Sesión expirada. Inicia sesión nuevamente.',
        );
      }
      return RedeemFailure(_mapKind(e), _mapMessage(e));
    } catch (_) {
      return const RedeemFailure(
        RedeemErrorKind.server,
        'No se pudo procesar el canje. Intenta de nuevo.',
      );
    }
  }

  RedeemErrorKind _mapKind(ApiException e) => switch (e.type) {
    ApiErrorType.conflict => RedeemErrorKind.conflict,
    ApiErrorType.networkError => RedeemErrorKind.network,
    _ => RedeemErrorKind.server,
  };

  String _mapMessage(ApiException e) => switch (e.type) {
    ApiErrorType.conflict =>
      'No se pudo canjear. Puede que no haya stock o puntos suficientes.',
    ApiErrorType.networkError => 'Sin conexión. Verifica tu internet.',
    _ => 'No se pudo procesar el canje. Intenta de nuevo.',
  };
}
