import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/features/sessions/utils/qr_token_parser.dart';

/// Parseo del token del QR en sus formatos soportados (US-19/US-33).
void main() {
  const token = 'QR-SESION-DEMO';

  test('acepta el token crudo', () {
    expect(QrTokenParser.parse(token), token);
  });

  test('extrae el token de un deep link sidru://', () {
    expect(QrTokenParser.parse('sidru://session?qrToken=$token'), token);
  });

  test('extrae el token de una URL con segmento /session/', () {
    expect(QrTokenParser.parse('https://sidru.app/session/$token'), token);
  });

  test('extrae el token de una URL con query qrToken', () {
    expect(QrTokenParser.parse('https://sidru.app/session?qrToken=$token'), token);
  });

  test('devuelve null para vacío o null', () {
    expect(QrTokenParser.parse(''), isNull);
    expect(QrTokenParser.parse(null), isNull);
  });

  test('devuelve null para un valor con espacios', () {
    expect(QrTokenParser.parse('token con espacios'), isNull);
  });

  test('devuelve null para una URL sin token ni segmento session', () {
    expect(QrTokenParser.parse('https://otra.com/foo/bar'), isNull);
  });
}
