import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/features/sessions/data/models/recycling_session.dart';
import 'package:sidru_mobile/features/sessions/data/models/smart_bin.dart';
import 'package:sidru_mobile/features/sessions/data/session_repository.dart';
import 'package:sidru_mobile/features/sessions/presentation/session_provider.dart';
import 'package:sidru_mobile/features/sessions/utils/qr_token_parser.dart';

/// CP012 — Rechazo de código QR con formato inválido (US-19, esc. 2).
///
/// El caso se ejecuta a mano sobre el dispositivo (paso 1: capturar con la cámara un QR
/// ajeno al sistema), pero su condición verificable —"no se realizó ninguna llamada al
/// backend"— sí se automatiza: se espía el repositorio y se comprueba que el controlador
/// de escaneo descarta el contenido localmente, antes de tocar la red.

/// Repositorio espía: registra cualquier llamada que reciba.
class SpySessionRepository implements SessionRepository {
  final List<String> qrLookups = [];
  final List<String> confirmations = [];

  @override
  Future<RecyclingSession> getSessionByQr(String qrToken) async {
    qrLookups.add(qrToken);
    throw StateError('el backend no debería consultarse para un QR inválido');
  }

  @override
  Future<RecyclingSession> confirmSessionByQr(String qrToken) async {
    confirmations.add(qrToken);
    throw StateError('el backend no debería consultarse para un QR inválido');
  }

  @override
  Future<List<RecyclingSession>> getMySessions() async => const [];

  @override
  Future<RecyclingSession> getSessionById(int id) => throw UnimplementedError();

  @override
  Future<SmartBin> getSmartBin(int id) => throw UnimplementedError();
}

void main() {
  late SpySessionRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = SpySessionRepository();
    container = ProviderContainer(
      overrides: [sessionRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  group('CP012 - Paso 1-2: el contenido ajeno se descarta localmente', () {
    /// Contenidos típicos de un QR que no pertenece a SIDRU.
    const ajenos = <String>[
      'https://www.google.com',
      'WIFI:S:MiRed;T:WPA;P:clave123;;',
      'BEGIN:VCARD\nFN:Juan Perez\nEND:VCARD',
      'texto con espacios',
      '',
      '   ',
    ];

    for (final contenido in ajenos) {
      test('rechaza "${contenido.replaceAll('\n', ' ')}"', () async {
        final outcome = await container
            .read(sessionScanControllerProvider)
            .getSessionByQr(contenido);

        expect(outcome, isA<QrLookupFailure>());
        expect(
          (outcome as QrLookupFailure).type,
          ScanErrorType.invalid,
          reason: 'la pantalla debe mostrar "Código no reconocido"',
        );
      });
    }
  });

  test('CP012 - Paso 3: no se realiza ninguna llamada al backend', () async {
    final controller = container.read(sessionScanControllerProvider);

    await controller.getSessionByQr('https://www.google.com');
    await controller.getSessionByQr('WIFI:S:MiRed;T:WPA;P:clave123;;');
    await controller.getSessionByQr('');

    expect(repository.qrLookups, isEmpty,
        reason: 'un QR no reconocido no debe generar tráfico de red');
    expect(repository.confirmations, isEmpty);
  });

  test('Contraste: un QR de SIDRU sí llega al backend', () async {
    // El mismo controlador, con un contenido válido, sí consulta la sesión.
    await container
        .read(sessionScanControllerProvider)
        .getSessionByQr('sidru://session?qrToken=QR-SESION-DEMO');

    expect(repository.qrLookups, ['QR-SESION-DEMO'],
        reason: 'el token debe extraerse del deep link y consultarse una sola vez');
  });

  group('CP012 - el parser acepta solo los formatos del sistema', () {
    test('acepta los formatos soportados por SIDRU', () {
      expect(QrTokenParser.parse('QR-SESION-DEMO'), 'QR-SESION-DEMO');
      expect(QrTokenParser.parse('sidru://session?qrToken=abc123'), 'abc123');
      expect(QrTokenParser.parse('https://sidru.app/session/abc123'), 'abc123');
    });

    test('rechaza cualquier otro contenido', () {
      expect(QrTokenParser.parse('https://www.google.com'), isNull);
      expect(QrTokenParser.parse('texto con espacios'), isNull);
      expect(QrTokenParser.parse(null), isNull);
    });
  });
}
