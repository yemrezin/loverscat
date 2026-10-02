import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../custom_quiz/presentation/custom_questions_sheet.dart';
import '../../../pet/domain/models/pet_avatar.dart';
import '../../../pet/presentation/controllers/pet_providers.dart';
import '../../../quiz/presentation/screens/quiz_play_screen.dart';
import '../../../online/controllers/online_controller.dart';
import '../controllers/map_providers.dart';
import '../widgets/boat_sailing_dialog.dart';
import '../widgets/snakes_ladders_board_widget.dart';
import 'grand_victory_screen.dart';

/// Main Island Map & Snakes and Ladders board screen.
/// Minimalist design showing ONLY the 6x8 game board with tactile checkers piece
/// ("dama taşı") tokens, and the "${currentIsland}. Ada" title.
class IslandMapScreen extends ConsumerStatefulWidget {
  const IslandMapScreen({super.key});

  @override
  ConsumerState<IslandMapScreen> createState() => _IslandMapScreenState();
}

class _IslandMapScreenState extends ConsumerState<IslandMapScreen> {
  void _handleStep(int playerNum) {
    HapticUtils.light();
    final mapState = ref.read(mapGameProvider);
    final couple = ref.read(couplePlayersProvider);
    final mapNotifier = ref.read(mapGameProvider.notifier);

    final steps = playerNum == 1 ? mapState.player1Steps : mapState.player2Steps;
    if (steps > 0 && !mapState.isMoving) {
      mapNotifier.usePlayerStep(
        playerNum,
        player1Name: couple.player1.name,
        player2Name: couple.player2.name,
      );
      // Synchronize with remote partner if online
      ref.read(onlineProvider.notifier).sendGameAction('step', {'playerNum': playerNum});
    } else if (steps == 0 && !mapState.isMoving) {
      _showQuizModePicker(context);
    }
  }

  void _showQuizModePicker(BuildContext context) {
    HapticUtils.light();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWarm,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quiz Modunu Seç & Adım Kazan 🎯',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                  );
                },
                icon: const Text('🌟', style: TextStyle(fontSize: 20)),
                label: const Text(
                  'Hazır Aşk Sorularıyla Oyna',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.player1Badge,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const CustomQuestionsSheet(),
                  );
                },
                icon: const Text('📚', style: TextStyle(fontSize: 20)),
                label: const Text(
                  'Kaydedilen / Özel Soruları Seç',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapGameProvider);
    final couple = ref.watch(couplePlayersProvider);
    final mapNotifier = ref.read(mapGameProvider.notifier);

    final player1 = couple.player1;
    final player2 = couple.player2;

    // Listen to remote partner game actions
    ref.listen<OnlineState>(onlineProvider, (prev, next) {
      final lastAction = next.lastGameAction;
      if (lastAction != null && lastAction != prev?.lastGameAction) {
        final actionType = lastAction['actionType'] as String?;
        final actionData = lastAction['actionData'] as Map<String, dynamic>? ?? {};

        if (actionType == 'step') {
          final remotePlayer = actionData['playerNum'] as int? ?? 2;
          mapNotifier.usePlayerStep(
            remotePlayer,
            player1Name: couple.player1.name,
            player2Name: couple.player2.name,
          );
        } else if (actionType == 'sail') {
          mapNotifier.sailToNextIsland();
        }
      }
    });

    // Check for 10-island grand victory
    if (mapState.hasCompletedAll10Islands) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GrandVictoryScreen()),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${mapState.currentIsland}. Ada',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              // 1. 6x8 Snakes & Ladders Board with Dama Taşı Tokens
              Expanded(
                child: Center(
                  child: SnakesLaddersBoardWidget(
                    player1Position: mapState.player1Position,
                    player1Pet: player1,
                    player2Position: mapState.player2Position,
                    player2Pet: player2,
                    onPlayer1Tap: () => _handleStep(1),
                    onPlayer2Tap: () => _handleStep(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Clean Bottom Bar (Dama Taşları & Quiz Icon - NO TEXT LABELS)
              _buildCleanBottomBar(mapState, player1, player2, mapNotifier),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanBottomBar(
    MapState mapState,
    PetAvatar player1,
    PetAvatar player2,
    MapNotifier mapNotifier,
  ) {
    if (mapState.hasReachedIslandGoal) {
      // Goal reached: Big glowing boat button to sail to the next island
      return Center(
        child: InkWell(
          onTap: () {
            HapticUtils.medium();
            showDialog(
              context: context,
              builder: (ctx) => BoatSailingDialog(
                completedIsland: mapState.currentIsland,
                onSailNext: () async {
                  await mapNotifier.sailToNextIsland();
                  ref.read(onlineProvider.notifier).sendGameAction('sail', {});
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2EC4B6), Color(0xFF0F9D58)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x402EC4B6),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⛵', style: TextStyle(fontSize: 28)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 26),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Player 1 Dama Taşı Button + Steps Badge
          _buildDamaTasiControl(
            playerNum: 1,
            player: player1,
            steps: mapState.player1Steps,
            isMoving: mapState.isMoving,
          ),

          // Center Quiz Icon Button
          GestureDetector(
            onTap: () => _showQuizModePicker(context),
            child: Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3DFB8500),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 26)),
              ),
            ),
          ),

          // Player 2 Dama Taşı Button + Steps Badge
          _buildDamaTasiControl(
            playerNum: 2,
            player: player2,
            steps: mapState.player2Steps,
            isMoving: mapState.isMoving,
          ),
        ],
      ),
    );
  }

  Widget _buildDamaTasiControl({
    required int playerNum,
    required PetAvatar player,
    required int steps,
    required bool isMoving,
  }) {
    final isP1 = playerNum == 1;
    final badgeColor = isP1 ? const Color(0xFFFF3366) : const Color(0xFF2EC4B6);

    return GestureDetector(
      onTap: () => _handleStep(playerNum),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DamaTasiWidget(
            petType: player.type,
            size: 54,
            isPlayer1: isP1,
          ),
          // Step Counter Bubble Badge
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30000000),
                    blurRadius: 3,
                    offset: Offset(0, 1.5),
                  ),
                ],
              ),
              child: Text(
                '$steps',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

