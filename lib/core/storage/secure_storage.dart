import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper de flutter_secure_storage para persistir el JWT.
/// Es la ÚNICA fuente válida del token en toda la app.
class SecureStorage {
  static const _tokenKey = 'jwt_token';

  final FlutterSecureStorage _storage;

  SecureStorage()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<bool> hasToken() async => (await getToken()) != null;
}
