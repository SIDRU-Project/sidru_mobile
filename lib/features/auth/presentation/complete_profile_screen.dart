import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/lima_districts.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../user/presentation/user_provider.dart';
import 'auth_provider.dart';

/// Pantalla única tras crear la cuenta con Google: distrito y teléfono opcionales.
/// Reutiliza PUT /profiles/me. "Ahora no" y "Guardar" terminan en el inicio.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _phoneCtrl = TextEditingController();
  String? _district;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(authNotifierProvider).finishProfileCompletion();
    if (mounted) context.go(RouteNames.home);
  }

  Future<void> _save() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isNotEmpty && !RegExp(r'^\d{7,15}$').hasMatch(phone)) {
      setState(() => _error = 'El teléfono solo lleva dígitos (7 a 15).');
      return;
    }
    if (_district == null && phone.isEmpty) {
      _finish();
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final notifier = ref.read(userNotifierProvider.notifier);
    final current = await ref.read(userNotifierProvider.future);
    final error = await notifier.updateProfile(
      fullName: current?.fullName ?? '',
      phone: phone.isNotEmpty ? phone : (current?.phone ?? ''),
      district: _district ?? (current?.district ?? ''),
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isLoading = false;
        _error = error;
      });
      return;
    }
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              Text('Un último paso', style: AppTextStyles.displayLarge),
              const SizedBox(height: 6),
              Text(
                'Cuéntanos de dónde reciclas. Puedes hacerlo después desde tu perfil.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              AppDropdownField(
                label: 'Distrito',
                hint: 'Selecciona tu distrito',
                value: _district,
                items: limaDistricts,
                prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                onChanged: (v) => setState(() => _district = v),
              ),
              AppTextField(
                label: 'Teléfono (opcional)',
                hint: '999999999',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientButton(
                label: 'Guardar y continuar',
                onPressed: _save,
                isLoading: _isLoading,
              ),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _finish,
                  child: const Text('Ahora no'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
