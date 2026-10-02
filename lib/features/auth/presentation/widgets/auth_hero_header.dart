import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Hero header for authentication screens displaying the mascot and app title.
class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.catBody.withOpacity(0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/pet_cat.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'Çiftler & Arkadaşlar İçin Canlı Ada Macerası 🐾✨',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
