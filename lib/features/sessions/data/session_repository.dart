import 'models/recycling_session.dart';
import 'models/smart_bin.dart';
import 'session_api.dart';

/// Abstrae las operaciones de sesiones de reciclaje.
/// Lanza [ApiException] ante errores del backend o de red.
class SessionRepository {
  final SessionApi _api;

  SessionRepository(this._api);

  /// Lista todas las sesiones del usuario.
  Future<List<RecyclingSession>> getMySessions() => _api.getMySessions();

  /// Detalle de una sesión por ID.
  Future<RecyclingSession> getSessionById(int id) => _api.getSessionById(id);

  /// Consulta una sesión por el token del QR escaneado.
  Future<RecyclingSession> getSessionByQr(String qrToken) =>
      _api.getSessionByQr(qrToken);

  /// Confirma una sesión PENDING por qrToken; acredita los puntos al usuario.
  Future<RecyclingSession> confirmSessionByQr(String qrToken) =>
      _api.confirmSessionByQr(qrToken);

  /// Datos del Smart Bin (opcional — para mostrar ubicación en detalle).
  Future<SmartBin> getSmartBin(int id) => _api.getSmartBin(id);
}
