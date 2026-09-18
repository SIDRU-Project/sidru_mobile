import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/core/network/api_exception.dart';
import 'package:sidru_mobile/features/wallet/data/models/wallet_balance.dart';
import 'package:sidru_mobile/features/wallet/data/models/wallet_transaction.dart';
import 'package:sidru_mobile/features/wallet/data/models/withdrawal_status.dart';
import 'package:sidru_mobile/features/wallet/data/wallet_api.dart';
import 'package:sidru_mobile/features/wallet/data/wallet_cache.dart';
import 'package:sidru_mobile/features/wallet/data/wallet_repository.dart';

/// CP019 — Coincidencia del saldo mostrado con el balance custodial (US-25, esc. 3).
///
/// Lado app del caso. Los pasos 1-3 (el saldo expuesto es exactamente `balanceOf`) se
/// verifican en el backend, que es quien consulta la cadena; aquí se comprueba que la app
/// no altera ese valor y que el paso 4 —sin conexión, último saldo cacheado con indicador
/// de modo offline— se comporta como exige el caso.

/// Almacén en memoria: el caché se prueba sin depender del almacenamiento del dispositivo.
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
  WalletBalance? balance;
  ApiException? error;
  int getWalletCalls = 0;

  @override
  Future<WalletBalance> getWallet() async {
    getWalletCalls++;
    if (error != null) throw error!;
    return balance!;
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async => const [];

  @override
  Future<WithdrawalStatus> withdraw(String toAddress) =>
      throw UnimplementedError();

  @override
  Future<WithdrawalStatus?> getWithdrawStatus() async => null;
}

const _balance = WalletBalance(
  address: '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
  network: 'polygon-amoy',
  balanceCtc: '200',
  balanceWei: '200000000000000000000',
  solesRef: '2.00',
  linkedWallet: null,
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
    test('Paso 1-3: expone el balance del backend sin alterarlo ni redondearlo', () async {
      api.balance = _balance;

      final snapshot = await repository.getWallet();

      expect(snapshot.fromCache, isFalse, reason: 'el saldo debe venir de la red');
      expect(snapshot.balance.balanceWei, '200000000000000000000');
      expect(snapshot.balance.balanceCtc, '200');
      expect(snapshot.balance.address, _balance.address);
      expect(snapshot.balance.network, 'polygon-amoy');
    });

    test('cada consulta exitosa refresca el saldo cacheado', () async {
      api.balance = _balance;
      await repository.getWallet();

      expect(store.writes, 1);
      expect(await repository.cachedWallet(), isNotNull);
      expect((await repository.cachedWallet())!.balanceWei, _balance.balanceWei);
    });
  });

  group('CP019 - Paso 4: modo offline', () {
    test('sin conexión devuelve el último saldo conocido marcado como cacheado', () async {
      // Primero una consulta exitosa que deja el saldo en caché.
      api.balance = _balance;
      await repository.getWallet();

      // Ahora se cae la conectividad del dispositivo.
      api.error = _networkError;
      final snapshot = await repository.getWallet();

      expect(snapshot.fromCache, isTrue,
          reason: 'la pantalla debe poder mostrar el indicador de modo offline');
      expect(snapshot.balance.balanceWei, _balance.balanceWei,
          reason: 'debe mostrarse el último saldo conocido');
    });

    test('sin conexión y sin caché previo, el error se propaga', () async {
      api.error = _networkError;

      expect(() => repository.getWallet(), throwsA(isA<ApiException>()));
    });

    test('un error del backend NO se disimula con el saldo cacheado', () async {
      api.balance = _balance;
      await repository.getWallet();

      // 500 del servidor: mostrar un saldo viejo ocultaría el fallo real.
      api.error = const ApiException(
        message: 'Error interno',
        statusCode: 500,
        type: ApiErrorType.serverError,
      );

      expect(() => repository.getWallet(), throwsA(isA<ApiException>()));
    });

    test('al cerrar sesión el saldo cacheado se descarta', () async {
      api.balance = _balance;
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
