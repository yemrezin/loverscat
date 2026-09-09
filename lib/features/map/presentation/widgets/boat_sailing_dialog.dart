import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/island_board.dart';

/// Animated Dialog shown when reaching square 100 on an island:
/// Boat sails on waves to the next island!
class BoatSailingDialog extends StatefulWidget {
  final int completedIsland;
  final VoidCallback onSailNext;

  const BoatSailingDialog({
    super.key,
    required this.completedIsland,
    required this.onSailNext,
  });

  @override
  State<BoatSailingDialog> createState() => _BoatSailingDialogState();
}

class _BoatSailingDialogState extends State<BoatSailingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextIslandNum = (widget.completedIsland + 1).clamp(1, 10);
    final currentInfo = SnakesAndLaddersConfig.islands[widget.completedIsland - 1];
    final nextInfo = SnakesAndLaddersConfig.islands[nextIslandNum - 1];

    return Dialog(
      backgroundColor: AppColors.backgroundWarm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Boat on animated waves
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final rock = math.sin(_controller.value * math.pi) * 0.12;
                final bob = math.cos(_controller.value * math.pi) * 6.0;
                return Transform.translate(
                  offset: Offset(0, bob),
                  child: Transform.rotate(
                    angle: rock,
                    child: const Text('⛵', style: TextStyle(fontSize: 68)),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            const Text(
              '🌊 🌊 🌊',
              style: TextStyle(fontSize: 22, letterSpacing: 4),
            ),
            const SizedBox(height: 16),

            Text(
              '${currentInfo.title} Tamamlandı! 🎉',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tekneye bindiniz! Şimdi rotamız:\n"${nextInfo.title}" (${nextInfo.subtitle})',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticUtils.medium();
                  Navigator.of(context).pop();
                  widget.onSailNext();
                },
                icon: const Text('⚓', style: TextStyle(fontSize: 18)),
                label: Text(
                  '${nextInfo.title}\'na Yelken Aç! ⛵',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.player2Badge,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
