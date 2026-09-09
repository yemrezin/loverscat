import 'package:flutter_test/flutter_test.dart';
import 'package:loverscat/features/quiz/domain/models/cat_reaction.dart';
import 'package:loverscat/features/quiz/domain/models/round_answer.dart';
import 'package:loverscat/features/quiz/presentation/controllers/cat_judge_engine.dart';

void main() {
  group('CatJudgeEngine Tests', () {
    const engine = CatJudgeEngine();

    test('Both players correct should trigger AngelWings reaction and confetti', () {
      const round = RoundAnswer(
        player1OwnAnswer: 'Pizza',
        player2OwnAnswer: 'Burger',
        player1Guess: 'Burger', // P1 guessed P2's answer correctly
        player2Guess: 'Pizza',  // P2 guessed P1's answer correctly
      );

      final reaction = engine.evaluateReaction(round);
      expect(reaction.type, CatReactionType.angelWings);
      expect(reaction.showConfetti, isTrue);
      expect(reaction.shakeScreen, isFalse);
      expect(engine.countCorrectGuesses(round), 2);
    });

    test('Player 1 fails to guess Player 2 answer should slap Player 1', () {
      const round = RoundAnswer(
        player1OwnAnswer: 'Pizza',
        player2OwnAnswer: 'Burger',
        player1Guess: 'Salad', // WRONG
        player2Guess: 'Pizza', // CORRECT
      );

      final reaction = engine.evaluateReaction(round);
      expect(reaction.type, CatReactionType.slapPlayer1);
      expect(reaction.shakeScreen, isTrue);
      expect(reaction.isDoubleSlap, isFalse);
      expect(engine.countCorrectGuesses(round), 1);
    });

    test('Player 2 fails to guess Player 1 answer should slap Player 2', () {
      const round = RoundAnswer(
        player1OwnAnswer: 'Pizza',
        player2OwnAnswer: 'Burger',
        player1Guess: 'Burger', // CORRECT
        player2Guess: 'Sushi',  // WRONG
      );

      final reaction = engine.evaluateReaction(round);
      expect(reaction.type, CatReactionType.slapPlayer2);
      expect(reaction.shakeScreen, isTrue);
      expect(reaction.isDoubleSlap, isFalse);
      expect(engine.countCorrectGuesses(round), 1);
    });

    test('Both players fail should trigger furious DoublePawAngry with heavy shake', () {
      const round = RoundAnswer(
        player1OwnAnswer: 'Pizza',
        player2OwnAnswer: 'Burger',
        player1Guess: 'Salad', // WRONG
        player2Guess: 'Sushi', // WRONG
      );

      final reaction = engine.evaluateReaction(round);
      expect(reaction.type, CatReactionType.doublePawAngry);
      expect(reaction.shakeScreen, isTrue);
      expect(reaction.isDoubleSlap, isTrue);
      expect(engine.countCorrectGuesses(round), 0);
    });

    test('Answers should be case-insensitive and ignore surrounding whitespace', () {
      const round = RoundAnswer(
        player1OwnAnswer: '  Kahve ☕  ',
        player2OwnAnswer: 'ÇAY',
        player1Guess: 'çay  ',
        player2Guess: '  KAHVE ☕',
      );

      final reaction = engine.evaluateReaction(round);
      expect(reaction.type, CatReactionType.angelWings);
      expect(engine.countCorrectGuesses(round), 2);
    });
  });
}
