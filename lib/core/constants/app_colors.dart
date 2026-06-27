import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF123B63);
  static const Color primaryLight = Color(0xFFEAF2FB);
  static const Color primaryDark = Color(0xFF0B2744);

  // Secondary / Accent
  static const Color secondary = Color(0xFF2D6EA3);
  static const Color accent = Color(0xFFFF8A5B);

  // Neutral colors
  static const Color background = Color(0xFFF4F7FB);
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFD7E1EC);

  // Text colors
  static const Color textPrimary = Color(0xFF102033);
  static const Color textSecondary = Color(0xFF5F7288);
  static const Color textLight = Color(0xFF95A4B5);

  // Status colors
  static const Color success = Color(0xFF169B62);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFEC8A1C);
  static const Color warningLight = Color(0xFFFFF1D9);
  static const Color error = Color(0xFFE05252);
  static const Color errorLight = Color(0xFFFDE4E4);
  static const Color info = Color(0xFF2383D9);
  static const Color infoLight = Color(0xFFE3F0FF);
  static const Color completed = Color(0xFF5A4FCF);
  static const Color completedLight = Color(0xFFEAE7FF);

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
