import 'package:freezed_annotation/freezed_annotation.dart';

part 'point_transaction.freezed.dart';
part 'point_transaction.g.dart';

/// Tipos de movimiento de puntos.
/// EARN  → puntos ganados por confirmar una sesión.
/// REDEEM → puntos gastados al canjear una recompensa.
enum PointTransactionType {
  @JsonValue('EARN')
  earn,

  @JsonValue('REDEEM')
  redeem,
}

/// Respuesta de GET /rewards/transactions/me (lista) y
/// POST /rewards/redeem (resultado del canje).
///
/// points siempre es positivo; el tipo indica si fue ganado o gastado.
/// createdAt es obligatorio en todos los registros del backend.
@freezed
class PointTransaction with _$PointTransaction {
  const factory PointTransaction({
    required int id,
    required int userId,
    required PointTransactionType type,
    required int points,
    required String description,
    required DateTime createdAt,
  }) = _PointTransaction;

  factory PointTransaction.fromJson(Map<String, dynamic> json) =>
      _$PointTransactionFromJson(json);
}
