import 'package:flutter/material.dart';

import 'app_colors.dart';

extension AdaptiveColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get financeBackground => Theme.of(this).scaffoldBackgroundColor;

  Color get financeSurface =>
      Theme.of(this).cardTheme.color ??
      (isDarkMode ? const Color(0xFF10251C) : AppColors.surface);

  Color get financeSurfaceSoft =>
      isDarkMode ? const Color(0xFF163126) : AppColors.surfaceSoft;

  Color get financeText =>
      isDarkMode ? const Color(0xFFE8F5EE) : AppColors.textPrimary;

  Color get financeTextSecondary =>
      isDarkMode ? const Color(0xFF9DB4A8) : AppColors.textSecondary;

  Color get financeTextMuted =>
      isDarkMode ? const Color(0xFF789386) : AppColors.textMuted;

  Color get financeBorder =>
      isDarkMode ? const Color(0xFF244236) : AppColors.border;

  Color get financeInputFill =>
      Theme.of(this).inputDecorationTheme.fillColor ??
      (isDarkMode ? const Color(0xFF10251C) : AppColors.surface);
}

