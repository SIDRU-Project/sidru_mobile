import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Bottom navigation flotante alineado al prototipo SIDRU.
/// - Contenedor oscuro con bordes redondeados y sombra.
/// - Botón central de Escanear con gradiente verde/celeste y glow.
/// - Ítems activos en verde, inactivos en gris.
class SidruBottomNav extends StatelessWidget {
  /// Índice activo: 0=Inicio, 1=Historial, 2=Escanear, 3=Premios, 4=Perfil
  final int currentIndex;
  final void Function(int) onTap;

  const SidruBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = max(MediaQuery.of(context).padding.bottom, 10.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 6),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF131829),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Inicio',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.history_outlined,
              activeIcon: Icons.history_rounded,
              label: 'Historial',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _ScanButton(onTap: () => onTap(2)),
            _NavItem(
              icon: Icons.card_giftcard_outlined,
              activeIcon: Icons.card_giftcard_rounded,
              label: 'Premios',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Perfil',
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ítem regular ──────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textTertiary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 58,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: isActive ? 0 : 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Botón central Escanear ────────────────────────────────────────────────────

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 58,
        height: 64,
        child: Center(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Color(0xFF0A0E1A),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
