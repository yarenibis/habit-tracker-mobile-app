import 'package:flutter/material.dart';

class PixelColors {
  // Canlı pixel art palette
  static const Color background = Color(0xFFB8D8F0);
  static const Color mint = Color(0xFF4CAF82); // Daha canlı yeşil
  static const Color mintDark = Color(0xFF2E7D55);
  static const Color mintLight = Color(0xFFA8E6C8);
  static const Color pink = Color(0xFFE8547A); // Canlı pembe
  static const Color pinkLight = Color(0xFFFFC0D0);
  static const Color yellow = Color(0xFFFFD600); // Pixel sarı
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E); // Daha koyu yazı
  static const Color textMedium = Color(0xFF4A4A6A);
  static const Color checkGreen = Color(0xFF4CAF82);
  static const Color uncheckBg = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFE8F5E9);
  static const Color stone = Color(0xFF8B7355);

  static const LinearGradient progressFull = LinearGradient(
    colors: [Color(0xFFE8547A), Color(0xFFFF6B9D)],
  );
  static const LinearGradient progressEmpty = LinearGradient(
    colors: [Color(0xFFFFC0D0), Color(0xFFFFD6E0)],
  );
  static const LinearGradient habitBar = LinearGradient(
    colors: [Color(0xFF4CAF82), Color(0xFF2E7D55)],
  );
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: PixelColors.mint,
        background: PixelColors.background,
      ),
      scaffoldBackgroundColor: PixelColors.background,
      fontFamily: 'SoftPixel',
      useMaterial3: true,
    );
  }
}
