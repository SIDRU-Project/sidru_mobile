import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_transaction.freezed.dart';
part 'wallet_transaction.g.dart';

/// Un retiro del ciudadano (spec sidru-mainnet): CTC minteado a su wallet o USDC
/// pagado desde la reserva. Reemplaza al modelo de "transacción on-chain" del mint
/// por sesión: con emisión al retirar, el único movimiento de la wallet es el
/// retiro (US-MN-07: confirmar una sesión ya no toca la cadena).
///
/// Respuesta de:
///   POST /wallet/withdraw            (item)
///   GET  /wallet/withdraw/{id}       (item)
///   GET  /wallet/me/withdrawals      (lista, del más reciente al más antiguo)
///
/// `status` es `EN_PROCESO` | `COMPLETADO` | `FALLIDO`. `txHash`/`explorerUrl` son
/// null mientras no confirme. `failureReason` solo se llena si `FALLIDO`.
/// `reserveOut` solo aplica a `mode == "USDC"`, y puede quedar null aun
/// `COMPLETADO` si el retiro se confirmó por lectura on-chain (sin recibo que
/// decodificar) en vez de por el recibo directo de la transacción.
@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required int id,
    required String mode,
    required int points,
    required String amountWei,
    required String toAddress,
    required String status,
    String? txHash,
    String? explorerUrl,
    String? failureReason,
    String? reserveOut,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
}
