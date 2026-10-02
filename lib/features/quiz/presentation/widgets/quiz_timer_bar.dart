import 'package:flutter/material.dart';

/// Reusable countdown timer bar for quiz rounds.
class QuizTimerBar extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final Color playerAccent;

  const QuizTimerBar({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 10,
    required this.playerAccent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (remainingSeconds / totalSeconds.toDouble()).clamp(0.0, 1.0);
    final isUrgent = remainingSeconds <= 3;
    final timerColor = isUrgent
        ? const Color(0xFFE63946)
        : (remainingSeconds <= 6 ? const Color(0xFFFB8500) : playerAccent);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFFFEBEE) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: timerColor.withOpacity(isUrgent ? 0.9 : 0.4),
          width: isUrgent ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: timerColor.withOpacity(isUrgent ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isUrgent ? Icons.alarm_on_rounded : Icons.timer_outlined,
                    size: 19,
                    color: timerColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isUrgent ? 'Süre Bitiyor! ⏳' : 'Kalan Süre ($totalSeconds sn)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: timerColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: timerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$remainingSeconds sn',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.grey.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
            ),
          ),
        ],
      ),
    );
  }
}
