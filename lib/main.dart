import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/notifications/fcm_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: '.env');

  // Inicializar datos de localización para formateo de fechas en español.
  // Sin esto, DateFormat(..., 'es') lanza LocaleDataException en runtime.
  await initializeDateFormatting('es', null);

  // FCM (best-effort): si Firebase no está configurado en la plataforma,
  // initialize() es un no-op y la app arranca igual (ver docs/FIREBASE_SETUP.md).
  // Se comparte la MISMA instancia con el resto de la app vía override del provider.
  final fcmHandler = FcmHandler();
  await fcmHandler.initialize();

  runApp(
    ProviderScope(
      overrides: [fcmHandlerProvider.overrideWithValue(fcmHandler)],
      child: const SidruApp(),
    ),
  );
}
