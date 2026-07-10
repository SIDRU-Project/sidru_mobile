import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../data/models/impact_metrics.dart';
import 'impact_provider.dart';

/// Pantalla de impacto ambiental global (US-36): totales de la plataforma +
/// equivalencias estimadas de CO₂ y energía a partir del peso reciclado.
class ImpactScreen extends ConsumerWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(impactProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Impacto ambiental'),
      ),
      body: async.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          message: e.toString().contains('Sin conexión')
              ? 'Sin conexión con el servidor.\nVerifica tu internet.'
              : 'No se pudieron cargar las métricas.',
          onRetry: () => ref.invalidate(impactProvider),
        ),
        data: (m) => _Content(m: m),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ImpactMetrics m;
  const _Content({required this.m});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const _SectionLabel('Impacto estimado'),
          const SizedBox(height: 8),
          _ImpactHero(
            co2Kg: m.co2AvoidedKg,
            energyKwh: m.energySavedKwh,
            weightKg: m.weightKg,
          ),
          const SizedBox(height: 18),
          const _SectionLabel('Comunidad SIDRU'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: Icons.recycling_rounded,
                label: 'Chapas recicladas',
                value: _int(m.capsRecycled),
                color: AppColors.primary,
              ),
              _StatCard(
                icon: Icons.scale_outlined,
                label: 'Peso reciclado',
                value: '${m.weightKg.toStringAsFixed(1)} kg',
                color: AppColors.secondary,
              ),
              _StatCard(
                icon: Icons.check_circle_outline,
                label: 'Sesiones confirmadas',
                value: _int(m.confirmedSessions),
                color: AppColors.success,
              ),
              _StatCard(
                icon: Icons.token_outlined,
                label: 'CTC emitidos',
                value: _int(m.ctcMinted),
                color: AppColors.secondary,
              ),
              _StatCard(
                icon: Icons.people_outline,
                label: 'Usuarios',
                value: _int(m.registeredUsers),
                color: AppColors.primary,
              ),
              _StatCard(
                icon: Icons.sensors_outlined,
                label: 'Smart Bins',
                value: _int(m.activeBins),
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Las cifras de CO₂ y energía son estimaciones a partir del peso reciclado, '
            'con factores aproximados de literatura de reciclaje.',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.5,
              height: 1.4,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  static String _int(int v) {
    final s = v.toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _ImpactHero extends StatelessWidget {
  final double co2Kg;
  final double energyKwh;
  final double weightKg;
  const _ImpactHero({
    required this.co2Kg,
    required this.energyKwh,
    required this.weightKg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _HeroMetric(
              icon: Icons.cloud_outlined,
              value: '${co2Kg.toStringAsFixed(1)} kg',
              label: 'CO₂ evitado',
            ),
          ),
          Container(width: 1, height: 48, color: const Color(0x22000000)),
          Expanded(
            child: _HeroMetric(
              icon: Icons.bolt_outlined,
              value: '${energyKwh.toStringAsFixed(1)} kWh',
              label: 'energía ahorrada',
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _HeroMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF0A0E1A);
    return Column(
      children: [
        Icon(icon, color: dark, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: dark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: dark,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}
