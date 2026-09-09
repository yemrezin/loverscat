import 'package:flutter_test/flutter_test.dart';
import 'package:loverscat/features/quiz/domain/models/cat_reaction.dart';
import 'package:loverscat/features/quiz/domain/models/question.dart';
import 'package:loverscat/features/quiz/domain/models/round_answer.dart';
import 'package:loverscat/features/quiz/domain/repositories/i_quiz_repository.dart';
import 'package:loverscat/features/quiz/presentation/controllers/cat_judge_engine.dart';
import 'package:loverscat/features/quiz/presentation/controllers/quiz_game_notifier.dart';

class FakeQuizRepository implements IQuizRepository {
  final List<QuizQuestion> questions;

  FakeQuizRepository([this.questions = const [
    QuizQuestion(
      id: 'q1',
      text: 'En sevilen renk?',
      type: QuestionType.multipleChoice,
      options: ['Mavi', 'Pembe', 'Yeşil', 'Sarı'],
    ),
    QuizQuestion(
      id: 'q2',
      text: 'En sevilen yemek?',
      type: QuestionType.multipleChoice,
      options: ['Pizza', 'Burger', 'Makarna', 'Salata'],
    ),
  ]]);

  @override
  Future<List<QuizQuestion>> getQuestions() async => questions;

  @override
  Future<void> saveCustomQuestion(QuizQuestion question) async {}

  @override
  Future<void> deleteCustomQuestion(String id) async {}

  @override
  Future<void> resetToDefaults() async {}
}

void main() {
  group('QuizGameNotifier State Machine Tests', () {
    late FakeQuizRepository repository;
    late QuizGameNotifier notifier;

    setUp(() async {
      repository = FakeQuizRepository();
      notifier = QuizGameNotifier(
        repository: repository,
        judgeEngine: const CatJudgeEngine(),
      );
      // Allow async loading
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('Initial state starts at Step 1: waitingOwnAnswers with Player 1', () {
      final state = notifier.state;
      expect(state.phase, GamePhase.waitingOwnAnswers);
      expect(state.activePlayer, PlayerId.player1);
      expect(state.currentQuestionIndex, 0);
      expect(state.questions.length, 2);
    });

    test('Step 1 flow: Player 1 seals -> Player 2 seals -> switches to Step 2', () {
      // Player 1 seals
      notifier.sealOwnAnswer('Pembe');
      expect(notifier.state.phase, GamePhase.waitingOwnAnswers);
      expect(notifier.state.activePlayer, PlayerId.player2);
      expect(notifier.state.isTransitionBarrierActive, isTrue);
      expect(notifier.state.currentRound.player1OwnAnswer, 'Pembe');

      // Dismiss transition barrier
      notifier.dismissTransitionBarrier();
      expect(notifier.state.isTransitionBarrierActive, isFalse);

      // Player 2 seals
      notifier.sealOwnAnswer('Mavi');
      // Now both sealed! Must advance to Step 2: waitingGuesses with Player 1
      expect(notifier.state.phase, GamePhase.waitingGuesses);
      expect(notifier.state.activePlayer, PlayerId.player1);
      expect(notifier.state.isTransitionBarrierActive, isTrue);
      expect(notifier.state.currentRound.player2OwnAnswer, 'Mavi');
    });

    test('Step 2 & 3 flow: Guessing triggers revealed phase and scores', () {
      // Step 1
      notifier.sealOwnAnswer('Pembe');
      notifier.dismissTransitionBarrier();
      notifier.sealOwnAnswer('Mavi');
      notifier.dismissTransitionBarrier();

      // Step 2: Player 1 guesses Player 2 chose 'Mavi' (CORRECT)
      notifier.submitGuess('Mavi');
      expect(notifier.state.phase, GamePhase.waitingGuesses);
      expect(notifier.state.activePlayer, PlayerId.player2);
      expect(notifier.state.isTransitionBarrierActive, isTrue);

      notifier.dismissTransitionBarrier();

      // Player 2 guesses Player 1 chose 'Pembe' (CORRECT)
      notifier.submitGuess('Pembe');

      // Step 3: Automatically transitions to revealed
      expect(notifier.state.phase, GamePhase.revealed);
      expect(notifier.state.activeReaction.type, CatReactionType.angelWings);
      expect(notifier.state.player1Score, 1);
      expect(notifier.state.player2Score, 1);
      expect(notifier.state.streak, 1);
      expect(notifier.state.totalCorrectGuesses, 2);
    });

    test('Next question resets round and advances question index', () {
      // Complete round 1
      notifier.sealOwnAnswer('Pembe');
      notifier.sealOwnAnswer('Mavi');
      notifier.submitGuess('Mavi');
      notifier.submitGuess('Pembe');

      expect(notifier.state.phase, GamePhase.revealed);

      // Advance
      notifier.nextQuestion();
      expect(notifier.state.currentQuestionIndex, 1);
      expect(notifier.state.phase, GamePhase.waitingOwnAnswers);
      expect(notifier.state.activePlayer, PlayerId.player1);
      expect(notifier.state.currentRound.player1OwnAnswer, isNull);
    });

    test('If player does not write own answer/detail, silly fallback is used', () {
      // Player 1 leaves empty / null
      notifier.sealOwnAnswer('');
      expect(notifier.state.currentRound.player1OwnAnswer,
          'Partneriniz şapşal ve daha ne cevap vereceğini bilmiyor');

      // Player 2 leaves null
      notifier.sealOwnAnswer(null);
      expect(notifier.state.currentRound.player2OwnAnswer,
          'Partneriniz şapşal ve daha ne cevap vereceğini bilmiyor');
    });

    test('Tracks Doğru, Yanlış, and Boş accurately', () {
      // Step 1: Answers sealed
      notifier.sealOwnAnswer('Mavi');
      notifier.dismissTransitionBarrier();
      notifier.sealOwnAnswer('Pembe');
      notifier.dismissTransitionBarrier();

      // Step 2:
      // Player 1 submits wrong guess
      notifier.submitGuess('Sarı');
      notifier.dismissTransitionBarrier();

      // Player 2 leaves guess blank (timeout/null)
      notifier.submitGuess(null);

      expect(notifier.state.phase, GamePhase.revealed);
      // Player 1 guessed 'Sarı' (wrong for 'Pembe')
      expect(notifier.state.player1Score, 0);
      expect(notifier.state.player1Wrong, 1);
      expect(notifier.state.player1Blank, 0);

      // Player 2 left blank
      expect(notifier.state.player2Score, 0);
      expect(notifier.state.player2Wrong, 0);
      expect(notifier.state.player2Blank, 1);
    });
  });
}
