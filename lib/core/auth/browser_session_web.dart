import 'package:web/web.dart' as web;

import 'browser_session.dart';

BrowserSession createBrowserSession() => _WebBrowserSession();

class _WebBrowserSession implements BrowserSession {
  // Se captura al crear la sesión (en main, antes de runApp): el router de Flutter puede reescribir la
  // URL al arrancar y el id_token viaja en el fragmento.
  final String _initialFragment = _readFragment();

  static String _readFragment() {
    final hash = web.window.location.hash;
    return hash.startsWith('#') ? hash.substring(1) : hash;
  }

  @override
  String? getItem(String key) => web.window.sessionStorage.getItem(key);

  @override
  void setItem(String key, String value) =>
      web.window.sessionStorage.setItem(key, value);

  @override
  void removeItem(String key) => web.window.sessionStorage.removeItem(key);

  @override
  String get origin => web.window.location.origin;

  @override
  String get initialFragment => _initialFragment;

  @override
  void clearUrlFragment() {
    final location = web.window.location;
    web.window.history.replaceState(
      null,
      '',
      '${location.pathname}${location.search}',
    );
  }

  @override
  void navigate(String url) => web.window.location.assign(url);
}
