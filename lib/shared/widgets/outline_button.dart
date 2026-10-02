import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Botón secundario (superficie + borde) de 52 px a todo el ancho. Lo usan "Iniciar sesión" y
/// "Continuar con Google" para ser idénticos; [leading] es un icono opcional antes del texto.
class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? leading;

  /// Colores propios (botón de Google, tema claro oficial). Si son null, el estilo oscuro de la app.
  final Color? background;
  final Color? borderColor;
  final Color? textColor;

  /// Gris sutil en hover/pressed.
  final Color? pressedColor;
  const OutlineButton({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
    this.background,
    this.borderColor,
    this.textColor,
    this.pressedColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background ?? AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(color: borderColor ?? AppColors.borderMedium),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            hoverColor: pressedColor,
            highlightColor: pressedColor,
            splashColor: pressedColor,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 10)],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
