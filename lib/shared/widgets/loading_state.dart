import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Widget de carga centrado con spinner del color primario SIDRU.
/// Se usa en pantallas que esperan datos async.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        strokeWidth: 2.5,
      ),
    );
  }
}
