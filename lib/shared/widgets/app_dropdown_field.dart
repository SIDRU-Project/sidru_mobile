import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Selector desplegable INLINE alineado al diseño de [AppTextField].
///
/// Al tocar la caja, la lista se expande **ahí mismo** dentro del formulario
/// (no abre un menú overlay ni otra pantalla) y ocupa el ancho del campo, con
/// altura acotada y scroll. Integra validación de [Form] vía [FormField], así
/// que funciona dentro de un [Form] sin lógica extra.
class AppDropdownField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.hint,
    this.value,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  State<AppDropdownField> createState() => _AppDropdownFieldState();
}

class _AppDropdownFieldState extends State<AppDropdownField> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (field) {
        final selected = field.value;
        final hasError = field.hasError;
        final borderColor =
            hasError
                ? AppColors.error.withValues(alpha: 0.5)
                : (_open ? AppColors.primary : AppColors.borderSubtle);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: AppTextStyles.labelMono),
            const SizedBox(height: 7),

            // Caja (header)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus(); // cierra el teclado si está abierto
                setState(() => _open = !_open);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: borderColor,
                    width: (_open && !hasError) ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      IconTheme(
                        data: const IconThemeData(
                          color: AppColors.textTertiary,
                        ),
                        child: widget.prefixIcon!,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        selected ?? (widget.hint ?? 'Selecciona'),
                        style: TextStyle(
                          color:
                              selected == null
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textTertiary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista inline expandible (ahí mismo, no overlay)
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child:
                  _open
                      ? Container(
                        margin: const EdgeInsets.only(top: 6),
                        constraints: const BoxConstraints(maxHeight: 240),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Scrollbar(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: widget.items.length,
                            itemBuilder: (_, i) {
                              final item = widget.items[i];
                              final isSelected = item == selected;
                              return InkWell(
                                onTap: () {
                                  field.didChange(item);
                                  widget.onChanged?.call(item);
                                  setState(() => _open = false);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  color:
                                      isSelected
                                          ? AppColors.primary.withValues(
                                            alpha: 0.08,
                                          )
                                          : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? AppColors.primary
                                                    : AppColors.textPrimary,
                                            fontSize: 14.5,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_rounded,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      : const SizedBox(width: double.infinity),
            ),

            // Error de validación
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 11.5,
                  ),
                ),
              ),

            const SizedBox(height: 14),
          ],
        );
      },
    );
  }
}
