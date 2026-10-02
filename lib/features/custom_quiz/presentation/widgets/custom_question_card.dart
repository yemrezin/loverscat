import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../quiz/domain/models/question.dart';

/// Card presenting a custom question, with type indicator, options chips, and optional delete action.
class CustomQuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final Color accentColor;
  final VoidCallback? onDelete;

  const CustomQuestionCard({
    super.key,
    required this.question,
    required this.accentColor,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final q = question;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: q.isOpenEnded
                      ? AppColors.player2Badge.withOpacity(0.15)
                      : AppColors.player1Badge.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  q.isOpenEnded ? '📝 Açık Uçlu (Metin)' : '🔤 4 Şıklı Test',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: q.isOpenEnded ? AppColors.player2Badge : AppColors.player1Badge,
                  ),
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.angryRed, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Sil',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            q.text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          if (q.isMultipleChoice && q.options.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: q.options.map((opt) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWarm,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    opt,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
