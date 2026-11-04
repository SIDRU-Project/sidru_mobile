class WeightFormatter {
  /// El backend SIEMPRE envía `weightGrams` en gramos (p. ej. 6.0, 48.5, 840.0,
  /// hasta 50000 = 50 kg). Muestra la unidad correcta: gramos por debajo de 1 kg
  /// y kilogramos a partir de 1 kg. Así una sesión de 6 g se ve "6 g", no "6.00 kg".
  static String fromGrams(double grams) {
    if (grams.abs() < 1000) {
      // "6 g" si es entero; "48.5 g" si tiene decimales.
      final isWhole = grams == grams.roundToDouble();
      return '${isWhole ? grams.toStringAsFixed(0) : grams.toStringAsFixed(1)} g';
    }
    return '${(grams / 1000).toStringAsFixed(2)} kg';
  }

  /// Alias de compatibilidad (lo usan las pantallas de sesiones). Ahora elige
  /// automáticamente g o kg en lugar de forzar siempre "kg".
  static String gramsToKg(double grams) => fromGrams(grams);
}
