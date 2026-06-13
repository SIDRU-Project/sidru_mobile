import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_error_mapper.dart';
import 'models/recycling_session.dart';
import 'models/smart_bin.dart';

/// Datasource HTTP de sesiones de reciclaje.
class SessionApi {
  final ApiClient _client;

  SessionApi(this._client);

  /// GET /sessions/me — lista de sesiones del usuario autenticado.
  Future<List<RecyclingSession>> getMySessions() async {
    try {
      final res = await _client.get('/sessions/me');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => RecyclingSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /sessions/{id} — detalle de una sesión por ID.
  Future<RecyclingSession> getSessionById(int id) async {
    try {
      final res = await _client.get('/sessions/$id');
      return RecyclingSession.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /sessions/qr/{qrToken} — consulta una sesión por el token del QR.
  Future<RecyclingSession> getSessionByQr(String qrToken) async {
    try {
      final res = await _client.get(
        '/sessions/qr/${Uri.encodeComponent(qrToken)}',
      );
      debugPrint('[SIDRU][QR] GET /sessions/qr/$qrToken -> ${res.statusCode}');
      debugPrint('[SIDRU][QR] Response: ${res.data}');
      return RecyclingSession.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// POST /sessions/qr/{qrToken}/confirm — confirma una sesión PENDING.
  Future<RecyclingSession> confirmSessionByQr(String qrToken) async {
    try {
      final res = await _client.post(
        '/sessions/qr/${Uri.encodeComponent(qrToken)}/confirm',
      );
      debugPrint(
        '[SIDRU][QR] POST /sessions/qr/$qrToken/confirm -> ${res.statusCode}',
      );
      debugPrint('[SIDRU][QR] Confirm response: ${res.data}');
      return RecyclingSession.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }

  /// GET /smart-bins/{id} — datos del Smart Bin para mostrar ubicación.
  /// Opcional: se usa en SessionDetailScreen si smartBinId está disponible.
  Future<SmartBin> getSmartBin(int id) async {
    try {
      final res = await _client.get('/smart-bins/$id');
      return SmartBin.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkErrorMapper.map(e);
    }
  }
}
