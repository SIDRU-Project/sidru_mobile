import 'models/point_transaction.dart';
import 'models/redeem_reward_request.dart';
import 'models/reward.dart';
import 'reward_api.dart';

/// Abstrae las operaciones de recompensas y transacciones de puntos.
/// Lanza [ApiException] ante errores del backend o de red.
class RewardRepository {
  final RewardApi _api;

  RewardRepository(this._api);

  /// Catálogo completo de recompensas.
  Future<List<Reward>> getRewards() => _api.getRewards();

  /// Detalle de una recompensa por ID.
  Future<Reward> getReward(int id) => _api.getReward(id);

  /// Canjea una recompensa; devuelve la transacción generada.
  Future<PointTransaction> redeem(RedeemRewardRequest request) =>
      _api.redeem(request);

  /// Historial de transacciones de puntos del usuario.
  Future<List<PointTransaction>> getMyTransactions() =>
      _api.getMyTransactions();
}
