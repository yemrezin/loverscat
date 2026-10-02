import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/game_state.dart';

/// Stat badges displaying Correct, Wrong, Blank count.
class StatBadgeRow extends StatelessWidget {
  final int correct;
  final int wrong;
  final int blank;

  const StatBadgeRow({
    super.key,
    required this.correct,
    required this.wrong,
    required this.blank,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip('✅ $correct', AppColors.successGreen),
        const SizedBox(width: 4),
        _buildChip('❌ $wrong', AppColors.angryRed),
        const SizedBox(width: 4),
        _buildChip('⚪ $blank', const Color(0xFF757575)),
      ],
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

/// Card presenting a player's answer, partner's guess, and open-ended judgment buttons.
class QuizVerdictCard extends StatelessWidget {
  final String playerName;
  final Color accentColor;
  final Color bgColor;
  final String ownAnswer;
  final String partnerGuess;
  final bool isPartnerGuessCorrect;
  final String partnerTitle;
  final bool isOpenEnded;
  final bool canJudge;
  final bool isJudged;
  final ValueChanged<bool>? onJudge;
  final String? waitingMessage;

  const QuizVerdictCard({
    super.key,
    required this.playerName,
    required this.accentColor,
    required this.bgColor,
    required this.ownAnswer,
    required this.partnerGuess,
    required this.isPartnerGuessCorrect,
    required this.partnerTitle,
    this.isOpenEnded = false,
    this.canJudge = false,
    this.isJudged = false,
    this.onJudge,
    this.waitingMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isPartnerEmptyOrSilly =
        ownAnswer == kPartnerNotKnowingAnswer || ownAnswer.trim().isEmpty;
    final displayOwnAnswer = isPartnerEmptyOrSilly ? kPartnerNotKnowingAnswer : ownAnswer;
    final isGuessBlank = partnerGuess.trim().isEmpty || partnerGuess == '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  playerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                isPartnerGuessCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isPartnerGuessCorrect ? AppColors.successGreen : AppColors.angryRed,
                size: 20,
              ),
            ],
          ),
          const Divider(height: 16),
          const Text(
            'Kendi Cevabı / Detayı:',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          if (isPartnerEmptyOrSilly)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFD166), width: 1),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🤪 ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      kPartnerNotKnowingAnswer,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF854D0E),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              displayOwnAnswer,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            partnerTitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            isGuessBlank ? '⚪ Boş (Süre doldu / Cevap verilmedi)' : partnerGuess,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isPartnerGuessCorrect
                  ? AppColors.successGreen
                  : (isGuessBlank ? const Color(0xFF757575) : AppColors.angryRed),
              fontStyle: isGuessBlank ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (isOpenEnded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    canJudge ? '⚖️ Bu tahmini değerlendir:' : '⚖️ Karar:',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  if (canJudge) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticUtils.medium();
                              onJudge?.call(true);
                            },
                            icon: const Icon(Icons.thumb_up_alt_rounded, size: 14),
                            label: const Text('Doğru (+1)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isJudged && isPartnerGuessCorrect ? AppColors.successGreen : Colors.grey.shade100,
                              foregroundColor: isJudged && isPartnerGuessCorrect ? Colors.white : AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              elevation: isJudged && isPartnerGuessCorrect ? 2 : 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticUtils.medium();
                              onJudge?.call(false);
                            },
                            icon: const Icon(Icons.thumb_down_alt_rounded, size: 14),
                            label: const Text('Bilemedi (0)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isJudged && !isPartnerGuessCorrect ? AppColors.angryRed : Colors.grey.shade100,
                              foregroundColor: isJudged && !isPartnerGuessCorrect ? Colors.white : AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              elevation: isJudged && !isPartnerGuessCorrect ? 2 : 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    if (isJudged)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPartnerGuessCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 15,
                            color: isPartnerGuessCorrect ? AppColors.successGreen : AppColors.angryRed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPartnerGuessCorrect ? 'Doğru Kabul Etti! (+1)' : 'Yanlış Saydı (0)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPartnerGuessCorrect ? AppColors.successGreen : AppColors.angryRed,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        waitingMessage ?? 'Partnerinin kararı bekleniyor... ⏳',
                        style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
