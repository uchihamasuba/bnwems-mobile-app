import 'package:flutter/material.dart';

class AppSizes {
  AppSizes._();

  // Spacing constants
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // BorderRadius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 24.0;

  // Common UI elements height/width
  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 36.0;
  static const double appBarHeight = 60.0;
  static const double cardPadding = 16.0;

  // Layout spacers
  static const SizedBox spacingXs = SizedBox(height: xs, width: xs);
  static const SizedBox spacingS = SizedBox(height: s, width: s);
  static const SizedBox spacingM = SizedBox(height: m, width: m);
  static const SizedBox spacingL = SizedBox(height: l, width: l);
  static const SizedBox spacingXl = SizedBox(height: xl, width: xl);
}
