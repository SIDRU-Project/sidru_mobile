import 'package:freezed_annotation/freezed_annotation.dart';

part 'withdrawal_status.freezed.dart';
part 'withdrawal_status.g.dart';

/// Estado del retiro de CTC desde la custodia hacia la wallet del ciudadano.
///
/// Respuesta de:
///   POST /wallet/withdraw           → estado inicial / resultado
///   GET  /wallet/withdraw/status    → último estado (o HTTP 204 → null)
///
/// El retiro es idempotente: estados EN_PROCESO / COMPLETADO / FALLIDO.
/// Por regla de negocio mueve el SALDO COMPLETO (RN-BC-05); la app solo envía
/// `toAddress`. `amountWei` llega como STRING para conservar los 18 decimales.
///
/// Campos:
///   - id          → identificador del retiro
///   - toAddress   → dirección destino (MetaMask) del ciudadano
///   - amountWei   → monto retirado en wei
///   - status      → EN_PROCESO | COMPLETADO | FALLIDO
///   - txHash      → hash on-chain (null mientras no exista)
///   - explorerUrl → enlace al explorador (null mientras no exista hash)
@freezed
class WithdrawalStatus with _$WithdrawalStatus {
  const factory WithdrawalStatus({
    required int id,
    required String toAddress,
    required String amountWei,
    required String status,
    String? txHash,
    String? explorerUrl,
  }) = _WithdrawalStatus;

  factory WithdrawalStatus.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalStatusFromJson(json);
}
