import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'cat_display_widget.dart';
import '../../domain/models/cat_reaction.dart';

/// Card displayed while waiting for the remote partner to submit their round answers.
class QuizOnlineWaitingCard extends StatelessWidget {
  final String partnerName;

  const QuizOnlineWaitingCard({
    super.key,
    required this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Center(
          child: CatDisplayWidget(
            reaction: CatReaction.idle,
            size: 140,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSubtle, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C4A4453),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.player1Badge,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cevapların Kaydedildi! 🐾✨',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$partnerName cevaplarını tamamlaması bekleniyor...\nİkiniz de cevapladığınızda Kedi Yargıç kararı açıklayacak!',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
