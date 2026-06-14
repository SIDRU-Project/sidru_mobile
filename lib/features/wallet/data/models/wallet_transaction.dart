import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_transaction.freezed.dart';
part 'wallet_transaction.g.dart';

/// Tipo de transacción on-chain del ciudadano.
/// Mapea los valores de string del backend.
enum WalletTransactionType {
  @JsonValue('MINT')
  mint,

  @JsonValue('WITHDRAW')
  withdraw,

  /// Fallback defensivo para tipos no contemplados por la app.
  @JsonValue('UNKNOWN')
  unknown,
}

/// Transacción on-chain de la wallet del ciudadano.
///
/// Respuesta (lista) de: GET /wallet/me/transactions
///
/// IMPORTANTE: el backend NO entrega un monto por transacción. La app NO debe
/// inventar ni mostrar un `amount`: solo tipo, hash, estado de confirmación y
/// enlace al explorador para auditar (RF-19).
///
/// Campos:
///   - type        → MINT | WITHDRAW
///   - txHash      → hash de la transacción (0x..)
///   - status      → estado de confirmación reportado por el backend
///   - explorerUrl → enlace directo a amoy.polygonscan.com/tx/{txHash}
@freezed
class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    // ignore: invalid_annotation_target
    @JsonKey(unknownEnumValue: WalletTransactionType.unknown)
    required WalletTransactionType type,
    required String txHash,
    required String status,
    required String explorerUrl,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
}
