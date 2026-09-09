import 'package:flutter_test/flutter_test.dart';
import 'package:loverscat/features/map/domain/models/island_board.dart';
import 'package:loverscat/features/map/presentation/controllers/map_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IslandBoard and Grid Coordinate Mapping Tests', () {
    test('48 squares boustrophedon 6x8 zigzag coordinates', () {
      // Row 0 (squares 1..6, from bottom y=7, left to right x=0..5)
      final pos1 = SnakesAndLaddersConfig.getGridPosition(1);
      expect(pos1.x, 0);
      expect(pos1.y, 7);

      final pos6 = SnakesAndLaddersConfig.getGridPosition(6);
      expect(pos6.x, 5);
      expect(pos6.y, 7);

      // Row 1 (squares 7..12, y=6, right to left x=5..0)
      final pos7 = SnakesAndLaddersConfig.getGridPosition(7);
      expect(pos7.x, 5);
      expect(pos7.y, 6);

      final pos12 = SnakesAndLaddersConfig.getGridPosition(12);
      expect(pos12.x, 0);
      expect(pos12.y, 6);

      // Square 48 (top row y=0, right to left, square 48 is x=0)
      final pos48 = SnakesAndLaddersConfig.getGridPosition(48);
      expect(pos48.x, 0);
      expect(pos48.y, 0);
    });

    test('Ladders and Snakes configuration matches design', () {
      expect(SnakesAndLaddersConfig.ladders[4], 15);
      expect(SnakesAndLaddersConfig.ladders[11], 22);
      expect(SnakesAndLaddersConfig.ladders[18], 29);
      expect(SnakesAndLaddersConfig.ladders[24], 37);
      expect(SnakesAndLaddersConfig.ladders[33], 44);

      expect(SnakesAndLaddersConfig.snakes[16], 5);
      expect(SnakesAndLaddersConfig.snakes[23], 8);
      expect(SnakesAndLaddersConfig.snakes[32], 19);
      expect(SnakesAndLaddersConfig.snakes[39], 26);
      expect(SnakesAndLaddersConfig.snakes[46], 30);
    });

    test('There are exactly 10 islands defined with valid map coordinates', () {
      expect(SnakesAndLaddersConfig.islands.length, 10);
      expect(SnakesAndLaddersConfig.islands.first.title, 'Foosha Köyü');
      expect(SnakesAndLaddersConfig.islands.last.number, 10);
      expect(SnakesAndLaddersConfig.islands.last.title, 'Raftel');

      for (final island in SnakesAndLaddersConfig.islands) {
        expect(island.mapX >= 0.0 && island.mapX <= 1.0, true);
        expect(island.mapY >= 0.0 && island.mapY <= 1.0, true);
        expect(island.dockX >= 0.0 && island.dockX <= 1.0, true);
        expect(island.dockY >= 0.0 && island.dockY <= 1.0, true);
        expect(island.verticalY > 0 && island.verticalY <= SnakesAndLaddersConfig.verticalMapHeight, true);
        expect(island.verticalXRatio >= 0.0 && island.verticalXRatio <= 1.0, true);
      }
    });
  });

  group('MapNotifier Step and Movement Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Adding steps from quiz works correctly', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      expect(notifier.state.earnedSteps, 3); // initial test steps

      notifier.addStepsFromQuiz(5);
      expect(notifier.state.earnedSteps, 8);
      expect(notifier.state.lastActionMessage, contains('5 adım'));
    });

    test('Moving into ladder 4->15 automatically climbs', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      notifier.state = notifier.state.copyWith(playerPosition: 3, earnedSteps: 2);

      await notifier.useSingleStep();
      expect(notifier.state.playerPosition, 15);
      expect(notifier.state.lastActionMessage, contains('Merdiven'));
    });

    test('Moving into snake 16->5 slides down', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      notifier.state = notifier.state.copyWith(playerPosition: 15, earnedSteps: 2);

      await notifier.useSingleStep();
      expect(notifier.state.playerPosition, 5);
      expect(notifier.state.lastActionMessage, contains('Yılan'));
    });

    test('Reaching square 48 sets hasReachedIslandGoal and allows boat sailing', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      notifier.state = notifier.state.copyWith(
        currentIsland: 1,
        playerPosition: 47,
        earnedSteps: 2,
      );

      await notifier.useSingleStep();
      expect(notifier.state.playerPosition, 48);
      expect(notifier.state.hasReachedIslandGoal, true);
      expect(notifier.state.maxUnlockedIsland, 2);

      await notifier.sailToNextIsland();
      expect(notifier.state.currentIsland, 2);
      expect(notifier.state.shipIsland, 2);
      expect(notifier.state.playerPosition, 1);
      expect(notifier.state.hasReachedIslandGoal, false);
    });

    test('Selecting unlocked island updates currentIsland and playerPosition', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      notifier.state = notifier.state.copyWith(maxUnlockedIsland: 3);

      notifier.selectIsland(2);
      expect(notifier.state.currentIsland, 2);

      // Cannot select locked island 4
      notifier.selectIsland(4);
      expect(notifier.state.currentIsland, 2);
    });

    test('Reaching square 48 on Island 10 completes all islands', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      notifier.state = notifier.state.copyWith(
        currentIsland: 10,
        playerPosition: 47,
        earnedSteps: 2,
      );

      await notifier.useSingleStep();
      expect(notifier.state.playerPosition, 48);
      expect(notifier.state.hasCompletedAll10Islands, true);
    });
  });
}
