import 'browser_session.dart';

/// Sesión inerte para plataformas sin navegador (Android/iOS, tests de VM). El login por redirección
/// solo existe en web: aquí navegar es un error de programación.
BrowserSession createBrowserSession() => _InertBrowserSession();

class _InertBrowserSession implements BrowserSession {
  final Map<String, String> _storage = {};

  @override
  String? getItem(String key) => _storage[key];

  @override
  void setItem(String key, String value) => _storage[key] = value;

  @override
  void removeItem(String key) => _storage.remove(key);

  @override
  String get origin => 'http://localhost';

  @override
  String get initialFragment => '';

  @override
  void clearUrlFragment() {}

  @override
  void navigate(String url) =>
      throw UnsupportedError('La navegación solo existe en web.');
}
