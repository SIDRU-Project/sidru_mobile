/// Extrae el qrToken real desde los formatos soportados por SIDRU.
///
/// Formatos aceptados:
/// - QR-SESION-DEMO
/// - sidru://session?qrToken=QR-SESION-DEMO
/// - https://sidru.app/session/QR-SESION-DEMO
/// - https://sidru.app/session?qrToken=QR-SESION-DEMO
class QrTokenParser {
  const QrTokenParser._();

  static String? parse(String? rawValue) {
    final value = rawValue?.trim();
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      final tokenFromQuery = _cleanToken(_queryValue(uri, 'qrToken'));
      if (tokenFromQuery != null) return tokenFromQuery;

      final segments =
          uri.pathSegments.where((s) => s.trim().isNotEmpty).toList();
      final sessionIndex = segments.indexWhere(
        (s) => s.toLowerCase() == 'session',
      );
      if (sessionIndex >= 0 && sessionIndex + 1 < segments.length) {
        return _cleanToken(segments[sessionIndex + 1]);
      }

      return null;
    }

    if (_looksLikeRawToken(value)) return value;
    return null;
  }

  static bool _looksLikeRawToken(String value) {
    if (value.contains(RegExp(r'\s'))) return false;
    if (value.contains('/') || value.contains('?') || value.contains('&')) {
      return false;
    }
    return RegExp(r'^[A-Za-z0-9._:-]+$').hasMatch(value);
  }

  static String? _cleanToken(String? value) {
    final token = value?.trim();
    return token == null || token.isEmpty ? null : token;
  }

  static String? _queryValue(Uri uri, String key) {
    for (final entry in uri.queryParameters.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) return entry.value;
    }
    return null;
  }
}
