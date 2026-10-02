import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../map/domain/models/island_board.dart';
import '../../../map/presentation/controllers/map_providers.dart';
import '../../../pet/domain/models/pet_avatar.dart';
import '../../domain/models/game_state.dart';
import '../controllers/quiz_game_notifier.dart';
import 'quiz_verdict_card.dart';

/// Screen view presented upon finishing a quiz test.
class QuizGameOverView extends StatelessWidget {
  final QuizGameState state;
  final QuizGameNotifier notifier;
  final CouplePlayers couple;
  final MapState mapState;
  final VoidCallback onAwardAndPop;
  final VoidCallback onRestart;

  const QuizGameOverView({
    super.key,
    required this.state,
    required this.notifier,
    required this.couple,
    required this.mapState,
    required this.onAwardAndPop,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final p1Earned = state.player1Score;
    final p2Earned = state.player2Score;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text('🏆✨🐱', style: TextStyle(fontSize: 50)),
              ),
              const SizedBox(height: 14),
              const Text(
                'Yarışma Tamamlandı!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Kedi Yargıç aşkınızı ve cevaplarınızı değerlendirdi!',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Final Scores Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x104A4453),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: AppColors.borderSubtle, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Player 1 Details
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${couple.player1.type.emoji} ${couple.player1.name}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.player1Badge,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              StatBadgeRow(
                                correct: state.player1Score,
                                wrong: state.player1Wrong,
                                blank: state.player1Blank,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '+$p1Earned Adım',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D6A4F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.player1Badge.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Mevcut Kare: ${mapState.player1Position}/${SnakesAndLaddersConfig.totalSquares}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.player1Badge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1.5, height: 110, color: AppColors.borderSubtle),
                        // Player 2 Details
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${couple.player2.type.emoji} ${couple.player2.name}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.player2Badge,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              StatBadgeRow(
                                correct: state.player2Score,
                                wrong: state.player2Wrong,
                                blank: state.player2Blank,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '+$p2Earned Adım',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D6A4F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.player2Badge.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Mevcut Kare: ${mapState.player2Position}/${SnakesAndLaddersConfig.totalSquares}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.player2Badge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔥 En Uzun Seri: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${state.streak}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.player1Badge)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Step Reward Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F3DC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF52B788), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🗺️', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kazanılan Adımlar: +$p1Earned & +$p2Earned',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4332),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Doğru cevaplarınız kadar adadaki piyonlarınızı ilerletin!',
                            style: TextStyle(fontSize: 12, color: Color(0xFF2D6A4F)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: () {
                  HapticUtils.medium();
                  onAwardAndPop();
                },
                icon: const Text('🧭', style: TextStyle(fontSize: 18)),
                label: const Text(
                  'Adaya Dön & Adımları İlerlet! 🐾',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40916C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  HapticUtils.medium();
                  onRestart();
                },
                child: const Text('Tekrar Quiz Çöz 🐾'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onAwardAndPop,
                child: const Text('Kapat & Geri Dön'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
