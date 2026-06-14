/// Utilidades de formato para la WalletScreen (direcciones y hashes).
class WalletFormatters {
  WalletFormatters._();

  /// Trunca una dirección/hash al estilo `0x1234…abcd`.
  /// Devuelve el valor original si es demasiado corto para truncar.
  static String truncate(String value, {int head = 6, int tail = 4}) {
    final v = value.trim();
    if (v.length <= head + tail + 1) return v;
    return '${v.substring(0, head)}…${v.substring(v.length - tail)}';
  }
}
