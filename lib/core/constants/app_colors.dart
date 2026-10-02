import 'package:flutter/material.dart';

/// "Paws & Us" pastel & sweet palette.
/// Designed for high aesthetic appeal, softness, and high legibility.
class AppColors {
  AppColors._();

  // Backgrounds - Crisp, radiant & clean
  static const Color background = Color(0xFFFFF5F7); // Bright warm blush
  static const Color backgroundWarm = Color(0xFFFFFBF2); // Radiant warm ivory
  static const Color surface = Colors.white;

  // Vibrant Cards & Accents
  static const Color pastelPink = Color(0xFFFFB3C6);
  static const Color pastelLavender = Color(0xFFD8B4F8);
  static const Color pastelMint = Color(0xFFA7F3D0);
  static const Color pastelYellow = Color(0xFFFFE66D);
  static const Color pastelPeach = Color(0xFFFFC6A5);
  static const Color pastelSky = Color(0xFFBAE6FD);

  // Player Accent Colors - High Saturation & Luminous
  static const Color player1Color = Color(0xFFFF4D80); // Radiant coral-pink
  static const Color player2Color = Color(0xFF2EC4B6); // Luminous turquoise
  static const Color player1Badge = Color(0xFFFF2A6D); // Vivid hot magenta/rose
  static const Color player2Badge = Color(0xFF00BFA5); // Bright vibrant teal

  // Typography & Content
  static const Color textPrimary = Color(0xFF2B2638); // Deep contrast purple-ink
  static const Color textSecondary = Color(0xFF6C6378); // Clear readable slate
  static const Color textLight = Color(0xFF9A91A5); // Soft caption

  // Cat & Emotion Accent Colors - High Energy
  static const Color catBody = Color(0xFFFF9F1C); // Bright luminous ginger
  static const Color catFurDark = Color(0xFFE85D04);
  static const Color catBelly = Color(0xFFFFF8F0);
  static const Color catCheeks = Color(0xFFFF3366);
  static const Color catEyes = Color(0xFF2B2638);
  static const Color angelHalo = Color(0xFFFFD000);
  static const Color angelWings = Color(0xFFFFF9E6);
  static const Color angryRed = Color(0xFFFF3366);
  static const Color successGreen = Color(0xFF00C49F);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFFFE0E9);
  static const Color cardShadow = Color(0x18FF2A6D);

  // Modern Mobile Vibrant Gradients
  static const LinearGradient heroPinkGradient = LinearGradient(
    colors: [Color(0xFFFF2A6D), Color(0xFFFF62A5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantTealGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF00C49F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantPurpleGradient = LinearGradient(
    colors: [Color(0xFF8338EC), Color(0xFFC77DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantOrangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFFA200)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient islandOceanGradient = LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB703), Color(0xFFFFD166)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
