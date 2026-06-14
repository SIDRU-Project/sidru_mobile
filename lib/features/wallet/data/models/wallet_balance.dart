import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_balance.freezed.dart';
part 'wallet_balance.g.dart';

/// Estado de la wallet custodial del ciudadano.
///
/// Respuesta de: GET /wallet/me
///
/// El backend entrega TODOS los campos numéricos como STRING para no perder
/// precisión con los 18 decimales de CTC. No se convierten a num: el balance
/// (`balanceOf` on-chain) es la fuente de verdad del saldo y `solesRef` es una
/// equivalencia REFERENCIAL (1 CTC ≈ S/ 0.01), nunca un tipo de cambio real.
///
/// Campos:
///   - address       → dirección custodial EVM del ciudadano (0x..)
///   - network       → red activa, ej: "polygon-amoy"
///   - balanceCtc    → saldo CTC ya formateado (entero/decimal legible), ej: "280"
///   - balanceWei    → saldo en wei (18 decimales), ej: "280000000000000000000"
///   - solesRef      → equivalencia referencial en soles, ej: "2.80"
///   - linkedWallet  → wallet de retiro vinculada (MetaMask), null si no hay
@freezed
class WalletBalance with _$WalletBalance {
  const factory WalletBalance({
    required String address,
    required String network,
    required String balanceCtc,
    required String balanceWei,
    required String solesRef,
    String? linkedWallet,
  }) = _WalletBalance;

  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceFromJson(json);
}
