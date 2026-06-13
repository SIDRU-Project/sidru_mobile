import 'package:freezed_annotation/freezed_annotation.dart';

part 'recycling_session.freezed.dart';
part 'recycling_session.g.dart';

/// Estados posibles de una sesión de reciclaje.
/// Mapean directamente los valores de string del backend.
enum RecyclingSessionStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('CONFIRMED')
  confirmed,

  @JsonValue('EXPIRED')
  expired,

  @JsonValue('CANCELLED')
  cancelled,
}

/// Modelo de sesión de reciclaje.
/// Respuesta de:
///   GET /sessions/qr/{qrToken}
///   POST /sessions/qr/{qrToken}/confirm
///   GET /sessions/me        (lista)
///   GET /sessions/{id}      (detalle)
///
/// Campos nullable:
///   - expiresAt:         puede ser null si el bin no registró expiración
///   - confirmedAt:       null mientras status sea PENDING
///   - blockchainTxHash:  null hasta que la transacción blockchain sea emitida
@freezed
class RecyclingSession with _$RecyclingSession {
  const factory RecyclingSession({
    required int id,
    required int smartBinId,
    int? userId,
    required int capCount,
    required double weightGrams,
    required int pointsEarned,
    required String qrToken,
    required RecyclingSessionStatus status,
    DateTime? expiresAt,
    DateTime? confirmedAt,
    String? blockchainTxHash,
  }) = _RecyclingSession;

  factory RecyclingSession.fromJson(Map<String, dynamic> json) =>
      _$RecyclingSessionFromJson(json);
}
