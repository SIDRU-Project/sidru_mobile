import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/features/wallet/utils/eth_address_validator.dart';

/// CP021 — Rechazo de retiro con dirección inválida (US-38, esc. 2).
/// CP032 — Actualización de la dirección de wallet externa (US-29, esc. 1, paso 4).
///
/// Lado app: la validación inline evita que una dirección mal escrita llegue siquiera a
/// salir del dispositivo, tanto por formato como por checksum EIP-55. El backend
/// revalida y responde 400 (`ERR_BC_004`) — eso se verifica en el CP021 del backend.
void main() {
  // Direcciones de la propia especificación EIP-55.
  const validaEip55 = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';
  const otraValidaEip55 = '0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359';
  const todoMayusculas = '0x52908400098527886E0F7030069857D2E4169EE7';
  const todoMinusculas = '0xde709f2102306220921060314715629080e2fb77';

  group('CP032 - Paso 4: una dirección EIP-55 válida se acepta', () {
    test('acepta la dirección canónica con checksum correcto', () {
      expect(EthAddressValidator.isValidFormat(validaEip55), isTrue);
      expect(EthAddressValidator.hasValidChecksum(validaEip55), isTrue);
      expect(EthAddressValidator.validate(validaEip55), isNull);
    });

    test('acepta otras direcciones de la especificación EIP-55', () {
      for (final address in [otraValidaEip55, todoMayusculas, todoMinusculas]) {
        expect(
          EthAddressValidator.validate(address),
          isNull,
          reason: '$address debería aceptarse',
        );
      }
    });

    test('acepta la misma dirección en minúsculas y con espacios alrededor', () {
      // Sin mezcla de mayúsculas no hay checksum verificable: es válida como tal.
      expect(EthAddressValidator.validate('  ${validaEip55.toLowerCase()}  '), isNull);
    });

    test('normaliza a la forma canónica EIP-55', () {
      expect(
        EthAddressValidator.toChecksumAddress(validaEip55.toLowerCase()),
        validaEip55,
      );
      expect(
        EthAddressValidator.toChecksumAddress(otraValidaEip55.toLowerCase()),
        otraValidaEip55,
      );
    });
  });

  group('CP021 - Pasos 1-3: las direcciones inválidas no salen del dispositivo', () {
    test('rechaza el checksum EIP-55 incorrecto, con mensaje explícito', () {
      // Misma dirección con un solo carácter cambiado de caja: el formato sigue siendo
      // correcto, pero el checksum ya no cuadra. Es el error típico al copiar a mano.
      const checksumAlterado = '0x5aAeb6053f3E94C9b9A09f33669435E7Ef1BeAed';

      expect(EthAddressValidator.isValidFormat(checksumAlterado), isTrue,
          reason: 'el formato es válido: lo que falla es el checksum');
      expect(EthAddressValidator.hasValidChecksum(checksumAlterado), isFalse);

      final error = EthAddressValidator.validate(checksumAlterado);
      expect(error, isNotNull);
      expect(error, contains('checksum'));
    });

    test('rechaza el checksum incorrecto en las otras direcciones de referencia', () {
      // Se invierte la caja del primer carácter alfabético de cada dirección canónica.
      for (final valida in [validaEip55, otraValidaEip55]) {
        final alterada = _invertirPrimeraLetra(valida);
        expect(
          EthAddressValidator.validate(alterada),
          isNotNull,
          reason: '$alterada tiene el checksum roto y debería rechazarse',
        );
      }
    });

    test('exige el prefijo 0x, con mensaje explícito', () {
      final error = EthAddressValidator.validate(
        '5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
      );
      expect(error, isNotNull);
      expect(error, contains('0x'));
    });

    test('rechaza una longitud incorrecta', () {
      expect(EthAddressValidator.validate('0x123'), isNotNull);
      expect(EthAddressValidator.validate('${validaEip55}00'), isNotNull);
    });

    test('rechaza caracteres no hexadecimales', () {
      expect(
        EthAddressValidator.validate('0xZZAeb6053F3E94C9b9A09f33669435E7Ef1BeAed'),
        isNotNull,
      );
    });

    test('pide la dirección cuando el campo está vacío', () {
      expect(EthAddressValidator.validate(''), isNotNull);
      expect(EthAddressValidator.validate(null), isNotNull);
    });
  });

  test('la app y el backend aplican la misma regla de checksum', () {
    // El backend (EvmAddress.isValid) acepta minúsculas/mayúsculas puras y exige EIP-55
    // solo en las mixtas. La app debe coincidir, o rechazaría direcciones que el backend
    // acepta (o al revés).
    expect(EthAddressValidator.isValid(todoMinusculas), isTrue);
    expect(EthAddressValidator.isValid(todoMayusculas), isTrue);
    expect(EthAddressValidator.isValid(validaEip55), isTrue);
    expect(EthAddressValidator.isValid('0x5aAeb6053f3E94C9b9A09f33669435E7Ef1BeAed'), isFalse);
  });
}

/// Invierte la caja de la primera letra a-f/A-F del cuerpo de la dirección, rompiendo
/// su checksum sin tocar el formato.
String _invertirPrimeraLetra(String address) {
  final body = address.substring(2).split('');
  for (var i = 0; i < body.length; i++) {
    final c = body[i];
    final lower = c.toLowerCase();
    if (lower.compareTo('a') >= 0 && lower.compareTo('f') <= 0) {
      body[i] = c == lower ? c.toUpperCase() : lower;
      break;
    }
  }
  return '0x${body.join()}';
}
