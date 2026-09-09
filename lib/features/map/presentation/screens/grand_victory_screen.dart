import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../pet/presentation/controllers/pet_providers.dart';
import '../../../pet/presentation/widgets/pet_display_widget.dart';
import '../../../quiz/presentation/widgets/confetti_overlay_widget.dart';
import '../controllers/map_providers.dart';

/// Grand celebration screen triggered when completing Island 10!
/// Displays "Dünyanın En Harika Sevgililerisiniz! 🏆💖"
class GrandVictoryScreen extends ConsumerWidget {
  const GrandVictoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(couplePlayersProvider);
    final mapState = ref.watch(mapGameProvider);

    final p1Wins = mapState.islandWinners.values.where((w) => w == couple.player1.name).length;
    final p2Wins = mapState.islandWinners.values.where((w) => w == couple.player2.name).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: ConfettiOverlayWidget(
        active: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆 👑 💖', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text(
                      'HARİKA BİR SEVGİLİSİNİZ!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.player1Badge,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '10 Adanın tamamını birbirinizi dinleyerek, anlayarak ve zihin okuyarak fethettiniz! Aşkınız efsane oldu!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Couple Score Summary Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.angelHalo, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  PetDisplayWidget(petType: couple.player1.type, size: 75),
                                  const SizedBox(height: 6),
                                  Text(
                                    couple.player1.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.player1Badge),
                                  ),
                                  Text(
                                    '$p1Wins Ada 🏆',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const Text('VS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textLight)),
                              Column(
                                children: [
                                  PetDisplayWidget(petType: couple.player2.type, size: 75),
                                  const SizedBox(height: 6),
                                  Text(
                                    couple.player2.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.player2Badge),
                                  ),
                                  Text(
                                    '$p2Wins Ada 🏆',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            p1Wins > p2Wins
                                ? '👑 Bu Büyük Yarışın Şampiyonu: ${couple.player1.name}!'
                                : p2Wins > p1Wins
                                    ? '👑 Bu Büyük Yarışın Şampiyonu: ${couple.player2.name}!'
                                    : '💖 Muhteşem Beraberlik: Birbirinizi Mükemmel Tamamlıyorsunuz!',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    ElevatedButton(
                      onPressed: () {
                        HapticUtils.medium();
                        ref.read(mapGameProvider.notifier).resetProgress();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.player1Badge,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        '1. Adadan Tekrar Başla 🌴',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Ana Menüye Dön 🏠'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
