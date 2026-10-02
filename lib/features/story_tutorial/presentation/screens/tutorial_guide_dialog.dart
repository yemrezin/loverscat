import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'story_intro_dialog.dart';

/// 3-Step interactive Tutorial Guide following the design specification.
class TutorialGuideDialog extends StatefulWidget {
  const TutorialGuideDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const TutorialGuideDialog(),
    );
  }

  @override
  State<TutorialGuideDialog> createState() => _TutorialGuideDialogState();
}

class _TutorialGuideDialogState extends State<TutorialGuideDialog> {
  int _step = 0;

  final _steps = const [
    (
      title: '1. Adım: Soru-Cevap & Yelken Rüzgarı',
      icon: '💨⛵',
      headline: 'Bilgi ve sevginizle yelkenleri doldurun!',
      body: 'Adalar arasında seyrederken çift uyum veya açık uçlu soruları cevaplayın. İki tarafın da samimi cevapları ve isabetli tahminleri rüzgar enerjisi oluşturur, tekneyi adaya doğru hızlandırır.',
    ),
    (
      title: '2. Adım: Adaya Varış & Çocuğunuzun İzleri',
      icon: '🏝️🎒',
      headline: 'Her adada kaybolan yavrunuzdan bir parça!',
      body: '10 adanın her birinde çocuğunuzun düşürdüğü bir eşya (şapka, dürbün, eldiven vb.) sizi bekler. Adaya vardığınızda mini-game mücadelesiyle hatıra eşyalarını defterinize ekleyin.',
    ),
    (
      title: '3. Adım: Büyük Hedef & Wano Zirvesi',
      icon: '🌋🎈👶',
      headline: '10 adayı aşın ve zirvede çocuğunuza kavuşun!',
      body: '10. ve son ada olan lav püskürten Wano Zirvesi\'ne ulaştığınızda büyük final gerçekleşir ve uçan balonlara asılı yavrunuzu kurtarırsınız! Ortak Uyum Skorunuz ise sonsuz sevginizin kanıtıdır.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _steps[_step];
    final isLast = _step == _steps.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x334A4453),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    'Rehber ${_step + 1} / 3',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.player1Badge),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (_) => const StoryIntroDialog());
                  },
                  icon: const Icon(Icons.auto_stories_rounded, size: 16),
                  label: const Text('Hikaye 📖', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              height: 95,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.vibrantTealGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(current.icon, style: const TextStyle(fontSize: 42)),
            ),
            const SizedBox(height: 14),

            Text(
              current.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              current.headline,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.player1Badge),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              current.body,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                if (_step > 0) ...[
                  OutlinedButton(
                    onPressed: () => setState(() => _step--),
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
                    onPressed: () {
                      HapticUtils.light();
                      if (isLast) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() => _step++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.player1Badge,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(isLast ? 'Harika, Anladım! 🚀' : 'İleri ➔'),
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
