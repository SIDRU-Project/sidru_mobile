import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

/// Botón OFICIAL de Google Identity Services. En web el SDK solo permite iniciar sesión
/// con su propia UI; el resultado llega por `authenticationEvents`, no por [onPressed].
/// Toma el ancho disponible (como los CTAs de arriba); GIS acepta entre 200 y 400 px.
Widget buildGoogleButton({required VoidCallback onPressed}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width =
          constraints.maxWidth.isFinite
              ? constraints.maxWidth.clamp(200.0, 400.0)
              : 280.0;
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
              minimumWidth: width,
            ),
          ),
        ),
      );
    },
  );
}
