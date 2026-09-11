import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // =========================
  // Dark Theme
  // =========================

  static const darkBackground = Color(0xFF0A0F1A);
  static const darkSecondaryBackground = Color(0xFF0F1F2A);
  static const darkSurface = Color(0xFF162A36);
  static const darkCard = Color(0xFF1E2F3A);

  static const darkPrimaryText = Color(0xFFFFFFFF);
  static const darkSecondaryText = Color(0xFFA7B3BF);

  static const darkAccentGold = Color(0xFFF4D58D);
  static const darkAccentTeal = Color(0xFF5BC0BE);

  // =========================
  // Light Theme
  // =========================

  static const lightBackground = Color(0xFFF6F9FC);
  static const lightSecondaryBackground = Color(0xFFEAF2F8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFEEF4F9);

  static const lightPrimaryText = Color(0xFF1B1B1B);
  static const lightSecondaryText = Color(0xFF6B7280);

  static const lightAccentBlue = Color(0xFF3B82F6);
  static const lightAccentBlueLight = Color(0xFFE8F1FE);

  // =========================
  // Shared App Background
  // =========================

  // Dark gradient used by Qibla, Settings, and Azkar.
  static const qiblaBackgroundTop = Color(0xFF12343F);
  static const qiblaBackgroundMiddle = Color(0xFF0B2632);
  static const qiblaBackgroundBottom = Color(0xFF06151F);

  // Light counterpart of the shared app background.
  static const qiblaLightBackgroundTop = Color(0xFFF6F9FC);
  static const qiblaLightBackgroundMiddle = Color(0xFFEAF2F8);
  static const qiblaLightBackgroundBottom = Color(0xFFE1EDF3);

  static const qiblaCompassSurface = Color(0xFF08212C);
  static const qiblaCompassRing = Color(0xFF5BC0BE);
  static const qiblaCompassRingAligned = Color(0xFF69E38A);
  static const qiblaAccentGold = Color(0xFFF4D58D);
  static const qiblaGuide = Color(0xFF8AA8B2);

  // Light Qibla palette aligned with the app light theme.
  static const qiblaLightCompassSurface = Color(0xFFFFFFFF);
  static const qiblaLightCompassRing = Color(0xFF3B82F6);
  static const qiblaLightCompassRingAligned = Color(0xFF4CAF7D);

  // =========================
  // Common
  // =========================

  static const success = Color(0xFF4CAF7D);
  static const warning = Color(0xFFFFB74D);
  static const error = Color(0xFFEF5350);
}
