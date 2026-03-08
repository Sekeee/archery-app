import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF80E27E);
  static const Color secondaryDark = Color(0xFF087F23);
  
  // Accent Colors
  static const Color accent = Color(0xFFFFC107);
  static const Color accentLight = Color(0xFFFFD54F);
  static const Color accentDark = Color(0xFFFFA000);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFCF6679);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Rank Colors
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  
  // Transparent
  static const Color transparent = Colors.transparent;
  
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  
  // Dark theme colors (static for app_theme.dart)
  static const Color background = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF757575);
  static const Color border = Color(0xFF3D3D3D);
  static const Color divider = Color(0xFF2C2C2C);
}

/// Extension for easy theme-aware colors
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  Color get backgroundColor => isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
  Color get surfaceColor => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  Color get surfaceVariantColor => isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8E8E8);
  Color get textPrimaryColor => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF212121);
  Color get textSecondaryColor => isDark ? const Color(0xFFB3B3B3) : const Color(0xFF757575);
  Color get textHintColor => isDark ? const Color(0xFF757575) : const Color(0xFFBDBDBD);
  Color get borderColor => isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE0E0E0);
  Color get dividerColor => isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE);
}
