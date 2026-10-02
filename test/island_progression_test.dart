import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loverscat/features/map/presentation/controllers/map_providers.dart';
import 'package:loverscat/features/map/presentation/screens/island_map_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Island 10-Question Target and Mini-Game Progression Tests', () {
    test('MapState initial question progress is 0 and mini-game is locked on Island 1', () {
      const state = MapState();
      expect(state.getQuestionsSolved(1), equals(0));
      expect(state.isIslandQuestionsCompleted(1), isFalse);
      expect(state.isMiniGameUnlocked(1), isFalse);
    });

    test('Solving less than 10 questions keeps mini-game locked', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      notifier.recordQuestionsSolved(1, 7);

      expect(notifier.state.getQuestionsSolved(1), equals(7));
      expect(notifier.state.isIslandQuestionsCompleted(1), isFalse);
      expect(notifier.state.isMiniGameUnlocked(1), isFalse);
    });

    test('Solving 10 questions unlocks the mini-game on current island', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      notifier.recordQuestionsSolved(1, 10);

      expect(notifier.state.getQuestionsSolved(1), equals(10));
      expect(notifier.state.isIslandQuestionsCompleted(1), isTrue);
      expect(notifier.state.isMiniGameUnlocked(1), isTrue);
    });

    test('Completing mini-game unlocks next island and advances ship', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      // Solve 10 questions on Island 1
      notifier.recordQuestionsSolved(1, 10);
      expect(notifier.state.isMiniGameUnlocked(1), isTrue);

      // Complete mini game on Island 1
      await notifier.completeMiniGame(1);

      expect(notifier.state.completedIslands.contains(1), isTrue);
      expect(notifier.state.maxUnlockedIsland, greaterThanOrEqualTo(2));
      expect(notifier.state.currentIsland, equals(2));
      // Island 2 questions should be 0 and locked
      expect(notifier.state.getQuestionsSolved(2), equals(0));
      expect(notifier.state.isMiniGameUnlocked(2), isFalse);
    });

    test('Old completed islands allow free mini-game access without solving questions', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      // Mark Island 1 as completed
      await notifier.completeMiniGame(1);
      expect(notifier.state.completedIslands.contains(1), isTrue);

      // Navigate back to Island 1
      notifier.selectIsland(1);
      expect(notifier.state.currentIsland, equals(1));

      // Mini-game MUST be unlocked even with 0 questions because it is an old completed island!
      expect(notifier.state.isMiniGameUnlocked(1), isTrue);
    });

    test('2. Ada requires 10 questions before opening Fire & Water mini game', () async {
      final notifier = MapNotifier();
      await notifier.loadFuture;
      // Advance to Island 2
      await notifier.completeMiniGame(1);
      expect(notifier.state.currentIsland, equals(2));

      // Initially locked
      expect(notifier.state.isMiniGameUnlocked(2), isFalse);

      // Solve 5 questions -> still locked
      notifier.recordQuestionsSolved(2, 5);
      expect(notifier.state.isMiniGameUnlocked(2), isFalse);

      // Solve 5 more questions -> now 10, unlocked!
      notifier.recordQuestionsSolved(2, 5);
      expect(notifier.state.getQuestionsSolved(2), equals(10));
      expect(notifier.state.isMiniGameUnlocked(2), isTrue);
    });
  });

  group('IslandMapScreen UI Progress Banner Tests', () {
    testWidgets('IslandMapScreen shows question count when locked', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(mapGameProvider.notifier).loadFuture;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: IslandMapScreen(),
          ),
        ),
      );
      await tester.pump();

      // Initially 0/10 questions solved -> Test Çöz button
      expect(find.text('1. Ada: 0/10 Soru Çözüldü'), findsOneWidget);
      expect(find.text('Test Çöz 🎯'), findsOneWidget);
    });

    testWidgets('IslandMapScreen shows Oyna button when 10 questions solved', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(mapGameProvider.notifier).loadFuture;

      // Set 10 questions solved
      container.read(mapGameProvider.notifier).recordQuestionsSolved(1, 10);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: IslandMapScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1. Ada: Mini Oyun Açıldı! 🎮'), findsOneWidget);
      expect(find.text('Oyna 🕹️'), findsOneWidget);
    });
  });
}
