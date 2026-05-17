import 'package:intl/intl.dart';

class DateFormatter {
  static final _full = DateFormat('dd MMM yyyy · HH:mm', 'es');
  static final _short = DateFormat('dd MMM yyyy', 'es');
  static final _time = DateFormat('HH:mm', 'es');

  /// "31 may 2026 · 18:20"
  static String full(String? isoString) {
    final dt = _parse(isoString);
    return dt != null ? _full.format(dt) : '—';
  }

  /// "31 may 2026"
  static String short(String? isoString) {
    final dt = _parse(isoString);
    return dt != null ? _short.format(dt) : '—';
  }

  /// "18:20"
  static String time(String? isoString) {
    final dt = _parse(isoString);
    return dt != null ? _time.format(dt) : '—';
  }

  /// Devuelve etiqueta relativa simple: "Hoy", "Ayer" o la fecha corta.
  static String relative(String? isoString) {
    final dt = _parse(isoString);
    if (dt == null) return '—';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Hoy · ${_time.format(dt)}';
    if (d == today.subtract(const Duration(days: 1))) {
      return 'Ayer · ${_time.format(dt)}';
    }
    return '${_short.format(dt)} · ${_time.format(dt)}';
  }

  static DateTime? _parse(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }
}
