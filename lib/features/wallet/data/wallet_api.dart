import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_error_mapper.dart';
import 'models/wallet_summary.dart';
import 'models/wallet_transaction.dart';

/// Datasource HTTP de la wallet del ciudadano (spec sidru-mainnet: retiro desde
/// puntos). Cadena C4: WalletRepository → WalletApi → ApiClient → JwtInterceptor.
/// Las pantallas nunca usan Dio directamente.
class WalletApi {
  final ApiClient _client;

  WalletApi(this._client);

  /// GET /wallet/me — saldo en puntos, equivalencias, red y wallet vinculada.
  Future<WalletSummary> getWallet() async {
    try {
      final res = await _client.get('/wallet/me');
      return WalletSummary.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// POST /wallet/withdraw — inicia un retiro de [points] puntos en modo [mode]
  /// ("CTC" o "USDC") hacia [toAddress]. HTTP 202 (EN_PROCESO) y 200 (resultado
  /// final, COMPLETADO o FALLIDO) son ambos éxito: el backend siempre devuelve el
  /// estado del retiro en el cuerpo.
  Future<WalletTransaction> withdraw({
    required String toAddress,
    required int points,
    required String mode,
  }) async {
    try {
      final res = await _client.post(
        '/wallet/withdraw',
        data: {'toAddress': toAddress, 'points': points, 'mode': mode},
      );
      return WalletTransaction.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /wallet/withdraw/{id} — estado de un retiro puntual (para el polling).
  Future<WalletTransaction> getWithdrawal(int id) async {
    try {
      final res = await _client.get('/wallet/withdraw/$id');
      return WalletTransaction.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /wallet/me/withdrawals — historial de retiros, del más reciente al más
  /// antiguo. Reemplaza a GET /wallet/me/transactions (eliminado en el backend).
  Future<List<WalletTransaction>> getWithdrawals() async {
    try {
      final res = await _client.get('/wallet/me/withdrawals');
      final data = (res.data as List<dynamic>?) ?? const [];
      return data
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }
}
