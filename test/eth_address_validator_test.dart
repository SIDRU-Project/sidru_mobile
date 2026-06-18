import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/features/wallet/utils/eth_address_validator.dart';

/// Validación de direcciones EVM del flujo de retiro (US-38/US-33).
void main() {
  // Dirección EIP-55 válida canónica (ejemplo de la especificación).
  const valid = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';

  group('EthAddressValidator.isValidFormat', () {
    test('acepta una dirección 0x + 40 hex', () {
      expect(EthAddressValidator.isValidFormat(valid), isTrue);
    });

    test('tolera espacios alrededor', () {
      expect(EthAddressValidator.isValidFormat('  $valid  '), isTrue);
    });

    test('rechaza longitud incorrecta', () {
      expect(EthAddressValidator.isValidFormat('0x123'), isFalse);
    });

    test('rechaza caracteres no hex', () {
      expect(
        EthAddressValidator.isValidFormat(
          '0xZZAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
        ),
        isFalse,
      );
    });
  });

  group('EthAddressValidator.validate', () {
    test('devuelve null cuando es válida', () {
      expect(EthAddressValidator.validate(valid), isNull);
    });

    test('pide la dirección cuando está vacía', () {
      expect(EthAddressValidator.validate(''), contains('Ingresa'));
      expect(EthAddressValidator.validate(null), contains('Ingresa'));
    });

    test('exige el prefijo 0x', () {
      final msg = EthAddressValidator.validate(
        '5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
      );
      expect(msg, contains('0x'));
    });

    test('rechaza formato inválido con mensaje', () {
      expect(EthAddressValidator.validate('0x123'), contains('inválida'));
    });
  });
}
