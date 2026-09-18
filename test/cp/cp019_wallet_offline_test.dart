import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/core/network/api_exception.dart';
import 'package:sidru_mobile/features/wallet/data/models/wallet_summary.dart';
import 'package:sidru_mobile/features/wallet/data/models/wallet_transaction.dart';
import 'package:sidru_mobile/features/wallet/data/wallet_api.dart';
import 'package:sidru_mobile/features/wallet/data/wallet_cache.dart';
import 'package:sidru_mobile/features/wallet/data/wallet_repository.dart';

/// CP019 — Coincidencia del saldo mostrado (US-MN-05, esc. "Pantalla Wallet").
///
/// Lado app del caso. Con emisión al retirar, el saldo ya no es un balance
/// on-chain: es `UserProfile.totalPoints`, que expone el backend en
/// `pointsBalance` (verificado ahí, que es quien lo calcula). Aquí se comprueba
/// que la app no altera ese valor y que el modo offline —último resumen
/// cacheado con indicador— se comporta como exige el caso (paso 4).

/// Almacén en memoria: el caché se prueba sin depender del almacenamiento del
/// dispositivo.
class InMemoryCacheStore implements WalletCacheStore {
  String? value;
  int writes = 0;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String v) async {
    value = v;
    writes++;
  }

  @override
  Future<void> clear() async => value = null;
}

/// Doble de la API que responde lo que le pidan o falla como se le indique.
class FakeWalletApi implements WalletApi {
  WalletSummary? summary;
  ApiException? error;
  int getWalletCalls = 0;

  @override
  Future<WalletSummary> getWallet() async {
    getWalletCalls++;
    if (error != null) throw error!;
    return summary!;
  }

  @override
  Future<WalletTransaction> withdraw({
    required String toAddress,
    required int points,
    required String mode,
  }) => throw UnimplementedError();

  @override
  Future<WalletTransaction> getWithdrawal(int id) => throw UnimplementedError();

  @override
  Future<List<WalletTransaction>> getWithdrawals() async => const [];
}

const _summary = WalletSummary(
  pointsBalance: 200,
  ctcEquivalent: '200',
  solesEquivalent: '2.00',
  network: 'polygon',
  explorerBaseUrl: 'https://polygonscan.com',
  linkedWallet: null,
  minWithdrawalPoints: 500,
  withdrawalsEnabled: true,
  hasWithdrawalInProgress: false,
);

const _networkError = ApiException(
  message: 'Sin conexión con el servidor.',
  type: ApiErrorType.networkError,
);

void main() {
  late InMemoryCacheStore store;
  late FakeWalletApi api;
  late WalletRepository repository;

  setUp(() {
    store = InMemoryCacheStore();
    api = FakeWalletApi();
    repository = WalletRepository(api, WalletCache(store));
  });

  group('CP019 - saldo en vivo', () {
    test('Paso 1-3: expone el resumen del backend sin alterarlo ni redondearlo', () async {
      api.summary = _summary;

      final snapshot = await repository.getWallet();

      expect(snapshot.fromCache, isFalse, reason: 'el saldo debe venir de la red');
      expect(snapshot.summary.pointsBalance, 200);
      expect(snapshot.summary.ctcEquivalent, '200');
      expect(snapshot.summary.solesEquivalent, '2.00');
      expect(snapshot.summary.network, 'polygon');
    });

    test('cada consulta exitosa refresca el resumen cacheado', () async {
      api.summary = _summary;
      await repository.getWallet();

      expect(store.writes, 1);
      expect(await repository.cachedWallet(), isNotNull);
      expect(
        (await repository.cachedWallet())!.pointsBalance,
        _summary.pointsBalance,
      );
    });
  });

  group('CP019 - Paso 4: modo offline', () {
    test('sin conexión devuelve el último resumen conocido marcado como cacheado', () async {
      // Primero una consulta exitosa que deja el resumen en caché.
      api.summary = _summary;
      await repository.getWallet();

      // Ahora se cae la conectividad del dispositivo.
      api.error = _networkError;
      final snapshot = await repository.getWallet();

      expect(snapshot.fromCache, isTrue,
          reason: 'la pantalla debe poder mostrar el indicador de modo offline');
      expect(snapshot.summary.pointsBalance, _summary.pointsBalance,
          reason: 'debe mostrarse el último saldo conocido');
    });

    test('sin conexión y sin caché previo, el error se propaga', () async {
      api.error = _networkError;

      expect(() => repository.getWallet(), throwsA(isA<ApiException>()));
    });

    test('un error del backend NO se disimula con el resumen cacheado', () async {
      api.summary = _summary;
      await repository.getWallet();

      // 500 del servidor: mostrar un saldo viejo ocultaría el fallo real.
      api.error = const ApiException(
        message: 'Error interno',
        statusCode: 500,
        type: ApiErrorType.serverError,
      );

      expect(() => repository.getWallet(), throwsA(isA<ApiException>()));
    });

    test('al cerrar sesión el resumen cacheado se descarta', () async {
      api.summary = _summary;
      await repository.getWallet();
      expect(await repository.cachedWallet(), isNotNull);

      await repository.clearCache();

      expect(await repository.cachedWallet(), isNull,
          reason: 'el saldo de un ciudadano no debe sobrevivir al cierre de sesión');
    });

    test('un caché corrupto se ignora en vez de romper la pantalla', () async {
      store.value = 'no-es-json';
      expect(await repository.cachedWallet(), isNull);
    });
  });
}
