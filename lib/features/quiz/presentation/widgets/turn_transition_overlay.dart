import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/round_answer.dart';

/// Fullscreen privacy shield during Pass-and-Play mode.
/// Prevents the other partner from seeing prior answers while handing over the phone.
class TurnTransitionOverlay extends StatelessWidget {
  final PlayerId nextPlayer;
  final VoidCallback onDismiss;

  const TurnTransitionOverlay({
    super.key,
    required this.nextPlayer,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isPlayer1 = nextPlayer == PlayerId.player1;
    final badgeColor = isPlayer1 ? AppColors.player1Badge : AppColors.player2Badge;
    final cardBg = isPlayer1 ? AppColors.pastelPink : AppColors.pastelMint;

    return Container(
      color: AppColors.background.withOpacity(0.96),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A4A4453),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
            border: Border.all(color: cardBg, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: cardBg.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🐾', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sıra ${nextPlayer.displayName}\'nda!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                AppStrings.passPhoneTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.passPhoneDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticUtils.medium();
                    onDismiss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: badgeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    AppStrings.readyButton,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
