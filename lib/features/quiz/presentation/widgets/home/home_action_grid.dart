import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../../online/controllers/online_controller.dart';
import '../../../../map/presentation/controllers/map_providers.dart';
import '../../../../map/presentation/screens/world_map_screen.dart';
import '../../../../settings/presentation/screens/settings_screen.dart';
import '../../../../custom_quiz/presentation/custom_questions_sheet.dart';
import '../../../../story_tutorial/presentation/screens/story_intro_dialog.dart';
import '../../../../story_tutorial/presentation/widgets/child_journal_sheet.dart';
import '../../../../story_tutorial/presentation/screens/tutorial_guide_dialog.dart';
import '../../dialogs/game_ready_lobby_dialog.dart';
import '../../screens/quiz_play_screen.dart';

/// Action buttons grid and hero play banner for Home Screen.
class HomeActionGrid extends StatelessWidget {
  final OnlineState onlineState;
  final MapState mapState;

  const HomeActionGrid({
    super.key,
    required this.onlineState,
    required this.mapState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Play Action Button
        _buildHeroPlayButton(context),
        const SizedBox(height: 16),

        // 2x2 Feature Grid
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: '✍️',
                title: 'Özel Sorular',
                subtitle: 'Açık Uçlu & Test',
                badgeText: 'Maks. 5 📝',
                gradient: AppColors.vibrantPurpleGradient,
                shadowColor: const Color(0x338338EC),
                onTap: () {
                  HapticUtils.light();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const CustomQuestionsSheet(),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: '🗺️',
                title: 'Dünya Haritası',
                subtitle: '10 Ada & Raftel',
                badgeText: 'One Piece ⛵',
                gradient: AppColors.islandOceanGradient,
                shadowColor: const Color(0x330077B6),
                onTap: () {
                  HapticUtils.light();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WorldMapScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Hikaye & Hatıra Defteri
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: '📖',
                title: 'Aşkın Rotası',
                subtitle: 'Giriş Hikayesi',
                badgeText: 'Hikaye 🌸',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF758C), Color(0xFFFF7EB3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shadowColor: const Color(0x33FF758C),
                onTap: () => StoryIntroDialog.show(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: '🎒',
                title: 'Hatıra Defteri',
                subtitle: '10 Ada Eşyaları',
                badgeText: '${mapState.completedIslands.length}/10 🧸',
                gradient: const LinearGradient(
                  colors: [Color(0xFF48CAE4), Color(0xFF0096C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shadowColor: const Color(0x330096C7),
                onTap: () => ChildJournalSheet.show(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Rehber & Ayarlar
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: '💡',
                title: 'Nasıl Oynanır?',
                subtitle: 'Kurallar & İpuçları',
                badgeText: 'Rehber 🐾',
                gradient: AppColors.goldGradient,
                shadowColor: const Color(0x33FFB703),
                onTap: () => TutorialGuideDialog.show(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: '⚙️',
                title: 'Ayarlar & Pet',
                subtitle: 'Profil & Karakter',
                badgeText: 'Düzenle 🐱',
                gradient: AppColors.vibrantTealGradient,
                shadowColor: const Color(0x3300BFA5),
                onTap: () {
                  HapticUtils.light();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroPlayButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroPinkGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44FF2A6D),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            HapticUtils.heavy();
            if (onlineState.isPaired) {
              GameReadyLobbyDialog.show(context);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎮', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        onlineState.isPaired ? 'EŞLİ OYUNA BAŞLA' : AppStrings.startGame,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        onlineState.isPaired ? 'Çift Taraflı Hazır Lobisi • 10 Soru' : 'Hemen Başla • 10 Soru',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.92),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required LinearGradient gradient,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
