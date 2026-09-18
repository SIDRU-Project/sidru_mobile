import 'wallet_balance.dart';

/// Estado de la wallet tal como lo consume la pantalla, junto con su procedencia.
///
/// `fromCache = false` → el saldo viene de consultar `balanceOf` on-chain a través del
/// backend: es el saldo real y vigente (CP019, pasos 1-3).
/// `fromCache = true`  → no hubo conexión y se está mostrando el último saldo conocido.
/// La pantalla debe señalarlo con el indicador de modo offline (CP019, paso 4), porque
/// un saldo cacheado puede haber quedado desactualizado.
class WalletSnapshot {
  final WalletBalance balance;
  final bool fromCache;

  const WalletSnapshot({required this.balance, this.fromCache = false});

  /// Snapshot en vivo, recién traído del backend.
  const WalletSnapshot.live(WalletBalance balance)
    : this(balance: balance, fromCache: false);

  /// Snapshot servido desde el caché local por falta de conexión.
  const WalletSnapshot.cached(WalletBalance balance)
    : this(balance: balance, fromCache: true);
}
