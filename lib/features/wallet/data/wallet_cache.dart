import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'models/wallet_summary.dart';

/// Almacén de una sola clave para el caché de la wallet.
///
/// Se abstrae para que el caché sea probable sin depender del almacenamiento del
/// dispositivo: en pruebas se inyecta una implementación en memoria.
abstract class WalletCacheStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

/// Implementación sobre `flutter_secure_storage`, el mismo almacén cifrado donde vive
/// el JWT. El saldo no es una credencial, pero sí es un dato personal del ciudadano.
class SecureWalletCacheStore implements WalletCacheStore {
  static const _key = 'wallet_last_snapshot';

  final FlutterSecureStorage _storage;

  SecureWalletCacheStore()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// Último saldo conocido de la wallet, para poder mostrar algo cuando no hay conexión
/// (CP019, paso 4 / US-25).
///
/// Es deliberadamente tolerante a fallos: si el almacén falla o el contenido quedó
/// corrupto tras un cambio de formato, se comporta como si no hubiera caché. Nunca debe
/// tumbar la pantalla de la wallet por un problema de caché.
class WalletCache {
  final WalletCacheStore _store;

  WalletCache(this._store);

  Future<void> save(WalletSummary summary) async {
    try {
      await _store.write(jsonEncode(summary.toJson()));
    } catch (_) {
      // El caché es un extra: si no se puede guardar, la app sigue funcionando.
    }
  }

  Future<WalletSummary?> read() async {
    try {
      final raw = await _store.read();
      if (raw == null || raw.isEmpty) return null;
      return WalletSummary.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Se invoca al cerrar sesión: el saldo del ciudadano anterior no debe sobrevivir.
  Future<void> clear() async {
    try {
      await _store.clear();
    } catch (_) {
      // idem: limpiar el caché nunca debe propagar un error.
    }
  }
}
