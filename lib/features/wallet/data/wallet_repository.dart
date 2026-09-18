import '../../../core/network/api_exception.dart';
import 'models/wallet_balance.dart';
import 'models/wallet_snapshot.dart';
import 'models/wallet_transaction.dart';
import 'models/withdrawal_status.dart';
import 'wallet_api.dart';
import 'wallet_cache.dart';

/// Abstrae las operaciones de wallet CTC.
/// Delega en [WalletApi]; no contiene lógica HTTP directa.
/// Lanza [ApiException] ante errores del backend o de red.
class WalletRepository {
  final WalletApi _api;
  final WalletCache _cache;

  WalletRepository(this._api, this._cache);

  /// Wallet del usuario: dirección, red, balance y wallet vinculada.
  ///
  /// El saldo en vivo es `balanceOf` on-chain y es la única fuente de verdad (US-25 AC3).
  /// Si no hay conexión y existe un saldo cacheado, se devuelve ese último valor conocido
  /// marcado como `fromCache` para que la pantalla muestre el indicador de modo offline
  /// (CP019, paso 4). Cualquier otro error —401, 5xx, etc.— se propaga: mostrar un saldo
  /// viejo ante un fallo del backend ocultaría el problema real.
  Future<WalletSnapshot> getWallet() async {
    try {
      final balance = await _api.getWallet();
      await _cache.save(balance);
      return WalletSnapshot.live(balance);
    } on ApiException catch (e) {
      if (e.isNetworkError) {
        final cached = await _cache.read();
        if (cached != null) return WalletSnapshot.cached(cached);
      }
      rethrow;
    }
  }

  /// Último saldo cacheado, sin tocar la red. `null` si nunca se guardó uno.
  Future<WalletBalance?> cachedWallet() => _cache.read();

  /// Descarta el saldo cacheado (al cerrar sesión).
  Future<void> clearCache() => _cache.clear();

  /// Transacciones on-chain recientes del usuario.
  Future<List<WalletTransaction>> getTransactions() => _api.getTransactions();

  /// Inicia el retiro del saldo completo hacia [toAddress].
  Future<WithdrawalStatus> withdraw(String toAddress) =>
      _api.withdraw(toAddress);

  /// Estado del último retiro (null si no hay retiros).
  Future<WithdrawalStatus?> getWithdrawStatus() => _api.getWithdrawStatus();
}
