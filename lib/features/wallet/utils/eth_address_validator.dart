import '../../../core/utils/keccak256.dart';

/// Validación client-side de direcciones EVM para el flujo de retiro.
///
/// Valida **formato** (`^0x[0-9a-fA-F]{40}$`) y **checksum EIP-55**. Si algo no cuadra,
/// la app rechaza el retiro inline y NO llama al backend (ERR-BC-04, RN-BC-06).
///
/// Regla de checksum, idéntica a la del backend (`EvmAddress.isValid`): una dirección
/// escrita toda en minúsculas o toda en mayúsculas no lleva checksum verificable y se
/// acepta; una con mayúsculas y minúsculas mezcladas sí lo lleva, y debe coincidir
/// exactamente con el resultado de EIP-55. Así una sola letra mal copiada de MetaMask se
/// detecta en el dispositivo, que es justo para lo que sirve el checksum.
///
/// El keccak-256 que exige EIP-55 está implementado en `core/utils/keccak256.dart`, en
/// Dart puro y sin dependencias nuevas. El backend sigue revalidando: el cliente es la
/// primera barrera, no la autoridad.
class EthAddressValidator {
  EthAddressValidator._();

  static final RegExp _format = RegExp(r'^0x[0-9a-fA-F]{40}$');

  /// `true` si la dirección cumple el formato EVM básico.
  static bool isValidFormat(String address) => _format.hasMatch(address.trim());

  /// `true` si la dirección es válida: formato correcto y, cuando lleva mayúsculas y
  /// minúsculas mezcladas, checksum EIP-55 correcto.
  static bool isValid(String? value) => validate(value) == null;

  /// `true` si la dirección lleva un checksum EIP-55 verificable y es correcto.
  ///
  /// Devuelve `false` tanto para una dirección con checksum equivocado como para una que
  /// no lo lleva (todo en minúsculas o todo en mayúsculas). Para decidir si aceptar una
  /// dirección se usa [validate], no este método.
  static bool hasValidChecksum(String address) {
    final trimmed = address.trim();
    if (!isValidFormat(trimmed)) return false;
    final body = trimmed.substring(2);
    if (!_isMixedCase(body)) return false;
    return toChecksumAddress(trimmed) == trimmed;
  }

  /// Reescribe la dirección con el patrón de mayúsculas de EIP-55.
  ///
  /// Es la forma canónica: la que conviene mostrar y la que devuelve el backend.
  static String toChecksumAddress(String address) {
    final lower = address.trim().substring(2).toLowerCase();
    final hash = Keccak256.hexOfString(lower);

    final buffer = StringBuffer('0x');
    for (var i = 0; i < lower.length; i++) {
      final char = lower[i];
      // Cada carácter se pone en mayúscula si el nibble correspondiente del hash es >= 8.
      final isLetter = char.compareTo('a') >= 0 && char.compareTo('f') <= 0;
      if (isLetter && int.parse(hash[i], radix: 16) >= 8) {
        buffer.write(char.toUpperCase());
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Devuelve un mensaje de error inline si la dirección es inválida,
  /// o `null` si puede enviarse al backend.
  static String? validate(String? value) {
    final address = (value ?? '').trim();
    if (address.isEmpty) {
      return 'Ingresa la dirección de tu wallet.';
    }
    if (!address.startsWith('0x')) {
      return 'La dirección debe empezar con 0x.';
    }
    if (!isValidFormat(address)) {
      return 'Dirección inválida. Debe ser 0x seguido de 40 caracteres hex.';
    }

    final body = address.substring(2);
    // Sin mezcla de mayúsculas y minúsculas no hay checksum que verificar: la dirección
    // es válida como tal (misma regla que aplica el backend).
    if (_isMixedCase(body) && toChecksumAddress(address) != address) {
      return 'Dirección inválida: el checksum no coincide. Revisa que la copiaste completa.';
    }
    return null;
  }

  static bool _isMixedCase(String body) {
    return body != body.toLowerCase() && body != body.toUpperCase();
  }
}
