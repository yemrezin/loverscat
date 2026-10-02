import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../pet/domain/models/pet_avatar.dart';
import '../../domain/models/round_answer.dart';

/// Header bar displaying current step/phase and active player badge.
class QuizStepHeader extends StatelessWidget {
  final GamePhase phase;
  final PlayerId activePlayer;
  final Color playerAccent;
  final CouplePlayers couple;

  const QuizStepHeader({
    super.key,
    required this.phase,
    required this.activePlayer,
    required this.playerAccent,
    required this.couple,
  });

  @override
  Widget build(BuildContext context) {
    String phaseLabel;
    String subLabel;
    final activeName = activePlayer == PlayerId.player1 ? couple.player1.name : couple.player2.name;

    switch (phase) {
      case GamePhase.waitingOwnAnswers:
        phaseLabel = AppStrings.step1Header;
        subLabel = 'Sıra $activeName\'nda: Kendi cevabını mühürle!';
        break;
      case GamePhase.waitingGuesses:
        phaseLabel = AppStrings.step2Header;
        subLabel = 'Sıra $activeName\'nda: Sevgilinin cevabını tahmin et!';
        break;
      case GamePhase.revealed:
        phaseLabel = AppStrings.step3Header;
        subLabel = 'Yargıç Kedi kararını verdi!';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                phaseLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (phase != GamePhase.revealed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: playerAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activeName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: playerAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subLabel,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastel card presenting the current question text.
class QuizPromptCard extends StatelessWidget {
  final String text;
  final Color bgColor;

  const QuizPromptCard({
    super.key,
    required this.text,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A4A4453),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          height: 1.35,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Standardized AppBar for Quiz Play Screen.
class QuizTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final int streak;
  final VoidCallback onBack;

  const QuizTopAppBar({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.streak,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
        onPressed: onBack,
      ),
      centerTitle: true,
      title: Text(
        'Soru ${currentQuestionIndex + 1} / $totalQuestions',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.pastelYellow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFE066), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 4),
              Text(
                'Seri: $streak',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

