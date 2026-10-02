import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../pet/domain/models/pet_avatar.dart';
import '../../domain/models/cat_reaction.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/round_answer.dart';
import '../controllers/quiz_game_notifier.dart';
import 'quiz_verdict_card.dart';

/// Step 3: Revealed Verdict & Answers View
class QuizRevealedVerdictView extends StatelessWidget {
  final QuizGameState state;
  final QuizGameNotifier notifier;
  final CouplePlayers couple;
  final bool isOnline;
  final String? currentUsername;
  final void Function(String judgedAuthor, bool isCorrect)? onSendOnlineJudge;
  final VoidCallback onNextQuestion;

  const QuizRevealedVerdictView({
    super.key,
    required this.state,
    required this.notifier,
    required this.couple,
    required this.isOnline,
    this.currentUsername,
    this.onSendOnlineJudge,
    required this.onNextQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final round = state.currentRound;
    final reaction = state.activeReaction;
    final isP1Correct = round.isP1GuessCorrect;
    final isP2Correct = round.isP2GuessCorrect;
    final currentQ = state.currentQuestion;
    final isOpenEnded = currentQ?.isOpenEnded ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: reaction.type == CatReactionType.angelWings
                ? AppColors.pastelYellow.withOpacity(0.7)
                : reaction.type == CatReactionType.doublePawAngry
                    ? AppColors.pastelPink.withOpacity(0.8)
                    : AppColors.pastelLavender.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: reaction.type == CatReactionType.angelWings
                  ? AppColors.angelHalo
                  : reaction.type == CatReactionType.doublePawAngry
                      ? AppColors.angryRed
                      : AppColors.player1Badge,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                reaction.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                reaction.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: QuizVerdictCard(
                playerName: couple.player1.name,
                accentColor: AppColors.player1Badge,
                bgColor: AppColors.pastelPink.withOpacity(0.35),
                ownAnswer: round.player1OwnAnswer ?? '-',
                partnerGuess: round.player2Guess ?? '-',
                isPartnerGuessCorrect: isP2Correct,
                partnerTitle: '${couple.player2.name}\'nin Tahmini:',
                isOpenEnded: isOpenEnded,
                canJudge: true,
                isJudged: round.isP2Judged,
                onJudge: (bool isCorrect) {
                  HapticUtils.medium();
                  notifier.judgeGuess(judgingPlayer: PlayerId.player1, isCorrect: isCorrect);
                  if (isOnline && currentUsername != null) {
                    onSendOnlineJudge?.call(currentUsername!, isCorrect);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuizVerdictCard(
                playerName: couple.player2.name,
                accentColor: AppColors.player2Badge,
                bgColor: AppColors.pastelMint.withOpacity(0.35),
                ownAnswer: round.player2OwnAnswer ?? '-',
                partnerGuess: round.player1Guess ?? '-',
                isPartnerGuessCorrect: isP1Correct,
                partnerTitle: '${couple.player1.name}\'in Tahmini:',
                isOpenEnded: isOpenEnded,
                canJudge: !isOnline,
                isJudged: round.isP1Judged,
                waitingMessage: '${couple.player2.name}\'nin kararı bekleniyor... ⏳',
                onJudge: !isOnline
                    ? (bool isCorrect) {
                        HapticUtils.medium();
                        notifier.judgeGuess(judgingPlayer: PlayerId.player2, isCorrect: isCorrect);
                      }
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x084A4453),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      couple.player1.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.player1Badge),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    StatBadgeRow(correct: state.player1Score, wrong: state.player1Wrong, blank: state.player1Blank),
                  ],
                ),
              ),
              Container(width: 1.5, height: 45, color: AppColors.borderSubtle),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      couple.player2.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.player2Badge),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    StatBadgeRow(correct: state.player2Score, wrong: state.player2Wrong, blank: state.player2Blank),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            HapticUtils.medium();
            onNextQuestion();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.player1Badge,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            state.currentQuestionIndex + 1 < state.totalQuestions
                ? AppStrings.nextQuestionButton
                : AppStrings.finishGameButton,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
