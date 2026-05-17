class WeightFormatter {
  /// Convierte peso de backend a kilogramos.
  ///
  /// La API histórica documentaba `weightGrams` como gramos, por ejemplo 840.0.
  /// El backend actual devuelve valores pequeños como 0.1, que representan kg.
  /// Para evitar mostrar "0.00 kg", valores menores a 10 se interpretan como kg.
  static double backendWeightToKg(double weight) {
    if (weight.abs() < 10) return weight;
    return weight / 1000;
  }

  /// Convierte gramos a texto legible.
  static String fromGrams(double grams) {
    return '${backendWeightToKg(grams).toStringAsFixed(2)} kg';
  }

  /// Siempre en kg con 2 decimales: "0.84 kg"
  static String gramsToKg(double grams) =>
      '${backendWeightToKg(grams).toStringAsFixed(2)} kg';
}
