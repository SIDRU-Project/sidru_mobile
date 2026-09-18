import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/core/utils/keccak256.dart';

/// Vectores conocidos de Keccak-256 (el original de Ethereum, no SHA3-256).
///
/// Si esta implementación se desviara del algoritmo, el checksum EIP-55 aceptaría
/// direcciones inválidas o rechazaría las buenas, así que se ancla a los vectores
/// oficiales antes de confiar en ella.
void main() {
  String hex(String input) => Keccak256.hexOfString(input);

  group('Keccak-256: vectores conocidos', () {
    test('cadena vacía', () {
      expect(
        hex(''),
        'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470',
      );
    });

    test('"abc"', () {
      expect(
        hex('abc'),
        '4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45',
      );
    });

    test('"testing"', () {
      expect(
        hex('testing'),
        '5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02',
      );
    });

    test('NO coincide con SHA3-256 (padding distinto)', () {
      // SHA3-256('') = a7ffc6f8bf1ed766...; Keccak-256('') = c5d2460186f7233c...
      expect(hex(''), isNot(startsWith('a7ffc6f8')));
    });
  });

  group('Keccak-256: entradas que cruzan el tamaño de bloque', () {
    // El rate es de 136 bytes: se prueban entradas por debajo, justo en el límite y
    // por encima, que es donde fallan las implementaciones con el padding mal hecho.
    test('135 bytes (un byte menos que el bloque)', () {
      final input = 'a' * 135;
      expect(hex(input), hasLength(64));
      expect(hex(input), isNot(hex('a' * 134)));
    });

    test('136 bytes (bloque exacto: fuerza un bloque de padding completo)', () {
      final input = 'a' * 136;
      expect(hex(input), hasLength(64));
      expect(hex(input), isNot(hex('a' * 135)));
    });

    test('137 bytes (dos bloques)', () {
      final input = 'a' * 137;
      expect(hex(input), hasLength(64));
      expect(hex(input), isNot(hex('a' * 136)));
    });

    test('entrada larga (1000 bytes)', () {
      expect(hex('sidru' * 200), hasLength(64));
    });
  });

  test('digest acepta bytes crudos y devuelve 32 bytes', () {
    final out = Keccak256.digest(Uint8List.fromList(utf8.encode('abc')));
    expect(out.length, 32);
    expect(out.first, 0x4e);
    expect(out.last, 0x45);
  });

  test('es determinista: la misma entrada da siempre el mismo resumen', () {
    expect(hex('SIDRU'), hex('SIDRU'));
  });
}
