import 'package:flutter/material.dart';
import 'package:loverscat/core/constants/app_colors.dart';
import 'package:loverscat/core/contracts/mini_game_contract.dart';
import 'package:loverscat/core/utils/haptic_utils.dart';
import '../controllers/mini_game_registry.dart';

/// Interactive modal presented upon reaching an island stage.
/// Explains the island's mini-game concept, controls, and dropped child item.
class MiniGameStageModal extends StatelessWidget {
  final int islandNumber;
  final VoidCallback? onContinue;

  const MiniGameStageModal({
    super.key,
    required this.islandNumber,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final meta = MiniGameRegistry.getGameForIsland(islandNumber);
    final isCoop = meta.id.mode == MiniGameMode.cooperative;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A4A4453),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Island Chip & Mode Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.player1Badge.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${meta.id.islandNumber}. Ada: ${meta.islandName}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.player1Badge,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isCoop
                          ? AppColors.pastelMint.withOpacity(0.5)
                          : AppColors.pastelPeach.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCoop ? '🤝 Co-Op İş Birliği' : '⚔️ 1v1 Tatlı Rekabet',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCoop ? const Color(0xFF0F5132) : const Color(0xFF842029),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dropped Child Memory Item Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22FFB703),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(meta.droppedChildItemIcon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Çocuğunuzun İzini Buldunuz! 👶',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B4800),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta.droppedChildItemName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta.storyClue,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mini-Game Description Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWarm,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🎮', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'Ada Görevi: ${meta.id.title}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meta.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🕹️ ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            'Kontroller: ${meta.controlGuide}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // In-Development Info Banner
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.pastelLavender.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Text('🚀 ', style: TextStyle(fontSize: 15)),
                    Expanded(
                      child: Text(
                        'Mini-oyun motor modülü geliştirilmektedir. Hatıra eşyası başarıyla kaydedildi!',
                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action Button
              ElevatedButton.icon(
                onPressed: () {
                  HapticUtils.light();
                  Navigator.of(context).pop();
                  onContinue?.call();
                },
                icon: const Text('⛵', style: TextStyle(fontSize: 16)),
                label: const Text('Rotaya Devam Et', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.player1Badge,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
