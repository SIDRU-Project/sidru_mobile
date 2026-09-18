import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_summary.freezed.dart';
part 'wallet_summary.g.dart';

/// Resumen de la wallet del ciudadano (spec sidru-mainnet).
///
/// Respuesta de: GET /wallet/me
///
/// El saldo pasa a ser de PUNTOS, no un balance on-chain (US-MN-05): ya no hay
/// dirección custodial que consultar. `pointsBalance` es `UserProfile.totalPoints`,
/// la única fuente de verdad. `ctcEquivalent` (1 punto = 1 CTC) y `solesEquivalent`
/// (puntos / 100, dos decimales) son conversiones puramente aritméticas, entregadas
/// como STRING por coherencia con el resto de la API. `linkedWallet` es la dirección
/// del último retiro COMPLETADO, o null si el ciudadano nunca retiró.
@freezed
class WalletSummary with _$WalletSummary {
  const factory WalletSummary({
    required int pointsBalance,
    required String ctcEquivalent,
    required String solesEquivalent,
    required String network,
    required String explorerBaseUrl,
    String? linkedWallet,
    required int minWithdrawalPoints,
    required bool withdrawalsEnabled,
    required bool hasWithdrawalInProgress,
  }) = _WalletSummary;

  factory WalletSummary.fromJson(Map<String, dynamic> json) =>
      _$WalletSummaryFromJson(json);
}
