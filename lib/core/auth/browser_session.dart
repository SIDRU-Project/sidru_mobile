import 'browser_session_stub.dart'
    if (dart.library.js_interop) 'browser_session_web.dart'
    as impl;

/// Lo mínimo del navegador que necesita el login con Google por redirección: sessionStorage,
/// la URL actual y la navegación. Es una interfaz para poder probar el flujo sin navegador y para que
/// el APK compile (el código real usa `package:web` y vive solo en `browser_session_web.dart`).
abstract class BrowserSession {
  String? getItem(String key);
  void setItem(String key, String value);
  void removeItem(String key);

  /// Origen de la web (p. ej. `https://sidru.adrianocruz.dev`).
  String get origin;

  /// Fragmento de la URL capturado al arrancar la app (sin `#`). Se captura al crear la sesión, antes
  /// de que el router de Flutter pueda reescribir la URL.
  String get initialFragment;

  /// Borra el `#…` de la barra de direcciones y del historial (`history.replaceState`).
  void clearUrlFragment();

  /// Navega a otra página (sale de la app).
  void navigate(String url);
}

/// Crea la sesión de navegador real (web) o una inerte (nativo y tests).
BrowserSession createBrowserSession() => impl.createBrowserSession();
