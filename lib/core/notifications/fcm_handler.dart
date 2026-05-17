import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

/// Provider del manejador FCM. En `main.dart` se sobrescribe con la instancia ya
/// inicializada antes de `runApp`, para que toda la app comparta el mismo handler.
final fcmHandlerProvider = Provider<FcmHandler>((ref) => FcmHandler());

/// Handler de mensajes en background/terminated. Debe ser una función top-level
/// anotada con `@pragma('vm:entry-point')` (se ejecuta en un isolate separado).
/// El sistema ya muestra la `notification` (título/cuerpo) en la bandeja; aquí solo
/// se podría procesar el payload `data`. No necesita contexto de UI.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] background message: ${message.messageId}');
}

/// Manejador de Firebase Cloud Messaging (C4: FcmHandler → Firebase Cloud Messaging).
///
/// Integración real y **best-effort**: si Firebase no está configurado en la plataforma
/// (falta `google-services.json` / `GoogleService-Info.plist`), `initialize()` falla en
/// silencio y el resto de métodos son no-op, por lo que la app arranca y funciona igual.
/// Cuando se sueltan los archivos de configuración (ver `docs/FIREBASE_SETUP.md`), el
/// push se activa sin cambiar el código.
///
/// Modelo de entrega por **topic**: cada ciudadano autenticado se suscribe a
/// `user-{userId}`; el backend publica en ese topic (no se registran device tokens).
class FcmHandler {
  FcmHandler();

  bool _available = false;
  String? _subscribedTopic;

  /// true solo si Firebase se inicializó correctamente en esta plataforma.
  bool get isAvailable => _available;

  /// Inicializa FCM: Firebase, handler de background, permisos y listeners. Nunca lanza.
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      // iOS: mostrar la notificación también con la app en foreground.
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      _available = true;
      debugPrint('[FCM] inicializado');
    } catch (e) {
      _available = false;
      debugPrint('[FCM] no disponible (Firebase sin configurar): $e');
    }
  }

  /// Suscribe al ciudadano al topic `user-{userId}`. Reemplaza una suscripción previa.
  /// No-op si FCM no está disponible. Nunca lanza.
  Future<void> subscribeToUser(int userId) async {
    if (!_available) return;
    final topic = 'user-$userId';
    if (_subscribedTopic == topic) return;
    try {
      await unsubscribeCurrent();
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      _subscribedTopic = topic;
      debugPrint('[FCM] suscrito a $topic');
    } catch (e) {
      debugPrint('[FCM] error suscribiendo a $topic: $e');
    }
  }

  /// Desuscribe del topic actual (al cerrar sesión). No-op si no hay suscripción.
  Future<void> unsubscribeCurrent() async {
    if (!_available) return;
    final topic = _subscribedTopic;
    if (topic == null) return;
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('[FCM] desuscrito de $topic');
    } catch (e) {
      debugPrint('[FCM] error desuscribiendo de $topic: $e');
    } finally {
      _subscribedTopic = null;
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      debugPrint('[FCM] foreground: ${notification.title} — ${notification.body}');
    }
    // Opcional (futuro): mostrar un banner con flutter_local_notifications.
  }

  void _onMessageOpened(RemoteMessage message) {
    debugPrint('[FCM] abierto desde notificación: ${message.messageId}');
    // Opcional (futuro): deep-link a la WalletScreen.
  }
}
