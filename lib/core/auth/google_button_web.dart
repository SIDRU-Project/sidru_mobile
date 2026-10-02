import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

/// Botón OFICIAL de Google Identity Services. En web el SDK solo permite iniciar sesión
/// con su propia UI; el resultado llega por `authenticationEvents`, no por [onPressed].
Widget buildGoogleButton({required VoidCallback onPressed}) {
  return SizedBox(
    height: 48,
    child: Center(
      child: web.renderButton(
        configuration: web.GSIButtonConfiguration(
          type: web.GSIButtonType.standard,
          theme: web.GSIButtonTheme.outline,
          size: web.GSIButtonSize.large,
          text: web.GSIButtonText.continueWith,
          shape: web.GSIButtonShape.pill,
          minimumWidth: 280,
        ),
      ),
    ),
  );
}
