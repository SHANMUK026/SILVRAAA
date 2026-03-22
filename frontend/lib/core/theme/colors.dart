import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0F1218);
  static const Color surface = Color(0xFF1E232E);
  static const Color surfaceLight = Color(0xFF2A313C);

  // Brand Colors
  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldSecondary = Color(0xFFE5C05F);
  static const Color silverPrimary = Color(0xFFC0C0C0);
  static const Color silverSecondary = Color(0xFFE0E0E0);
  
  // Accents
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Texts
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFF64748B);

  // Borders
  static const Color border = Color(0xFF334155);

  // Light UI (Figma)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFF6DD);
  static const Color navyPrimary = Color(0xFF111827);
  static const Color grayMedium = Color(0xFF6B7280);
  static const Color grayLight = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  
  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF5D77A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient silverGradient = LinearGradient(
    colors: [Color(0xFFB0B0B0), Color(0xFFE8E8E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumDarkGradient = LinearGradient(
    colors: [Color(0xFF1E232E), Color(0xFF0F1218)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
