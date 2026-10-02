import 'package:flutter/material.dart';

/// "Paws & Us" ultra-vibrant, bright, and radiant color system.
/// Designed for high energy, candy-like mobile aesthetics, and crisp contrast.
class AppColors {
  AppColors._();

  // Backgrounds - Bright, radiant & warm
  static const Color background = Color(0xFFFFF2F5); // Bright luminous warm blush
  static const Color backgroundWarm = Color(0xFFFFF8F2); // Radiant warm honey ivory
  static const Color surface = Colors.white;

  // Saturated Candy Cards & Accents
  static const Color pastelPink = Color(0xFFFF85A6);
  static const Color pastelLavender = Color(0xFFB57EDC);
  static const Color pastelMint = Color(0xFF6EE7B7);
  static const Color pastelYellow = Color(0xFFFFD166);
  static const Color pastelPeach = Color(0xFFFF9E7D);
  static const Color pastelSky = Color(0xFF70C8F8);

  // Player Accent Colors - High Saturation & Luminous Neon
  static const Color player1Color = Color(0xFFFF007A); // Ultra-radiant hot magenta
  static const Color player2Color = Color(0xFF00C9A7); // Luminous electric mint
  static const Color player1Badge = Color(0xFFFF1493); // Electric deep pink
  static const Color player2Badge = Color(0xFF00BFA5); // Bright vibrant cyan-teal

  // Typography & Content - High Contrast Ink
  static const Color textPrimary = Color(0xFF1E1728); // Deep contrast violet-ink
  static const Color textSecondary = Color(0xFF5A5168); // Crisp readable slate
  static const Color textLight = Color(0xFF8C8299); // Balanced caption

  // Cat & Emotion Accent Colors - High Energy & Punchy
  static const Color catBody = Color(0xFFFF8500); // Luminous sunny tangerine
  static const Color catFurDark = Color(0xFFE85D04);
  static const Color catBelly = Color(0xFFFFF8F0);
  static const Color catCheeks = Color(0xFFFF1493);
  static const Color catEyes = Color(0xFF1E1728);
  static const Color angelHalo = Color(0xFFFFD000);
  static const Color angelWings = Color(0xFFFFF9E6);
  static const Color angryRed = Color(0xFFFF1744); // Electric luminous crimson
  static const Color successGreen = Color(0xFF00E676); // High-voltage emerald green

  // Borders & Dividers - Crisp & Well-Defined
  static const Color borderSubtle = Color(0xFFFFCCD9); // Warm crisp rose border
  static const Color borderActive = Color(0xFFFF1493); // High-contrast active rose
  static const Color cardShadow = Color(0x24FF1493); // Radiant warm love glow

  // Modern Mobile Vibrant Juicy Gradients
  static const LinearGradient heroPinkGradient = LinearGradient(
    colors: [Color(0xFFFF007A), Color(0xFFFF2A6D), Color(0xFFFF6584)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantTealGradient = LinearGradient(
    colors: [Color(0xFF00C9A7), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantPurpleGradient = LinearGradient(
    colors: [Color(0xFF7928CA), Color(0xFF9D4EDD), Color(0xFFFF007A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantOrangeGradient = LinearGradient(
    colors: [Color(0xFFFF5400), Color(0xFFFF8500), Color(0xFFFFB703)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient islandOceanGradient = LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF0096C7), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFF9E00), Color(0xFFFFD000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardWhiteGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFFF8FB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
