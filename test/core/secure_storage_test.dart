import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/core/storage/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('clearSession() borra el JWT y los cachés por usuario (p. ej. wallet_last_snapshot)', () async {
    FlutterSecureStorage.setMockInitialValues({
      'jwt_token': 'x',
      'wallet_last_snapshot': '{}',
    });
    final storage = SecureStorage();

    await storage.clearSession();

    expect(await storage.getToken(), isNull);
    expect(await storage.hasToken(), isFalse);
    const rawStorage = FlutterSecureStorage();
    expect(await rawStorage.read(key: 'wallet_last_snapshot'), isNull);
  });
}
