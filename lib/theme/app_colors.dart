import 'package:flutter/material.dart';

/// Brand palette — red & blue throughout the app.
abstract final class AppColors {
  static const primaryBlue = Color(0xFF0A4EE4);
  static const navyBlue = Color(0xFF062A70);
  static const brightBlue = Color(0xFF1468F2);
  static const lightBlue = Color(0xFFE8F1FF);
  static const primaryRed = Color(0xFFE53B31);
  static const accentRed = Color(0xFFFF2E2E);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF5B6472);
  static const border = Color(0xFFE2E8F4);
  static const surface = Color(0xFFF4F7FC);
  static const card = Colors.white;

  static const gradientBlue = LinearGradient(
    colors: [navyBlue, brightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientHero = LinearGradient(
    colors: [navyBlue, primaryBlue, primaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.65, 1.0],
  );

  static const gradientSplash = LinearGradient(
    colors: [lightBlue, surface, Color(0xFFFFF0EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF059669);
      case 'accepted':
      case 'in_progress':
        return brightBlue;
      case 'cancelled':
        return primaryRed;
      default:
        return const Color(0xFFF59E0B);
    }
  }
}
