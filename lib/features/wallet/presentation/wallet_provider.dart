import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/models/wallet_snapshot.dart';
import '../data/models/wallet_transaction.dart';
import '../data/wallet_api.dart';
import '../data/wallet_cache.dart';
import '../data/wallet_repository.dart';

// Cadena de dependencias (C4)

final walletApiProvider = Provider<WalletApi>((ref) {
  return WalletApi(ref.watch(apiClientProvider));
});

/// Caché del último resumen conocido, para el modo offline de la WalletScreen (CP019).
final walletCacheProvider = Provider<WalletCache>((ref) {
  return WalletCache(SecureWalletCacheStore());
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(walletApiProvider), ref.watch(walletCacheProvider));
});

// Resumen de la wallet del usuario

/// Estado de la wallet del usuario (GET /wallet/me).
/// `autoDispose`: se desecha al salir de la WalletScreen y re-consulta el saldo
/// cada vez que se vuelve a abrir. El valor incluye si vino de la red o del
/// caché offline (CP019).
final walletProvider =
    AsyncNotifierProvider.autoDispose<WalletNotifier, WalletSnapshot?>(
      () => WalletNotifier(),
    );

class WalletNotifier extends AutoDisposeAsyncNotifier<WalletSnapshot?> {
  @override
  Future<WalletSnapshot?> build() async {
    return _load();
  }

  Future<WalletSnapshot?> _load() async {
    try {
      return await ref.read(walletRepositoryProvider).getWallet();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await ref.read(authNotifierProvider).logout();
        return null;
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

// Historial de retiros

/// Historial de retiros del usuario (GET /wallet/me/withdrawals), del más
/// reciente al más antiguo. `autoDispose`: se recarga cada vez que se abre la
/// WalletScreen.
final walletWithdrawalsProvider =
    FutureProvider.autoDispose<List<WalletTransaction>>((ref) async {
  try {
    return await ref.read(walletRepositoryProvider).getWithdrawals();
  } on ApiException catch (e) {
    if (e.isUnauthorized) {
      await ref.read(authNotifierProvider).logout();
      return const [];
    }
    rethrow;
  }
});

// Acción de retiro

/// Resultado del flujo de retiro hacia el sheet (sin exponer detalles HTTP).
sealed class WithdrawOutcome {
  const WithdrawOutcome();
}

class WithdrawSuccess extends WithdrawOutcome {
  final WalletTransaction transaction;
  const WithdrawSuccess(this.transaction);
}

class WithdrawFailure extends WithdrawOutcome {
  final String message;
  const WithdrawFailure(this.message);
}

/// Desenlace de esperar (polling) el estado final de un retiro que quedó
/// EN_PROCESO al iniciarlo.
sealed class WithdrawPollResult {
  const WithdrawPollResult();
}

class WithdrawPollResolved extends WithdrawPollResult {
  final WalletTransaction transaction;
  const WithdrawPollResolved(this.transaction);
}

/// Se agotaron los 2 minutos de espera sin que el retiro saliera de EN_PROCESO
/// (api-contract.md): la app deja de preguntar y confía en la notificación push.
class WithdrawPollTimedOut extends WithdrawPollResult {
  const WithdrawPollTimedOut();
}

/// Controlador imperativo del retiro. Las pantallas llaman a este provider
/// (nunca al repositorio directamente).
final walletWithdrawControllerProvider = Provider<WalletWithdrawController>((
  ref,
) {
  return WalletWithdrawController(ref);
});

class WalletWithdrawController {
  static const _pollInterval = Duration(seconds: 5);
  static const _pollTimeout = Duration(minutes: 2);

  final Ref _ref;
  WalletWithdrawController(this._ref);

  /// Inicia el retiro de [points] puntos en modo [mode] ("CTC"/"USDC") hacia
  /// [toAddress]. Si el resultado ya es final (COMPLETADO/FALLIDO), refresca
  /// saldo e historial de inmediato; si queda EN_PROCESO, el llamador decide si
  /// espera con [pollWithdrawal].
  Future<WithdrawOutcome> withdraw({
    required String toAddress,
    required int points,
    required String mode,
  }) async {
    try {
      final transaction = await _ref.read(walletRepositoryProvider).withdraw(
        toAddress: toAddress.trim(),
        points: points,
        mode: mode,
      );
      await _refreshAfterOutcome();
      return WithdrawSuccess(transaction);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _ref.read(authNotifierProvider).logout();
        return const WithdrawFailure(
          'Sesión expirada. Inicia sesión nuevamente.',
        );
      }
      return WithdrawFailure(_mapWithdrawError(e));
    }
  }

  /// Consulta GET /wallet/withdraw/{id} cada 5 s hasta que el retiro salga de
  /// EN_PROCESO, con un tope de 2 minutos. Un fallo de red puntual durante la
  /// espera no la corta: se reintenta en el siguiente tick.
  Future<WithdrawPollResult> pollWithdrawal(int id) async {
    final deadline = DateTime.now().add(_pollTimeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(_pollInterval);
      try {
        final transaction =
            await _ref.read(walletRepositoryProvider).getWithdrawal(id);
        if (transaction.status != 'EN_PROCESO') {
          await _refreshAfterOutcome();
          return WithdrawPollResolved(transaction);
        }
      } on ApiException {
        // Best-effort: seguir intentando hasta el tope.
      }
    }
    return const WithdrawPollTimedOut();
  }

  Future<void> _refreshAfterOutcome() async {
    await _ref.read(walletProvider.notifier).refresh();
    _ref.invalidate(walletWithdrawalsProvider);
  }

  /// Mapea el error del backend a un mensaje de negocio para el sheet.
  /// Códigos: ERR_BC_004 (dirección inválida), ERR_BC_005 (puntos insuficientes),
  /// ERR_BC_007 (retiro en curso), ERR_BC_009 (bajo el mínimo), ERR_BC_010
  /// (retiros deshabilitados), ERR_BC_011 (retiro inexistente).
  String _mapWithdrawError(ApiException e) {
    // Si el backend trae un mensaje específico, priorizarlo.
    final backendMsg = e.message.trim();
    return switch (e.type) {
      ApiErrorType.badRequest =>
        backendMsg.isNotEmpty
            ? backendMsg
            : 'Dirección de retiro o monto inválidos.',
      ApiErrorType.unprocessableEntity =>
        backendMsg.isNotEmpty ? backendMsg : 'Puntos insuficientes.',
      ApiErrorType.conflict =>
        backendMsg.isNotEmpty
            ? backendMsg
            : 'Ya tienes un retiro en proceso. Espera a que finalice.',
      ApiErrorType.serviceUnavailable =>
        backendMsg.isNotEmpty
            ? backendMsg
            : 'Los retiros están temporalmente deshabilitados.',
      ApiErrorType.notFound =>
        backendMsg.isNotEmpty ? backendMsg : 'Retiro no encontrado.',
      ApiErrorType.networkError =>
        'Sin conexión con el servidor. Verifica tu internet.',
      _ =>
        backendMsg.isNotEmpty ? backendMsg : 'No se pudo procesar el retiro.',
    };
  }
}
