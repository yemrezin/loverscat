import '../../domain/models/cat_reaction.dart';
import '../../domain/models/round_answer.dart';

/// Single Responsibility: Decides the Cat Judge's verdict and reaction
/// independently of Flutter UI or game persistence.
class CatJudgeEngine {
  const CatJudgeEngine();

  /// Evaluates both players' guesses against their partner's sealed answers.
  /// Returns a rich [CatReaction] controlling screen shake, audio/haptics,
  /// animations, and commentary.
  CatReaction evaluateReaction(RoundAnswer round) {
    final p1Correct = round.isP1GuessCorrect;
    final p2Correct = round.isP2GuessCorrect;

    if (p1Correct && p2Correct) {
      return CatReaction.bothCorrect;
    } else if (!p1Correct && p2Correct) {
      // Player 1 failed to guess Player 2's answer
      return CatReaction.slapP1;
    } else if (p1Correct && !p2Correct) {
      // Player 2 failed to guess Player 1's answer
      return CatReaction.slapP2;
    } else {
      // Both failed!
      return CatReaction.bothWrong;
    }
  }

  /// Calculates total correct guesses in this round (0, 1, or 2).
  int countCorrectGuesses(RoundAnswer round) {
    var count = 0;
    if (round.isP1GuessCorrect) count++;
    if (round.isP2GuessCorrect) count++;
    return count;
  }
}
