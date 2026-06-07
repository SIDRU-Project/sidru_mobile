import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_error_mapper.dart';
import 'models/point_transaction.dart';
import 'models/redeem_reward_request.dart';
import 'models/reward.dart';

/// Datasource HTTP de recompensas y transacciones de puntos.
class RewardApi {
  final ApiClient _client;

  RewardApi(this._client);

  /// GET /rewards — catálogo de recompensas.
  Future<List<Reward>> getRewards() async {
    try {
      final res = await _client.get('/rewards');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Reward.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /rewards/{id} — detalle de una recompensa.
  Future<Reward> getReward(int id) async {
    try {
      final res = await _client.get('/rewards/$id');
      return Reward.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// POST /rewards/redeem — canjea una recompensa con puntos.
  /// Devuelve la transacción REDEEM generada.
  Future<PointTransaction> redeem(RedeemRewardRequest request) async {
    try {
      final res = await _client.post('/rewards/redeem', data: request.toJson());
      return PointTransaction.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /rewards/transactions/me — historial de transacciones de puntos.
  Future<List<PointTransaction>> getMyTransactions() async {
    try {
      final res = await _client.get('/rewards/transactions/me');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => PointTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }
}
