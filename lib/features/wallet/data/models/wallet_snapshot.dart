import 'wallet_summary.dart';

/// Estado de la wallet tal como lo consume la pantalla, junto con su procedencia.
///
/// `fromCache = false` → el resumen viene de consultar `/wallet/me` recién: es el
/// saldo de puntos vigente (CP019, pasos 1-3).
/// `fromCache = true`  → no hubo conexión y se está mostrando el último resumen
/// conocido. La pantalla debe señalarlo con el indicador de modo offline (CP019,
/// paso 4), porque puede haber quedado desactualizado.
class WalletSnapshot {
  final WalletSummary summary;
  final bool fromCache;

  const WalletSnapshot({required this.summary, this.fromCache = false});

  /// Snapshot en vivo, recién traído del backend.
  const WalletSnapshot.live(WalletSummary summary)
    : this(summary: summary, fromCache: false);

  /// Snapshot servido desde el caché local por falta de conexión.
  const WalletSnapshot.cached(WalletSummary summary)
    : this(summary: summary, fromCache: true);
}
