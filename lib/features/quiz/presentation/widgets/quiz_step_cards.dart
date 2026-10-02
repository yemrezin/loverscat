import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/models/game_state.dart';
import '../controllers/quiz_game_notifier.dart';
import 'answer_input_card.dart';
import 'quiz_step_header.dart';
import 'whispering_bird_button.dart';

/// Step 1: Input view for player to seal their own answer.
class QuizStep1View extends StatelessWidget {
  final dynamic currentQuestion;
  final Color playerAccent;
  final ValueChanged<String?> onSubmit;
  final VoidCallback onSkip;

  const QuizStep1View({
    super.key,
    required this.currentQuestion,
    required this.playerAccent,
    required this.onSubmit,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizPromptCard(text: currentQuestion.text, bgColor: AppColors.pastelLavender),
        const SizedBox(height: 20),
        AnswerInputCard(
          question: currentQuestion,
          buttonLabel: AppStrings.sealButton,
          accentColor: playerAccent,
          onSubmit: onSubmit,
          onSkip: onSkip,
        ),
      ],
    );
  }
}

/// Step 2: Input view for player to guess their partner's answer.
class QuizStep2View extends StatelessWidget {
  final QuizGameState state;
  final dynamic currentQuestion;
  final Color playerAccent;
  final QuizGameNotifier notifier;
  final ValueChanged<String?> onSubmit;
  final VoidCallback onSkip;

  const QuizStep2View({
    super.key,
    required this.state,
    required this.currentQuestion,
    required this.playerAccent,
    required this.notifier,
    required this.onSubmit,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.pastelPeach.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.pastelPeach, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.step2Question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.player1Badge,
                    ),
                  ),
                  WhisperingBirdButton(
                    availableHints: state.birdWhisperHintsAvailable,
                    revealedHint: state.activeHintRevealed,
                    onUseHint: () => notifier.useBirdWhisperHint(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                currentQuestion.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AnswerInputCard(
          question: currentQuestion,
          buttonLabel: AppStrings.submitGuessButton,
          accentColor: playerAccent,
          onSubmit: onSubmit,
          onSkip: onSkip,
        ),
      ],
    );
  }
}
