import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/models/wallet_balance.dart';
import '../data/models/wallet_transaction.dart';
import '../data/models/withdrawal_status.dart';
import '../data/wallet_api.dart';
import '../data/wallet_repository.dart';

// ── Cadena de dependencias (C4) ───────────────────────────────────────────────

final walletApiProvider = Provider<WalletApi>((ref) {
  return WalletApi(ref.watch(apiClientProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(walletApiProvider));
});

// ── Balance / wallet del usuario ──────────────────────────────────────────────

/// Estado de la wallet del usuario (GET /wallet/me).
/// `autoDispose`: se desecha al salir de la WalletScreen y re-consulta el saldo
/// on-chain cada vez que se vuelve a abrir (balance/transacciones siempre frescos).
final walletProvider =
    AsyncNotifierProvider.autoDispose<WalletNotifier, WalletBalance?>(
      () => WalletNotifier(),
    );

class WalletNotifier extends AutoDisposeAsyncNotifier<WalletBalance?> {
  @override
  Future<WalletBalance?> build() async {
    return _load();
  }

  Future<WalletBalance?> _load() async {
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

// ── Transacciones recientes ───────────────────────────────────────────────────

/// Transacciones on-chain del usuario (GET /wallet/me/transactions).
/// `autoDispose`: se recargan cada vez que se abre la WalletScreen.
final walletTransactionsProvider =
    FutureProvider.autoDispose<List<WalletTransaction>>((ref) async {
  try {
    return await ref.read(walletRepositoryProvider).getTransactions();
  } on ApiException catch (e) {
    if (e.isUnauthorized) {
      await ref.read(authNotifierProvider).logout();
      return const [];
    }
    rethrow;
  }
});

// ── Acción de retiro ──────────────────────────────────────────────────────────

/// Resultado del flujo de retiro hacia el sheet (sin exponer detalles HTTP).
sealed class WithdrawOutcome {
  const WithdrawOutcome();
}

class WithdrawSuccess extends WithdrawOutcome {
  final WithdrawalStatus status;
  const WithdrawSuccess(this.status);
}

class WithdrawFailure extends WithdrawOutcome {
  final String message;
  const WithdrawFailure(this.message);
}

/// Controlador imperativo del retiro. Las pantallas llaman a este provider
/// (nunca al repositorio directamente).
final walletWithdrawControllerProvider = Provider<WalletWithdrawController>((
  ref,
) {
  return WalletWithdrawController(ref);
});

class WalletWithdrawController {
  final Ref _ref;
  WalletWithdrawController(this._ref);

  /// Inicia el retiro del saldo completo hacia [toAddress].
  /// Al COMPLETAR, refresca balance y transacciones (RN-BC-05).
  Future<WithdrawOutcome> withdraw(String toAddress) async {
    try {
      final status = await _ref
          .read(walletRepositoryProvider)
          .withdraw(toAddress.trim());
      // Tras un retiro exitoso, refrescar balance e historial.
      await _ref.read(walletProvider.notifier).refresh();
      _ref.invalidate(walletTransactionsProvider);
      return WithdrawSuccess(status);
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

  /// Mapea el error del backend a un mensaje de negocio para el sheet.
  /// Estados: ERR-BC-04 (dirección inválida), ERR-BC-05 (sin saldo),
  /// ERR-BC-07 (retiro en curso).
  String _mapWithdrawError(ApiException e) {
    // Si el backend trae un mensaje específico, priorizarlo.
    final backendMsg = e.message.trim();
    return switch (e.type) {
      ApiErrorType.badRequest =>
        backendMsg.isNotEmpty ? backendMsg : 'Dirección de retiro inválida.',
      ApiErrorType.conflict =>
        backendMsg.isNotEmpty
            ? backendMsg
            : 'Ya tienes un retiro en proceso. Espera a que finalice.',
      ApiErrorType.networkError =>
        'Sin conexión con el servidor. Verifica tu internet.',
      _ =>
        backendMsg.isNotEmpty ? backendMsg : 'No se pudo procesar el retiro.',
    };
  }
}
