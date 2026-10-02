import 'package:flutter/material.dart';

/// Botón de Google en plataformas sin el SDK web (Android/iOS, tests):
/// un botón propio que dispara [onPressed] (el flujo nativo de google_sign_in).
Widget buildGoogleButton({required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Text(
        'G',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      label: const Text('Continuar con Google'),
    ),
  );
}
