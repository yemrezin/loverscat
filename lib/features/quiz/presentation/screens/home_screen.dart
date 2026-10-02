import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../controllers/quiz_providers.dart';
import 'package:loverscat/features/map/presentation/screens/world_map_screen.dart';
import 'package:loverscat/features/pet/presentation/controllers/pet_providers.dart';
import 'package:loverscat/features/pet/presentation/widgets/pet_display_widget.dart';
import 'package:loverscat/features/custom_quiz/presentation/custom_questions_sheet.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/online/controllers/online_controller.dart';
import 'package:loverscat/features/profile/domain/models/friend_request.dart';
import 'package:loverscat/features/settings/presentation/screens/settings_screen.dart';
import 'package:loverscat/features/map/presentation/controllers/map_providers.dart';
import '../dialogs/game_ready_lobby_dialog.dart';
import 'package:loverscat/features/profile/presentation/widgets/couple_circle_avatar.dart';
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
    final onlineState = ref.watch(onlineProvider);
    final mapState = ref.watch(mapProvider);

    // Listen for partner or request updates
    ref.listen<OnlineState>(onlineProvider, (prev, next) {
      if (next.statusMessage != null && next.statusMessage != prev?.statusMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.statusMessage!),
            backgroundColor: const Color(0xFF00C49F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sleek Mobile Top Bar
              _buildMobileTopBar(context, onlineState, mapState),
              const SizedBox(height: 12),

              // Dynamic Branding Header
              _buildBrandHeader(),
              const SizedBox(height: 14),

              // Gelen Arkadaşlık İstekleri Bildirim Kartı
              if (onlineState.incomingRequests.isNotEmpty) ...[
                _buildIncomingRequestsCard(context, ref, onlineState.incomingRequests),
                const SizedBox(height: 14),
              ],

              // Hero Display: Either Paired Couple or Single Pet with Add Friend Prompt
              if (onlineState.isPaired)
                _buildOnlineCoupleCard(context, ref, onlineState, mapState)
              else
                _buildSinglePetWithInvite(context, ref, pet, onlineState),

              const SizedBox(height: 16),

              // Dynamic 3-Pill Stats (Aşk Serisi, Ada, Kuş Fısıltısı)
              Row(
                children: [
                  Expanded(
                    child: _buildVibrantStatCard(
                      icon: '🔥',
                      value: '${gameState.streak}',
                      label: 'Aşk Serisi',
                      gradient: AppColors.vibrantOrangeGradient,
                      shadowColor: const Color(0x33FF6B00),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildVibrantStatCard(
                      icon: '⛵',
                      value: '${mapState.currentIsland}. Ada',
                      label: 'Raftel Yolu',
                      gradient: AppColors.islandOceanGradient,
                      shadowColor: const Color(0x330077B6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildVibrantStatCard(
                      icon: '🕊️',
                      value: '${gameState.birdWhisperHintsAvailable}',
                      label: 'Fısıltı',
                      gradient: AppColors.vibrantPurpleGradient,
                      shadowColor: const Color(0x338338EC),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hero Play Action Button
              _buildHeroPlayButton(context, onlineState),
              const SizedBox(height: 16),

              // Mobile 2x2 Feature Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMobileActionCard(
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
                    child: _buildMobileActionCard(
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
              Row(
                children: [
                  Expanded(
                    child: _buildMobileActionCard(
                      icon: '📖',
                      title: 'Nasıl Oynanır?',
                      subtitle: 'Kurallar & Skor',
                      badgeText: 'Rehber 🐾',
                      gradient: AppColors.goldGradient,
                      shadowColor: const Color(0x33FFB703),
                      onTap: () => _showHowToPlay(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMobileActionCard(
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTopBar(BuildContext context, OnlineState onlineState, MapState mapState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sol Üstte Harita Butonu
        InkWell(
          onTap: () {
            HapticUtils.light();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WorldMapScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.islandOceanGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330077B6),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🗺️', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                const Text(
                  'Haritalar',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sağ Üst Kontroller
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: AppColors.textPrimary, size: 22),
                tooltip: 'Nasıl Oynanır?',
                onPressed: () => _showHowToPlay(context),
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary, size: 22),
                    tooltip: 'Ayarlar & Arkadaş Ekle',
                    onPressed: () {
                      HapticUtils.light();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
                if (onlineState.incomingRequests.isNotEmpty)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.angryRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${onlineState.incomingRequests.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.player1Badge.withOpacity(0.35), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0CFF2A6D),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💕', style: TextStyle(fontSize: 12)),
              SizedBox(width: 4),
              Text(
                'One Piece • Hedef Raftel ⛵',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.player1Badge,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVibrantStatCard({
    required String icon,
    required String value,
    required String label,
    required LinearGradient gradient,
    required Color shadowColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.92),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPlayButton(BuildContext context, OnlineState onlineState) {
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

  Widget _buildMobileActionCard({
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

  Widget _buildOnlineCoupleCard(BuildContext context, WidgetRef ref, OnlineState onlineState, MapState mapState) {
    final user = onlineState.user;
    final partner = onlineState.partner!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.player1Badge, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22FF2A6D),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Player 1 (You) with Rumuz fixed INSIDE the circle
              Expanded(
                child: Column(
                  children: [
                    CoupleCircleAvatar(
                      username: user.username,
                      petType: user.petType,
                      customAvatarBase64: user.customAvatarBase64,
                      size: 96,
                      borderColor: AppColors.player1Badge,
                      isEditable: true,
                      onTap: () {
                        HapticUtils.light();
                        CoupleCircleAvatar.showAvatarManagerModal(context, ref);
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.customAvatarBase64 != null ? '📸 Fotoğrafınız' : user.petType.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Center Love Connection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    const Text('💕', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: partner.isOnline ? const Color(0xFF00C49F) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (partner.isOnline)
                            const BoxShadow(
                              color: Color(0x3300C49F),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        partner.isOnline ? 'Bağlısınız 🟢' : 'Eşleşti ⚪',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: partner.isOnline ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Player 2 (Partner) with Rumuz fixed INSIDE the circle
              Expanded(
                child: Column(
                  children: [
                    CoupleCircleAvatar(
                      username: partner.username,
                      petType: partner.petType,
                      customAvatarBase64: partner.customAvatarBase64,
                      size: 96,
                      borderColor: AppColors.player2Badge,
                      isOnline: partner.isOnline,
                      isEditable: false,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      partner.customAvatarBase64 != null ? '📸 Fotoğrafı' : partner.petType.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF2A6D), Color(0xFFFF9F1C)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x25FF2A6D),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⛵', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Raftel Yolculuğuna Birlikte Hazırsınız! (Ada ${mapState.currentIsland}/10)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePetWithInvite(BuildContext context, WidgetRef ref, PetAvatar pet, OnlineState onlineState) {
    final user = onlineState.user;
    final hasPhoto = user.customAvatarBase64 != null && user.customAvatarBase64!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.player1Badge.withOpacity(0.5), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15FF2A6D),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: CoupleCircleAvatar(
              username: user.username,
              petType: pet.type,
              customAvatarBase64: user.customAvatarBase64,
              size: 130,
              borderColor: AppColors.player1Badge,
              isEditable: true,
              onTap: () {
                HapticUtils.light();
                CoupleCircleAvatar.showAvatarManagerModal(context, ref);
              },
            ),
          ),
          const SizedBox(height: 12),
          // Photo / Pet Manager Action Button
          InkWell(
            onTap: () {
              HapticUtils.light();
              CoupleCircleAvatar.showAvatarManagerModal(context, ref);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.player1Badge.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.player1Badge.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasPhoto ? Icons.photo_camera_rounded : Icons.pets_rounded,
                    size: 15,
                    color: AppColors.player1Badge,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      hasPhoto ? 'Fotoğrafı Değiştir' : 'Fotoğraf / Karakter Değiştir',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.player1Badge,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Add Friend Prompt Card
          InkWell(
            onTap: () {
              HapticUtils.light();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.vibrantPurpleGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x338338EC),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('💌', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Partnerini Ekle & Canlı Oyna ✨',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestsCard(
    BuildContext context,
    WidgetRef ref,
    List<FriendRequest> requests,
  ) {
    final notifier = ref.read(onlineProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.player1Badge, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18FF3366),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('💌', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Yeni Arkadaşlık İsteği!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.player1Badge,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.player1Badge,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${requests.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...requests.map((req) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.pastelPink),
              ),
              child: Row(
                children: [
                  Image.asset(req.fromPetType.headAssetPath, width: 40, height: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${req.fromUsername}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Sana arkadaşlık isteği gönderdi ✨',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () {
                      HapticUtils.heavy();
                      notifier.respondFriendRequest(req.id, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kabul Et 💖',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.angryRed, size: 20),
                    tooltip: 'Reddet',
                    onPressed: () {
                      HapticUtils.light();
                      notifier.respondFriendRequest(req.id, false);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
