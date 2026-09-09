import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/cat_reaction.dart';
import '../controllers/quiz_providers.dart';
import 'package:loverscat/features/map/presentation/screens/world_map_screen.dart';
import 'package:loverscat/features/pet/presentation/controllers/pet_providers.dart';
import 'package:loverscat/features/pet/presentation/widgets/pet_display_widget.dart';
import 'package:loverscat/features/pet/presentation/dialogs/pet_selection_dialog.dart';
import 'package:loverscat/features/custom_quiz/presentation/custom_questions_sheet.dart';
import 'quiz_builder_screen.dart';
import 'quiz_play_screen.dart';

/// Home welcome screen introducing "Paws & Us" with interactive mascot,
/// start game action, quiz builder navigation, and how-to-play modal.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showHowToPlay(BuildContext context) {
    HapticUtils.light();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.backgroundWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Text('📖', style: TextStyle(fontSize: 26)),
                  SizedBox(width: 8),
                  Text(
                    AppStrings.rulesTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRuleStep(
                stepNum: '1',
                title: AppStrings.step1Title,
                desc: AppStrings.step1Desc,
                color: AppColors.player1Badge,
              ),
              const SizedBox(height: 12),
              _buildRuleStep(
                stepNum: '2',
                title: AppStrings.step2Title,
                desc: AppStrings.step2Desc,
                color: AppColors.player2Badge,
              ),
              const SizedBox(height: 12),
              _buildRuleStep(
                stepNum: '3',
                title: AppStrings.step3Title,
                desc: AppStrings.step3Desc,
                color: AppColors.catBody,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.player1Badge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Anladım, Haydi Başlayalım! 🐾'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildRuleStep({
    required String stepNum,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              stepNum,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(quizGameProvider);
    final pet = ref.watch(activePetProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sol Üstte Haritalar Butonu
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticUtils.light();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WorldMapScreen()),
                      );
                    },
                    icon: const Text('🗺️', style: TextStyle(fontSize: 16)),
                    label: const Text(
                      'Haritalar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.player2Badge,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // Sağ Üst Kontroller
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _showHowToPlay(context),
                        child: const Text(
                          '📖 Nasıl?',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmarks_outlined, color: AppColors.textPrimary, size: 22),
                        tooltip: 'Soruları Seç',
                        onPressed: () {
                          HapticUtils.light();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const CustomQuestionsSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Interactive Pet Avatar (Click to customize Cat, Rabbit, Fox, Penguin)
              Center(
                child: InkWell(
                  onTap: () {
                    HapticUtils.light();
                    showDialog(
                      context: context,
                      builder: (_) => const PetSelectionDialog(),
                    );
                  },
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      PetDisplayWidget(
                        petType: pet.type,
                        size: 185,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.player1Badge,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x20000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Değiştir',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title & Subtitle with Pet Name
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${pet.name} (${pet.type.displayName.split(' ')[0]}) ile Aşk Yarışması 🐾',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.player1Badge,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              const Text(
                '(Hayvanını veya ismini değiştirmek için maskota tıkla!)',
                style: TextStyle(fontSize: 11, color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // Stats Row (Responsive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A4A4453),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('🔥 Aşk Serisi', '${gameState.streak}'),
                    ),
                    Container(width: 1.5, height: 32, color: AppColors.borderSubtle),
                    Expanded(
                      child: _buildStatItem('🕊️ Kuş Fısıltısı', '${gameState.birdWhisperHintsAvailable}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              ElevatedButton(
                onPressed: () {
                  HapticUtils.medium();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.player1Badge,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  AppStrings.startGame,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  HapticUtils.light();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const CustomQuestionsSheet(),
                  );
                },
                icon: const Text('📚', style: TextStyle(fontSize: 18)),
                label: const Text(
                  'Kaydedilen Soruları Seç & Oyna',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pastelMint,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.player2Badge, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  HapticUtils.light();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QuizBuilderScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  AppStrings.createCustomQuiz,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
