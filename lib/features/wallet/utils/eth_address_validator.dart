/// Validación client-side de direcciones EVM para el flujo de retiro.
///
/// Alcance: validación de FORMATO (`^0x[0-9a-fA-F]{40}$`). Si no cumple, la app
/// rechaza el retiro inline y NO llama al backend (ERR-BC-04, RN-BC-06).
///
/// Checksum EIP-55 completo: requiere keccak-256, que NO está disponible en las
/// dependencias actuales de la app (`crypto` solo provee SHA). Añadir keccak
/// implicaría una dependencia pesada, por lo que se omite el checksum en cliente
/// y el backend queda como autoridad del checksum EIP-55 (revalida y responde
/// 400 si la dirección es inválida). Ver design.md §5.3.
class EthAddressValidator {
  EthAddressValidator._();

  static final RegExp _format = RegExp(r'^0x[0-9a-fA-F]{40}$');

  /// `true` si la dirección cumple el formato EVM básico.
  static bool isValidFormat(String address) => _format.hasMatch(address.trim());

  /// Devuelve un mensaje de error inline si la dirección es inválida,
  /// o `null` si el formato es correcto.
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
    return null;
  }
}
