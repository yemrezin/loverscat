import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../pet/presentation/controllers/pet_providers.dart';
import '../../../pet/presentation/widgets/pet_display_widget.dart';
import '../../../quiz/presentation/screens/quiz_play_screen.dart';
import '../../domain/models/island_board.dart';
import '../controllers/map_providers.dart';
import '../widgets/animated_ship_widget.dart';
import '../widgets/stepping_stones_widget.dart';
import '../widgets/vertical_island_widget.dart';
import 'grand_victory_screen.dart';
import 'island_map_screen.dart';

/// Vertical Archipelago Saga Map Screen.
/// Islands ascend vertically from bottom (Ada 1) to top (Ada 10) connected with stepping stones.
class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveIsland();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveIsland() {
    if (!_scrollController.hasClients) return;
    final mapState = ref.read(mapGameProvider);
    final island = SnakesAndLaddersConfig.islands[mapState.currentIsland - 1];

    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate target offset so active island is centered in viewport
    final targetOffset = (island.verticalY - (screenHeight * 0.45))
        .clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }

  void _openIsland(IslandInfo island, MapState mapState) {
    if (island.number > mapState.maxUnlockedIsland) {
      HapticUtils.light();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF2B2D42),
          content: Row(
            children: [
              const Text('🔒', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${island.number}. Ada henüz kilitli! Önce ${island.number - 1}. Adayı tamamlamalısınız. ⛵',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    HapticUtils.medium();
    ref.read(mapGameProvider.notifier).selectIsland(island.number);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const IslandMapScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapGameProvider);
    final couple = ref.watch(couplePlayersProvider);
    final pet = couple.player1;
    final activeIsland = SnakesAndLaddersConfig.islands[mapState.currentIsland - 1];
    final shipIslandInfo = SnakesAndLaddersConfig.islands[mapState.shipIsland - 1];

    final p1Wins = mapState.islandWinners.values.where((w) => w == couple.player1.name).length;
    final p2Wins = mapState.islandWinners.values.where((w) => w == couple.player2.name).length;

    if (mapState.hasCompletedAll10Islands) {
      return const GrandVictoryScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0077B6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF03045E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Dünya Haritası',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          // Step Balance Badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.pastelMint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF52B788), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🐾', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${mapState.player1Steps + mapState.player2Steps} Adım',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1B4332),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Couple Scoreboard Subheader
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF023E8A),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${couple.player1.name}: $p1Wins Ada  •  ${couple.player2.name}: $p2Wins Ada',
                      style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      HapticUtils.light();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
                      );
                    },
                    icon: const Text('🎯', style: TextStyle(fontSize: 14)),
                    label: const Text(
                      '+Adım Kazan',
                      style: TextStyle(fontSize: 12, color: AppColors.pastelYellow, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Vertical Ocean Channel
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mapWidth = constraints.maxWidth;
                  const mapHeight = SnakesAndLaddersConfig.verticalMapHeight;

                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: mapWidth,
                      height: mapHeight,
                      child: Stack(
                        children: [
                          // 1. Tropical Sparkling Sea Background
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF023E8A), // Deeper blue at high castle
                                    Color(0xFF0077B6),
                                    Color(0xFF0096C7),
                                    Color(0xFF00B4D8),
                                    Color(0xFF48CAE4), // Brighter turquoise at start
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 2. Stepping Stones connecting consecutive islands
                          for (int i = 0; i < SnakesAndLaddersConfig.islands.length - 1; i++)
                            Builder(
                              builder: (context) {
                                final islandA = SnakesAndLaddersConfig.islands[i];
                                final islandB = SnakesAndLaddersConfig.islands[i + 1];

                                final startOffset = Offset(
                                  islandA.verticalXRatio * mapWidth,
                                  islandA.verticalY + 20,
                                );
                                final endOffset = Offset(
                                  islandB.verticalXRatio * mapWidth,
                                  islandB.verticalY + 70,
                                );

                                return Positioned.fill(
                                  child: CustomPaint(
                                    painter: SteppingStonesPainter(
                                      start: startOffset,
                                      end: endOffset,
                                      isPathUnlocked: islandB.number <= mapState.maxUnlockedIsland,
                                    ),
                                  ),
                                );
                              },
                            ),

                          // 3. Floating Islands
                          for (final island in SnakesAndLaddersConfig.islands)
                            Positioned(
                              left: (island.verticalXRatio * mapWidth) - (island.number == 10 ? 85 : 71),
                              top: island.verticalY,
                              child: VerticalIslandWidget(
                                island: island,
                                isUnlocked: island.number <= mapState.maxUnlockedIsland,
                                isCurrent: island.number == mapState.currentIsland,
                                isCompleted: mapState.completedIslands.contains(island.number),
                                winnerName: mapState.islandWinners[island.number],
                                onTap: () => _openIsland(island, mapState),
                              ),
                            ),

                          // 4. Sailing Ship (anchored in water beside active island)
                          Builder(
                            builder: (context) {
                              final shipIsland = shipIslandInfo;
                              final isLeftSide = shipIsland.verticalXRatio > 0.5;
                              final shipX = isLeftSide
                                  ? (shipIsland.verticalXRatio * mapWidth) - 120
                                  : (shipIsland.verticalXRatio * mapWidth) + 72;
                              final shipY = shipIsland.verticalY + 28;

                              return AnimatedPositioned(
                                duration: const Duration(milliseconds: 1400),
                                curve: Curves.easeInOutCubic,
                                left: shipX.clamp(10.0, mapWidth - 60.0),
                                top: shipY,
                                child: GestureDetector(
                                  onTap: () => _openIsland(shipIsland, mapState),
                                  child: Tooltip(
                                    message: 'Gemi: ${shipIsland.number}. Ada',
                                    child: AnimatedShipWidget(
                                      size: 48,
                                      isSailing: mapState.isShipSailing,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Selected Island Action Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Pet Avatar badge
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: activeIsland.themeColor,
                          shape: BoxShape.circle,
                        ),
                        child: PetDisplayWidget(petType: pet.type, size: 52),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${activeIsland.number}. Ada: ${activeIsland.title}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (mapState.completedIslands.contains(activeIsland.number))
                                  const Text('⭐', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeIsland.subtitle,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${couple.player1.name}: ${mapState.player1Position}/${SnakesAndLaddersConfig.totalSquares} • ${couple.player2.name}: ${mapState.player2Position}/${SnakesAndLaddersConfig.totalSquares}',
                              style: const TextStyle(fontSize: 11, color: AppColors.player1Badge, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openIsland(activeIsland, mapState),
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          label: Text(
                            mapState.completedIslands.contains(activeIsland.number)
                                ? 'Adayı Tekrar Oyna 🐾'
                                : '${activeIsland.number}. Adayı Oyna 🐾',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.player1Badge,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
