import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_error_mapper.dart';
import 'models/wallet_balance.dart';
import 'models/wallet_transaction.dart';
import 'models/withdrawal_status.dart';

/// Datasource HTTP de la wallet CTC del ciudadano.
/// Cadena C4: WalletRepository → WalletApi → ApiClient → JwtInterceptor.
/// Las pantallas nunca usan Dio directamente.
class WalletApi {
  final ApiClient _client;

  WalletApi(this._client);

  /// GET /wallet/me — dirección custodial, red, balance CTC y wallet vinculada.
  Future<WalletBalance> getWallet() async {
    try {
      final res = await _client.get('/wallet/me');
      return WalletBalance.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /wallet/me/transactions — transacciones on-chain del usuario.
  Future<List<WalletTransaction>> getTransactions() async {
    try {
      final res = await _client.get('/wallet/me/transactions');
      final data = (res.data as List<dynamic>?) ?? const [];
      return data
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// POST /wallet/withdraw — inicia el retiro idempotente del saldo completo
  /// hacia `toAddress`. El backend revalida el checksum EIP-55.
  Future<WithdrawalStatus> withdraw(String toAddress) async {
    try {
      final res = await _client.post(
        '/wallet/withdraw',
        data: {'toAddress': toAddress},
      );
      return WithdrawalStatus.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /wallet/withdraw/status — estado del último retiro.
  /// HTTP 204 (sin body) significa "no hay retiros" → devuelve null.
  Future<WithdrawalStatus?> getWithdrawStatus() async {
    try {
      final res = await _client.get('/wallet/withdraw/status');
      if (res.statusCode == 204 || res.data == null) return null;
      final data = res.data;
      if (data is! Map<String, dynamic>) return null;
      return WithdrawalStatus.fromJson(data);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }
}
