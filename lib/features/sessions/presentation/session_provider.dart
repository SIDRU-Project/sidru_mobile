import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../user/presentation/user_provider.dart';
import '../data/models/recycling_session.dart';
import '../data/models/smart_bin.dart';
import '../data/session_api.dart';
import '../data/session_repository.dart';
import '../utils/qr_token_parser.dart';

// ── Cadena de dependencias ────────────────────────────────────────────────────

final sessionApiProvider = Provider<SessionApi>((ref) {
  return SessionApi(ref.watch(apiClientProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(sessionApiProvider));
});

// ── Lista de sesiones ─────────────────────────────────────────────────────────

/// Lista completa de sesiones del usuario.
/// `build()` carga al observarse por primera vez.
/// Refresca con `ref.invalidate(sessionListProvider)`.
final sessionListProvider =
    AsyncNotifierProvider<SessionListNotifier, List<RecyclingSession>>(
      () => SessionListNotifier(),
    );

class SessionListNotifier extends AsyncNotifier<List<RecyclingSession>> {
  @override
  Future<List<RecyclingSession>> build() async {
    return _load();
  }

  Future<List<RecyclingSession>> _load() async {
    try {
      final sessions =
          await ref.read(sessionRepositoryProvider).getMySessions();
      // Ordenar por id descendente para que la más reciente quede primera
      sessions.sort((a, b) => b.id.compareTo(a.id));
      return sessions;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await ref.read(authNotifierProvider).logout();
        return [];
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

// ── Detalle de sesión (por ID) ────────────────────────────────────────────────

/// Carga el detalle de una sesión específica.
/// Se invalida automáticamente cuando el proveedor padre cambia.
final sessionDetailProvider = FutureProvider.family<RecyclingSession, int>((
  ref,
  id,
) async {
  try {
    return await ref.read(sessionRepositoryProvider).getSessionById(id);
  } on ApiException catch (e) {
    if (e.isUnauthorized) {
      await ref.read(authNotifierProvider).logout();
      rethrow;
    }
    rethrow;
  }
});

// ── Smart Bin (opcional, en detalle de sesión) ────────────────────────────────

final smartBinProvider = FutureProvider.family<SmartBin, int>((
  ref,
  binId,
) async {
  return ref.read(sessionRepositoryProvider).getSmartBin(binId);
});

// ── Flujo de escaneo QR ───────────────────────────────────────────────────────

/// Tipos de error del flujo de escaneo / confirmación.
/// Cada valor mapea a una variante visual de ScanErrorScreen.
enum ScanErrorType {
  invalid, // QR no corresponde a ninguna sesión (404)
  alreadyRedeemed, // sesión ya CONFIRMED
  expired, // sesión EXPIRED
  cancelled, // sesión CANCELLED
  noBackend, // sin conexión con el servidor
  confirmError, // error al confirmar
  serverError, // error genérico del backend
}

/// Resultado de consultar un QR.
sealed class QrLookupOutcome {
  const QrLookupOutcome();
}

class QrLookupSuccess extends QrLookupOutcome {
  final RecyclingSession session;
  const QrLookupSuccess(this.session);
}

class QrLookupFailure extends QrLookupOutcome {
  final ScanErrorType type;
  const QrLookupFailure(this.type);
}

/// Resultado de confirmar una sesión.
sealed class ConfirmOutcome {
  const ConfirmOutcome();
}

class ConfirmSuccess extends ConfirmOutcome {
  final RecyclingSession session;
  const ConfirmSuccess(this.session);
}

class ConfirmFailure extends ConfirmOutcome {
  final ScanErrorType type;
  const ConfirmFailure(this.type);
}

/// Controlador imperativo del flujo de escaneo y confirmación.
/// Las pantallas llaman a este provider (nunca al repositorio directamente).
final sessionScanControllerProvider = Provider<SessionScanController>((ref) {
  return SessionScanController(ref);
});

class SessionScanController {
  final Ref _ref;
  SessionScanController(this._ref);

  /// Recibe el valor crudo del QR, extrae el qrToken real y consulta la sesión.
  Future<QrLookupOutcome> getSessionByQr(String rawQrValue) async {
    final repo = _ref.read(sessionRepositoryProvider);
    final qrToken = QrTokenParser.parse(rawQrValue);
    if (qrToken == null) {
      return const QrLookupFailure(ScanErrorType.invalid);
    }

    try {
      final session = await repo.getSessionByQr(qrToken);
      return switch (session.status) {
        RecyclingSessionStatus.pending => QrLookupSuccess(session),
        RecyclingSessionStatus.confirmed => const QrLookupFailure(
          ScanErrorType.alreadyRedeemed,
        ),
        RecyclingSessionStatus.expired => const QrLookupFailure(
          ScanErrorType.expired,
        ),
        RecyclingSessionStatus.cancelled => const QrLookupFailure(
          ScanErrorType.cancelled,
        ),
      };
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _ref.read(authNotifierProvider).logout();
        return const QrLookupFailure(ScanErrorType.serverError);
      }
      return QrLookupFailure(_mapLookupError(e));
    } catch (e, st) {
      debugPrint('[SIDRU][QR] Lookup parse/runtime error: $e');
      debugPrintStack(stackTrace: st);
      return const QrLookupFailure(ScanErrorType.serverError);
    }
  }

  /// Confirma la sesión PENDING por qrToken y refresca perfil + historial.
  Future<ConfirmOutcome> confirmSessionByQr(String qrToken) async {
    final repo = _ref.read(sessionRepositoryProvider);
    final parsedQrToken = QrTokenParser.parse(qrToken);
    if (parsedQrToken == null) {
      return const ConfirmFailure(ScanErrorType.invalid);
    }

    try {
      final session = await repo.confirmSessionByQr(parsedQrToken);
      // Regla de negocio: tras confirmar, refrescar perfil (puntos) e historial.
      await _ref.read(userNotifierProvider.notifier).refresh();
      await _ref.read(sessionListProvider.notifier).refresh();
      return ConfirmSuccess(session);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _ref.read(authNotifierProvider).logout();
        return const ConfirmFailure(ScanErrorType.confirmError);
      }
      return ConfirmFailure(_mapConfirmError(e));
    } catch (e, st) {
      debugPrint('[SIDRU][QR] Confirm parse/runtime error: $e');
      debugPrintStack(stackTrace: st);
      return const ConfirmFailure(ScanErrorType.confirmError);
    }
  }

  ScanErrorType _mapLookupError(ApiException e) => switch (e.type) {
    ApiErrorType.notFound => ScanErrorType.invalid,
    ApiErrorType.networkError => ScanErrorType.noBackend,
    _ => ScanErrorType.serverError,
  };

  ScanErrorType _mapConfirmError(ApiException e) => switch (e.type) {
    ApiErrorType.conflict => ScanErrorType.alreadyRedeemed,
    ApiErrorType.notFound => ScanErrorType.invalid,
    ApiErrorType.networkError => ScanErrorType.noBackend,
    _ => ScanErrorType.confirmError,
  };
}
