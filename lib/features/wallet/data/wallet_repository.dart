import 'models/wallet_balance.dart';
import 'models/wallet_transaction.dart';
import 'models/withdrawal_status.dart';
import 'wallet_api.dart';

/// Abstrae las operaciones de wallet CTC.
/// Delega en [WalletApi]; no contiene lógica HTTP directa.
/// Lanza [ApiException] ante errores del backend o de red.
class WalletRepository {
  final WalletApi _api;

  WalletRepository(this._api);

  /// Wallet del usuario: dirección, red, balance y wallet vinculada.
  Future<WalletBalance> getWallet() => _api.getWallet();

  /// Transacciones on-chain recientes del usuario.
  Future<List<WalletTransaction>> getTransactions() => _api.getTransactions();

  /// Inicia el retiro del saldo completo hacia [toAddress].
  Future<WithdrawalStatus> withdraw(String toAddress) =>
      _api.withdraw(toAddress);

  /// Estado del último retiro (null si no hay retiros).
  Future<WithdrawalStatus?> getWithdrawStatus() => _api.getWithdrawStatus();
}
