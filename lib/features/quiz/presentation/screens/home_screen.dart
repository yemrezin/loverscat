import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/quiz_providers.dart';
import 'package:loverscat/features/pet/presentation/controllers/pet_providers.dart';
import 'package:loverscat/features/online/controllers/online_controller.dart';
import 'package:loverscat/features/map/presentation/controllers/map_providers.dart';
import 'package:loverscat/features/story_tutorial/presentation/screens/tutorial_guide_dialog.dart';
import '../widgets/home/home_top_bar.dart';
import '../widgets/home/home_hero_couple_card.dart';
import '../widgets/home/home_vibrant_stats.dart';
import '../widgets/home/home_action_grid.dart';
import '../widgets/home/home_incoming_requests_card.dart';

/// Primary Welcome and Dashboard Screen for "Paws & Us".
/// Coordinates the couple hero avatar, vibrant stats, online matchmaking,
/// and navigations to map, quiz, custom questions, and child memory journal.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
              HomeTopBar(
                onlineState: onlineState,
                mapState: mapState,
                onShowHowToPlay: () => TutorialGuideDialog.show(context),
              ),
              const SizedBox(height: 12),

              // Dynamic Branding Header
              _buildBrandHeader(),
              const SizedBox(height: 14),

              // Gelen Arkadaşlık İstekleri Bildirim Kartı
              if (onlineState.incomingRequests.isNotEmpty) ...[
                HomeIncomingRequestsCard(
                  ref: ref,
                  requests: onlineState.incomingRequests,
                ),
                const SizedBox(height: 14),
              ],

              // Hero Display: Either Paired Couple or Single Pet with Add Friend Prompt
              HomeHeroCoupleCard(
                ref: ref,
                onlineState: onlineState,
                mapState: mapState,
                pet: pet,
              ),
              const SizedBox(height: 16),

              // Dynamic 3-Pill Stats (Aşk Serisi, Ada, Kuş Fısıltısı)
              HomeVibrantStats(
                gameState: gameState,
                mapState: mapState,
              ),
              const SizedBox(height: 16),

              // Action Buttons & Hero Play Button
              HomeActionGrid(
                onlineState: onlineState,
                mapState: mapState,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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
}
