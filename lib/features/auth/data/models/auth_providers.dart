/// Respuesta de GET /authentication/providers.
/// `google` es null si el backend no tiene Google habilitado (sin client ID).
/// Clase simple (sin freezed): solo se lee, nunca se serializa.
class AuthProviders {
  final bool password;
  final String? googleClientId;

  const AuthProviders({this.password = true, this.googleClientId});

  /// Respaldo cuando el endpoint falla: solo correo y contraseña.
  static const passwordOnly = AuthProviders();

  bool get hasGoogle => googleClientId != null && googleClientId!.isNotEmpty;

  factory AuthProviders.fromJson(Map<String, dynamic> json) {
    final google = json['google'];
    return AuthProviders(
      password: json['password'] as bool? ?? true,
      googleClientId: google is Map ? google['clientId'] as String? : null,
    );
  }
}
