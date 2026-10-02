import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loverscat/features/minigames/fire_water/domain/fire_water_level_builder.dart';
import 'package:loverscat/features/minigames/fire_water/domain/models/fire_water_models.dart';
import 'package:loverscat/features/minigames/fire_water/presentation/controllers/fire_water_controller.dart';
import 'package:loverscat/features/minigames/fire_water/presentation/widgets/fire_water_canvas.dart';
import 'package:loverscat/features/minigames/fire_water/presentation/widgets/fire_water_controls.dart';
import 'package:loverscat/features/minigames/fire_water/presentation/screens/fire_water_game_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Fire & Water Mini-Game Domain and LevelBuilder Tests', () {
    test('Level 1 builds with valid platforms, hazards, gems, buttons, barriers, and doors', () {
      final state = FireWaterLevelBuilder.buildLevel1();

      expect(state.platforms.isNotEmpty, isTrue);
      expect(state.hazards.length, greaterThanOrEqualTo(3));
      expect(state.gems.length, equals(6));
      expect(state.buttons.length, equals(1));
      expect(state.barriers.length, equals(1));
      expect(state.fireDoor.type, equals(CharacterType.fire));
      expect(state.waterDoor.type, equals(CharacterType.water));
      expect(state.firePlayer.type, equals(CharacterType.fire));
      expect(state.waterPlayer.type, equals(CharacterType.water));
      expect(state.activeCharacter, equals(CharacterType.fire));
      expect(state.isCompleted, isFalse);
      expect(state.isGameOver, isFalse);
    });

    test('Gem collection count getters work correctly', () {
      final state = FireWaterLevelBuilder.buildLevel1();
      expect(state.totalGemsCount, equals(6));
      expect(state.collectedGemsCount, equals(0));

      final collectedState = state.copyWith(
        gems: state.gems.map((g) => g.copyWith(isCollected: true)).toList(),
      );
      expect(collectedState.collectedGemsCount, equals(6));
    });
  });

  group('FireWaterController Physics and Logic Tests', () {
    late FireWaterController controller;

    setUp(() {
      controller = FireWaterController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial controller state matches Level 1', () {
      expect(controller.state.activeCharacter, equals(CharacterType.fire));
      expect(controller.state.firePlayer.isAlive, isTrue);
      expect(controller.state.waterPlayer.isAlive, isTrue);
    });

    test('Switch character alternates between Fire and Water', () {
      expect(controller.state.activeCharacter, equals(CharacterType.fire));

      controller.switchCharacter();
      expect(controller.state.activeCharacter, equals(CharacterType.water));

      controller.switchCharacter();
      expect(controller.state.activeCharacter, equals(CharacterType.fire));
    });

    test('Select character explicitly sets active type', () {
      controller.selectCharacter(CharacterType.water);
      expect(controller.state.activeCharacter, equals(CharacterType.water));

      controller.selectCharacter(CharacterType.water);
      expect(controller.state.activeCharacter, equals(CharacterType.water));

      controller.selectCharacter(CharacterType.fire);
      expect(controller.state.activeCharacter, equals(CharacterType.fire));
    });

    test('Reset level restores clean state', () {
      controller.switchCharacter();
      expect(controller.state.activeCharacter, equals(CharacterType.water));

      controller.resetLevel();
      expect(controller.state.activeCharacter, equals(CharacterType.fire));
      expect(controller.state.isGameOver, isFalse);
      expect(controller.state.isCompleted, isFalse);
    });
  });

  group('Fire & Water Widgets and Screen Rendering Tests', () {
    testWidgets('FireWaterCanvas renders inside AspectRatio 1.0 container', (tester) async {
      final state = FireWaterLevelBuilder.buildLevel1();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FireWaterCanvas(state: state),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FireWaterCanvas), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('FireWaterControls renders D-pad and jump buttons and responds to taps', (tester) async {
      final controller = FireWaterController();
      final state = controller.state;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FireWaterControls(state: state, controller: controller),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ateş Kedi 🔥'), findsOneWidget);
      expect(find.text('Su Kedi 💧'), findsOneWidget);
      expect(find.text('ZIPLA'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      // Tap on Su Kedi to switch
      await tester.tap(find.text('Su Kedi 💧'));
      await tester.pump();
      expect(controller.state.activeCharacter, equals(CharacterType.water));

      controller.dispose();
    });

    testWidgets('FireWaterGameScreen renders in portrait with header, canvas, and controls', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FireWaterGameScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ateş ve Su Tapınağı'), findsOneWidget);
      expect(find.byType(FireWaterCanvas), findsOneWidget);
      expect(find.byType(FireWaterControls), findsOneWidget);
    });
  });
}
