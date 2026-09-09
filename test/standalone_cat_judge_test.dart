import 'package:loverscat/features/quiz/domain/models/cat_reaction.dart';
import 'package:loverscat/features/quiz/domain/models/round_answer.dart';
import 'package:loverscat/features/quiz/domain/models/question.dart';
import 'package:loverscat/features/quiz/presentation/controllers/cat_judge_engine.dart';
import 'package:loverscat/features/quiz/data/datasources/default_questions.dart';

void main() {
  print('Running standalone Paws & Us domain and judge engine verification...');
  const engine = CatJudgeEngine();

  // Test 1: Both correct -> angelWings + 2 correct
  const round1 = RoundAnswer(
    player1OwnAnswer: 'Pizza',
    player2OwnAnswer: 'Burger',
    player1Guess: 'Burger',
    player2Guess: 'Pizza',
  );
  final r1 = engine.evaluateReaction(round1);
  assert(r1.type == CatReactionType.angelWings, 'Expected angelWings');
  assert(r1.showConfetti == true, 'Expected confetti');
  assert(engine.countCorrectGuesses(round1) == 2, 'Expected 2 correct');
  print('✓ Test 1 Passed: Both players correct -> Angel wings & confetti');

  // Test 2: Player 1 fails -> slapPlayer1 + 1 correct
  const round2 = RoundAnswer(
    player1OwnAnswer: 'Pizza',
    player2OwnAnswer: 'Burger',
    player1Guess: 'Salad',
    player2Guess: 'Pizza',
  );
  final r2 = engine.evaluateReaction(round2);
  assert(r2.type == CatReactionType.slapPlayer1, 'Expected slapPlayer1');
  assert(r2.shakeScreen == true, 'Expected screen shake');
  assert(engine.countCorrectGuesses(round2) == 1, 'Expected 1 correct');
  print('✓ Test 2 Passed: Player 1 fails -> Slap player 1');

  // Test 3: Player 2 fails -> slapPlayer2 + 1 correct
  const round3 = RoundAnswer(
    player1OwnAnswer: 'Pizza',
    player2OwnAnswer: 'Burger',
    player1Guess: 'Burger',
    player2Guess: 'Salad',
  );
  final r3 = engine.evaluateReaction(round3);
  assert(r3.type == CatReactionType.slapPlayer2, 'Expected slapPlayer2');
  assert(r3.shakeScreen == true, 'Expected screen shake');
  assert(engine.countCorrectGuesses(round3) == 1, 'Expected 1 correct');
  print('✓ Test 3 Passed: Player 2 fails -> Slap player 2');

  // Test 4: Both fail -> doublePawAngry + 0 correct
  const round4 = RoundAnswer(
    player1OwnAnswer: 'Pizza',
    player2OwnAnswer: 'Burger',
    player1Guess: 'Salad',
    player2Guess: 'Sushi',
  );
  final r4 = engine.evaluateReaction(round4);
  assert(r4.type == CatReactionType.doublePawAngry, 'Expected doublePawAngry');
  assert(r4.shakeScreen == true, 'Expected screen shake');
  assert(r4.isDoubleSlap == true, 'Expected double slap');
  assert(engine.countCorrectGuesses(round4) == 0, 'Expected 0 correct');
  print('✓ Test 4 Passed: Both fail -> Double paw angry slap');

  // Test 5: Default questions pool >= 10 and has both types
  assert(defaultQuizQuestions.length >= 10, 'Expected at least 10 questions');
  assert(defaultQuizQuestions.any((q) => q.isMultipleChoice), 'Expected multiple choice questions');
  assert(defaultQuizQuestions.any((q) => q.isOpenEnded), 'Expected open-ended questions');
  print('✓ Test 5 Passed: Default questions >= 10 with multiple choice and open-ended items (${defaultQuizQuestions.length} questions)');

  // Test 6: Question serialization
  const q = QuizQuestion(
    id: 'test_q',
    text: 'Test question?',
    type: QuestionType.multipleChoice,
    options: ['A', 'B', 'C', 'D'],
    isCustom: true,
  );
  final map = q.toMap();
  final restored = QuizQuestion.fromMap(map);
  assert(restored.id == q.id && restored.text == q.text && restored.options.length == 4, 'Serialization failed');
  print('✓ Test 6 Passed: QuizQuestion serialization / deserialization roundtrip');

  print('\n🎉 ALL STANDALONE VERIFICATION TESTS PASSED SUCCESSFULLY!');
}
