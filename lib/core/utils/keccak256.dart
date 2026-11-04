import 'dart:convert';
import 'dart:typed_data';

/// Keccak-256 (el original de Ethereum, **no** SHA3-256).
///
/// Se implementa aquí en Dart puro en vez de añadir una librería de criptografía: el
/// algoritmo es autocontenido y lo único que necesita la app es calcular el checksum
/// EIP-55 de una dirección EVM. El paquete `crypto` de Dart no sirve —ofrece SHA-2, y
/// SHA3-256 tampoco valdría porque usa un padding distinto (0x06) al de Keccak (0x01)—.
///
/// La aritmética de 64 bits se hace con pares de enteros de 32 bits (alto/bajo) a
/// propósito: en la VM nativa `int` es de 64 bits, pero al compilar a web los enteros son
/// de 53 bits y las operaciones bit a bit trabajan en 32. Con pares de 32 bits el
/// resultado es idéntico en las dos plataformas.
///
/// Verificado contra los vectores oficiales de Keccak-256 en
/// `test/cp/keccak256_test.dart`.
class Keccak256 {
  Keccak256._();

  /// Tamaño del bloque absorbido, en bytes (rate = 1088 bits).
  static const int _rateBytes = 136;

  /// Longitud del resumen, en bytes.
  static const int _digestBytes = 32;

  static const int _rounds = 24;

  /// Desplazamientos de la etapa rho, por índice de lane (x + 5y).
  static const List<int> _rho = [
    0, 1, 62, 28, 27, //
    36, 44, 6, 55, 20,
    3, 10, 43, 25, 39,
    41, 45, 15, 21, 8,
    18, 2, 61, 56, 14,
  ];

  /// Destino de cada lane en la etapa pi: (x, y) -> (y, 2x + 3y).
  static const List<int> _pi = [
    0, 10, 20, 5, 15, //
    16, 1, 11, 21, 6,
    7, 17, 2, 12, 22,
    23, 8, 18, 3, 13,
    14, 24, 9, 19, 4,
  ];

  /// Constantes de ronda (iota), partidas en mitad alta y mitad baja.
  static const List<int> _rcHi = [
    0x00000000, 0x00000000, 0x80000000, 0x80000000, //
    0x00000000, 0x00000000, 0x80000000, 0x80000000,
    0x00000000, 0x00000000, 0x00000000, 0x00000000,
    0x00000000, 0x80000000, 0x80000000, 0x80000000,
    0x80000000, 0x80000000, 0x00000000, 0x80000000,
    0x80000000, 0x80000000, 0x00000000, 0x80000000,
  ];

  static const List<int> _rcLo = [
    0x00000001, 0x00008082, 0x0000808A, 0x80008000, //
    0x0000808B, 0x80000001, 0x80008081, 0x00008009,
    0x0000008A, 0x00000088, 0x80008009, 0x8000000A,
    0x8000808B, 0x0000008B, 0x00008089, 0x00008003,
    0x00008002, 0x00000080, 0x0000800A, 0x8000000A,
    0x80008081, 0x00008080, 0x80000001, 0x80008008,
  ];

  /// Resumen Keccak-256 de [input].
  static Uint8List digest(Uint8List input) {
    final stateHi = Uint32List(25);
    final stateLo = Uint32List(25);

    // Padding pad10*1 con el byte de dominio 0x01 propio de Keccak.
    final padded = _pad(input);

    // Absorción: un bloque de rate bytes a la vez.
    for (var offset = 0; offset < padded.length; offset += _rateBytes) {
      for (var lane = 0; lane < _rateBytes ~/ 8; lane++) {
        final base = offset + lane * 8;
        stateLo[lane] ^= _readLe32(padded, base);
        stateHi[lane] ^= _readLe32(padded, base + 4);
      }
      _permute(stateHi, stateLo);
    }

    // Exprimido: con rate=136 y salida de 32 bytes basta el primer bloque.
    final out = Uint8List(_digestBytes);
    for (var lane = 0; lane < _digestBytes ~/ 8; lane++) {
      _writeLe32(out, lane * 8, stateLo[lane]);
      _writeLe32(out, lane * 8 + 4, stateHi[lane]);
    }
    return out;
  }

