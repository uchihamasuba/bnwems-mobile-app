import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary PaletteS
  static const Color primary = Color(0xFF5F5DEC); // Sleek Indigo/Blue
  static const Color primaryLight = Color(0xFFEEECFD); // Soft Lavender Light
  static const Color primaryDark = Color(0xFF3B39C3);
  
  // Secondary / Accent
  static const Color secondary = Color(0xFF9E8CF4); // Light purple
  static const Color accent = Color(0xFFFF7A8A); // Warm coral accent for wedding theme
  
  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC); // Very light grey-blue background
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE2E8F0);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textLight = Color(0xFF94A3B8); // Slate 400
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9); // Sky 500
  static const Color infoLight = Color(0xFFE0F2FE);

  // Soft Shadow
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
