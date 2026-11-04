import '../../../core/network/api_exception.dart';
import 'models/wallet_snapshot.dart';
import 'models/wallet_summary.dart';
import 'models/wallet_transaction.dart';
import 'wallet_api.dart';
import 'wallet_cache.dart';

/// Abstrae las operaciones de wallet del ciudadano (spec sidru-mainnet).
/// Delega en [WalletApi]; no contiene lógica HTTP directa.
/// Lanza [ApiException] ante errores del backend o de red.
class WalletRepository {
  final WalletApi _api;
  final WalletCache _cache;

  WalletRepository(this._api, this._cache);

  /// Resumen de la wallet: puntos, equivalencias, red y wallet vinculada.
  ///
  /// El saldo de puntos es la única fuente de verdad (US-MN-05). Si no hay
  /// conexión y existe un resumen cacheado, se devuelve ese último valor
  /// conocido marcado como `fromCache` para que la pantalla muestre el
  /// indicador de modo offline (CP019, paso 4). Cualquier otro error —401,
  /// 5xx, etc.— se propaga: mostrar un saldo viejo ante un fallo del backend
  /// ocultaría el problema real.
  Future<WalletSnapshot> getWallet() async {
    try {
      final summary = await _api.getWallet();
      await _cache.save(summary);
      return WalletSnapshot.live(summary);
    } on ApiException catch (e) {
      if (e.isNetworkError) {
        final cached = await _cache.read();
        if (cached != null) return WalletSnapshot.cached(cached);
      }
      rethrow;
    }
  }

  /// Último resumen cacheado, sin tocar la red. `null` si nunca se guardó uno.
  Future<WalletSummary?> cachedWallet() => _cache.read();

  /// Descarta el resumen cacheado (al cerrar sesión).
  Future<void> clearCache() => _cache.clear();

  /// Inicia un retiro de [points] puntos en modo [mode] hacia [toAddress].
  Future<WalletTransaction> withdraw({
    required String toAddress,
    required int points,
    required String mode,
  }) => _api.withdraw(toAddress: toAddress, points: points, mode: mode);

  /// Estado de un retiro puntual (para el polling tras iniciar uno EN_PROCESO).
  Future<WalletTransaction> getWithdrawal(int id) => _api.getWithdrawal(id);

  /// Historial de retiros del usuario, del más reciente al más antiguo.
  Future<List<WalletTransaction>> getWithdrawals() => _api.getWithdrawals();
}