  /// Resumen de [input] en hexadecimal minúscula, sin prefijo `0x`.
  static String hexOfString(String input) {
    final bytes = digest(Uint8List.fromList(utf8.encode(input)));
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static Uint8List _pad(Uint8List input) {
    final padLength = _rateBytes - (input.length % _rateBytes);
    final padded = Uint8List(input.length + padLength)..setAll(0, input);
    padded[input.length] = 0x01;
    padded[padded.length - 1] |= 0x80;
    return padded;
  }

  static int _readLe32(Uint8List data, int offset) {
    return (data[offset] |
            (data[offset + 1] << 8) |
            (data[offset + 2] << 16) |
            (data[offset + 3] << 24)) &
        0xFFFFFFFF;
  }

  static void _writeLe32(Uint8List out, int offset, int value) {
    out[offset] = value & 0xFF;
    out[offset + 1] = (value >> 8) & 0xFF;
    out[offset + 2] = (value >> 16) & 0xFF;
    out[offset + 3] = (value >> 24) & 0xFF;
  }

  /// Permutación Keccak-f[1600] sobre el estado, in place.
  static void _permute(Uint32List aHi, Uint32List aLo) {
    final cHi = Uint32List(5);
    final cLo = Uint32List(5);
    final bHi = Uint32List(25);
    final bLo = Uint32List(25);

    for (var round = 0; round < _rounds; round++) {
      // theta
      for (var x = 0; x < 5; x++) {
        cHi[x] = aHi[x] ^ aHi[x + 5] ^ aHi[x + 10] ^ aHi[x + 15] ^ aHi[x + 20];
        cLo[x] = aLo[x] ^ aLo[x + 5] ^ aLo[x + 10] ^ aLo[x + 15] ^ aLo[x + 20];
      }
      for (var x = 0; x < 5; x++) {
        final nextHi = cHi[(x + 1) % 5];
        final nextLo = cLo[(x + 1) % 5];
        // rot(C[x+1], 1)
        final rotHi = ((nextHi << 1) | (nextLo >> 31)) & 0xFFFFFFFF;
        final rotLo = ((nextLo << 1) | (nextHi >> 31)) & 0xFFFFFFFF;

        final dHi = cHi[(x + 4) % 5] ^ rotHi;
        final dLo = cLo[(x + 4) % 5] ^ rotLo;

        for (var y = 0; y < 25; y += 5) {
          aHi[x + y] ^= dHi;
          aLo[x + y] ^= dLo;
        }
      }

      // rho + pi
      for (var i = 0; i < 25; i++) {
        final n = _rho[i];
        final hi = aHi[i];
        final lo = aLo[i];
        final target = _pi[i];

        if (n == 0) {
          bHi[target] = hi;
          bLo[target] = lo;
        } else if (n == 32) {
          bHi[target] = lo;
          bLo[target] = hi;
        } else if (n < 32) {
          bHi[target] = ((hi << n) | (lo >> (32 - n))) & 0xFFFFFFFF;
          bLo[target] = ((lo << n) | (hi >> (32 - n))) & 0xFFFFFFFF;
        } else {
          final m = n - 32;
          bHi[target] = ((lo << m) | (hi >> (32 - m))) & 0xFFFFFFFF;
          bLo[target] = ((hi << m) | (lo >> (32 - m))) & 0xFFFFFFFF;
        }
      }

      // chi
      for (var y = 0; y < 25; y += 5) {
        for (var x = 0; x < 5; x++) {
          final i = x + y;
          aHi[i] = bHi[i] ^ ((~bHi[(x + 1) % 5 + y] & 0xFFFFFFFF) & bHi[(x + 2) % 5 + y]);
          aLo[i] = bLo[i] ^ ((~bLo[(x + 1) % 5 + y] & 0xFFFFFFFF) & bLo[(x + 2) % 5 + y]);
        }
      }

      // iota
      aHi[0] ^= _rcHi[round];
      aLo[0] ^= _rcLo[round];
    }
  }
}
