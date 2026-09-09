import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Joker Button: "Kuşlar Fısıldasın 🕊️".
/// Unlocks 1 bird whisper per 10 total correct guesses.
/// Shows animated fluttering bird dialog revealing the partner's sealed choice.
class WhisperingBirdButton extends StatelessWidget {
  final int availableHints;
  final VoidCallback onUseHint;
  final String? revealedHint;

  const WhisperingBirdButton({
    super.key,
    required this.availableHints,
    required this.onUseHint,
    this.revealedHint,
  });

  void _handleTap(BuildContext context) {
    if (availableHints <= 0) {
      HapticUtils.light();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            AppStrings.noBirdHints,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticUtils.medium();
    onUseHint();

    // Show dialog with fluttering bird animation
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _BirdWhisperDialog(hintText: revealedHint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasHint = availableHints > 0;

    return OutlinedButton.icon(
      onPressed: () => _handleTap(context),
      icon: const Text('🕊️', style: TextStyle(fontSize: 18)),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Kuşlar Fısıldasın',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: hasHint ? AppColors.player1Badge : AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$availableHints',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: hasHint ? AppColors.player1Badge : AppColors.textSecondary,
        side: BorderSide(
          color: hasHint ? AppColors.player1Badge : AppColors.borderSubtle,
          width: 1.5,
        ),
        backgroundColor: hasHint ? AppColors.pastelPink.withOpacity(0.3) : Colors.white.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _BirdWhisperDialog extends StatefulWidget {
  final String? hintText;

  const _BirdWhisperDialog({this.hintText});

  @override
  State<_BirdWhisperDialog> createState() => _BirdWhisperDialogState();
}

class _BirdWhisperDialogState extends State<_BirdWhisperDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundWarm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fluttering Bird Animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final wingFlap = math.sin(_controller.value * math.pi) * 8.0;
                return Transform.translate(
                  offset: Offset(0, -wingFlap),
                  child: const Text('🕊️', style: TextStyle(fontSize: 64)),
                );
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Kuş Kulağına Fısıldadı! ✨',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Karşı tarafın mühürlediği gizli cevap:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.pastelMint,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x15000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.hintText ?? 'Cevap kilitlendi!',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.player2Badge,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Teşekkürler Minik Kuş! 🌿'),
            ),
          ],
        ),
      ),
    );
  }
}
