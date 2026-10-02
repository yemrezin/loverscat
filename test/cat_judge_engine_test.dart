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

    test('Open-ended question manual judgment overrides string mismatch', () {
      // P1 answered "Paris tatili", P2 guessed "Fransa gezisi" (different strings)
      // P1 explicitly judges P2's guess as correct
      const round = RoundAnswer(
        player1OwnAnswer: 'Paris tatili',
        player2OwnAnswer: 'Deniz kenarı kamp',
        player1Guess: 'Kamp yapmak',
        player2Guess: 'Fransa gezisi',
        p1GuessJudgedCorrect: true, // P2 judged P1's guess as correct
        p2GuessJudgedCorrect: true, // P1 judged P2's guess as correct
      );

      expect(round.isP1GuessCorrect, isTrue);
      expect(round.isP2GuessCorrect, isTrue);
      final reaction = engine.evaluateReaction(round);
      expect(reaction.type, CatReactionType.angelWings);
      expect(engine.countCorrectGuesses(round), 2);
    });

    test('Open-ended question manual judgment can reject guess even if similar', () {
      const round = RoundAnswer(
        player1OwnAnswer: 'Mavi',
        player2OwnAnswer: 'Kırmızı',
        player1Guess: 'Kırmızı',
        player2Guess: 'Açık Mavi',
        p1GuessJudgedCorrect: false, // P2 decided it is wrong
        p2GuessJudgedCorrect: false, // P1 decided it is wrong
      );

      expect(round.isP1GuessCorrect, isFalse);
      expect(round.isP2GuessCorrect, isFalse);
      final reaction = engine.evaluateReaction(round);
      expect(reaction.type, CatReactionType.doublePawAngry);
      expect(engine.countCorrectGuesses(round), 0);
    });
  });
}
