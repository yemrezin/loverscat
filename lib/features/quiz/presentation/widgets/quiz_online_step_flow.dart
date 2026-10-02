import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/game_state.dart';
import '../../../online/controllers/online_controller.dart';
import 'answer_input_card.dart';
import 'cat_display_widget.dart';
import 'quiz_timer_bar.dart';
import 'quiz_step_header.dart';
import 'quiz_online_waiting_card.dart';

/// Renders the online simultaneous round steps:
/// 0: Own Answer, 1: Guess Partner, 2: Waiting for remote partner
class QuizOnlineStepFlow extends StatelessWidget {
  final int onlineStep;
  final int remainingSeconds;
  final QuizGameState gameState;
  final dynamic currentQuestion;
  final OnlineState online;
  final ValueChanged<String?> onOwnAnswerSubmitted;
  final VoidCallback onOwnAnswerSkipped;
  final ValueChanged<String?> onGuessSubmitted;
  final VoidCallback onGuessSkipped;

  const QuizOnlineStepFlow({
    super.key,
    required this.onlineStep,
    required this.remainingSeconds,
    required this.gameState,
    required this.currentQuestion,
    required this.online,
    required this.onOwnAnswerSubmitted,
    required this.onOwnAnswerSkipped,
    required this.onGuessSubmitted,
    required this.onGuessSkipped,
  });

  @override
  Widget build(BuildContext context) {
    if (onlineStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '1. Adım: Senin Tercihin 🐾',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.player1Badge.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    online.user.formattedUsername,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.player1Badge),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          QuizTimerBar(remainingSeconds: remainingSeconds, playerAccent: AppColors.player1Badge),
          Center(
            child: CatDisplayWidget(
              reaction: gameState.activeReaction,
              size: 130,
            ),
          ),
          const SizedBox(height: 16),
          QuizPromptCard(text: currentQuestion.text, bgColor: AppColors.pastelLavender),
          const SizedBox(height: 20),
          AnswerInputCard(
            question: currentQuestion,
            buttonLabel: 'Cevabımı Kaydet 🐾',
            accentColor: AppColors.player1Badge,
            onSubmit: onOwnAnswerSubmitted,
            onSkip: onOwnAnswerSkipped,
          ),
        ],
      );
    } else if (onlineStep == 1) {
      final partnerName = online.partner?.formattedUsername ?? 'Partnerinin';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '2. Adım: $partnerName Cevabını Tahmin Et 🧠',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.player2Badge.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Tahmin Et',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.player2Badge),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          QuizTimerBar(remainingSeconds: remainingSeconds, playerAccent: AppColors.player2Badge),
          Center(
            child: CatDisplayWidget(
              reaction: gameState.activeReaction,
              size: 130,
            ),
          ),
          const SizedBox(height: 16),
          QuizPromptCard(text: currentQuestion.text, bgColor: AppColors.pastelPeach),
          const SizedBox(height: 20),
          AnswerInputCard(
            question: currentQuestion,
            buttonLabel: 'Tahminimi Gönder 🚀',
            accentColor: AppColors.player2Badge,
            onSubmit: onGuessSubmitted,
            onSkip: onGuessSkipped,
          ),
        ],
      );
    } else {
      final partnerName = online.partner?.formattedUsername ?? 'Partnerin';
      return QuizOnlineWaitingCard(partnerName: partnerName);
    }
  }
}
