import 'package:flutter/material.dart';

class AppColors {
  // ── Fondos ──────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E1A);
  static const Color backgroundDark = Color(0xFF08090D);
  static const Color surface = Color(0xFF131829);
  static const Color surfaceElevated = Color(0xFF1B2138);

  // ── Marca ───────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF00F5A0); // verde SIDRU
  static const Color secondary = Color(0xFF00D9FF); // celeste SIDRU

  // ── Texto ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B92A8);
  static const Color textTertiary = Color(0xFF5A6178);

  // ── Semánticos ──────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF5774);
  static const Color warning = Color(0xFFFFB547);
  static const Color success = Color(0xFF00F5A0);

  // ── Bordes ──────────────────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color borderMedium = Color(0x1FFFFFFF); // rgba(255,255,255,0.12)

  // ── Gradiente principal ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00F5A0), Color(0xFF00D9FF)],
  );

  // ── Estados de sesión ───────────────────────────────────────────────────────
  static const Color sessionPending = Color(0xFFFFB547);
  static const Color sessionConfirmed = Color(0xFF00F5A0);
  static const Color sessionExpired = Color(0xFF5A6178);
  static const Color sessionCancelled = Color(0xFFFF5774);
}
