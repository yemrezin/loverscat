import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/story_panel.dart';

/// 4-Panel Cinematic Story Dialog presenting "Aşkın Uçan Rotası" opening.
class StoryIntroDialog extends StatefulWidget {
  const StoryIntroDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const StoryIntroDialog(),
    );
  }

  @override
  State<StoryIntroDialog> createState() => _StoryIntroDialogState();
}

class _StoryIntroDialogState extends State<StoryIntroDialog> {
  int _currentPanelIndex = 0;
  final _panels = StoryPanel.introPanels;

  void _next() {
    HapticUtils.light();
    if (_currentPanelIndex < _panels.length - 1) {
      setState(() => _currentPanelIndex++);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prev() {
    HapticUtils.light();
    if (_currentPanelIndex > 0) {
      setState(() => _currentPanelIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final panel = _panels[_currentPanelIndex];
    final isLast = _currentPanelIndex == _panels.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x334A4453),
              blurRadius: 26,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.player1Badge.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Bölüm ${_currentPanelIndex + 1} / 4',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.player1Badge,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Atla', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Illustration Hero Display
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(_currentPanelIndex),
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  panel.illustrationIcon,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              panel.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Narrative Subtitle
            Text(
              panel.subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Dramatic Quote Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.pastelLavender.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.player1Badge.withOpacity(0.2)),
              ),
              child: Text(
                panel.quote,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: AppColors.player1Badge,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                if (_currentPanelIndex > 0) ...[
                  OutlinedButton(
                    onPressed: _prev,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Geri'),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.player1Badge,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isLast ? 'Yola Çık! ⛵' : 'Devam Et ➔',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
