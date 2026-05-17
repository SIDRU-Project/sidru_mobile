class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu correo.';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(value.trim())) return 'Correo no válido.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
    if (value.length < 6) return 'Mínimo 6 caracteres.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña.';
    if (value != original) return 'Las contraseñas no coinciden.';
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido.';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu teléfono.';
    final re = RegExp(r'^\d{7,15}$');
    if (!re.hasMatch(value.trim())) {
      return 'Solo dígitos, entre 7 y 15 caracteres.';
    }
    return null;
  }
}
