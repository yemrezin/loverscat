import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cat_reaction.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/question.dart';
import '../../domain/models/round_answer.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import 'cat_judge_engine.dart';

/// Riverpod StateNotifier managing the 3-step couple quiz game loop.
class QuizGameNotifier extends StateNotifier<QuizGameState> {
  final IQuizRepository _repository;
  final CatJudgeEngine _judgeEngine;

  QuizGameNotifier({
    required IQuizRepository repository,
    CatJudgeEngine judgeEngine = const CatJudgeEngine(),
  })  : _repository = repository,
        _judgeEngine = judgeEngine,
        super(const QuizGameState(isLoading: true)) {
    loadGame();
  }

  /// Initial questions load from repository.
  Future<void> loadGame() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final questions = await _repository.getQuestions();
      state = QuizGameState(
        questions: questions,
        isLoading: false,
        currentQuestionIndex: 0,
        activePlayer: PlayerId.player1,
        phase: GamePhase.waitingOwnAnswers,
        currentRound: const RoundAnswer(),
        activeReaction: CatReaction.idle,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sorular yüklenirken hata oluştu: $e',
      );
    }
  }

  /// Starts a custom game with a specified list of chosen questions.
  void startCustomGame(List<QuizQuestion> selectedQuestions) {
    if (selectedQuestions.isEmpty) return;
    state = QuizGameState(
      questions: List.unmodifiable(selectedQuestions),
      isLoading: false,
      currentQuestionIndex: 0,
      activePlayer: PlayerId.player1,
      phase: GamePhase.waitingOwnAnswers,
      currentRound: const RoundAnswer(),
      activeReaction: CatReaction.idle,
      streak: 0,
      player1Score: 0,
      player1Wrong: 0,
      player1Blank: 0,
      player2Score: 0,
      player2Wrong: 0,
      player2Blank: 0,
      totalCorrectGuesses: 0,
      birdWhisperHintsAvailable: 0,
      isTransitionBarrierActive: false,
    );
  }

  /// Step 1: "Kendini Anlat" - Player seals their personal answer.
  /// If answer is empty or timed out, defaults to kPartnerNotKnowingAnswer.
  void sealOwnAnswer(String? answer) {
    if (state.phase != GamePhase.waitingOwnAnswers) return;

    final sanitized = (answer == null || answer.trim().isEmpty)
        ? kPartnerNotKnowingAnswer
        : answer.trim();

    final currentRound = state.currentRound;
    RoundAnswer updatedRound;

    if (state.activePlayer == PlayerId.player1) {
      updatedRound = currentRound.copyWith(player1OwnAnswer: sanitized);
      // Prompt phone handoff to Player 2
      state = state.copyWith(
        currentRound: updatedRound,
        activePlayer: PlayerId.player2,
        isTransitionBarrierActive: true,
      );
    } else {
      // Player 2 seals
      updatedRound = currentRound.copyWith(player2OwnAnswer: sanitized);

      // Both players have sealed! Transition to Step 2: "Zihin Okuma"
      state = state.copyWith(
        currentRound: updatedRound,
        phase: GamePhase.waitingGuesses,
        activePlayer: PlayerId.player1,
        isTransitionBarrierActive: true, // Pass phone back to Player 1 for guessing
      );
    }
  }

  /// Step 2: "Zihin Okuma" - Player locks their guess of the other partner's answer.
  /// If guess is empty or timed out, recorded as empty (Boş).
  void submitGuess(String? guess) {
    if (state.phase != GamePhase.waitingGuesses) return;

    final sanitized = (guess == null || guess.trim().isEmpty) ? '' : guess.trim();

    final currentRound = state.currentRound;
    RoundAnswer updatedRound;

    if (state.activePlayer == PlayerId.player1) {
      // Player 1 guessed Player 2's answer
      updatedRound = currentRound.copyWith(player1Guess: sanitized);
      state = state.copyWith(
        currentRound: updatedRound,
        activePlayer: PlayerId.player2,
        isTransitionBarrierActive: true, // Pass phone to Player 2 to guess
        clearActiveHint: true,
      );
    } else {
      // Player 2 guessed Player 1's answer
      updatedRound = currentRound.copyWith(player2Guess: sanitized);
      state = state.copyWith(
        currentRound: updatedRound,
        clearActiveHint: true,
      );

      // Both guesses are made! Trigger Step 3: "Kedi Yargısı"
      _revealCatVerdict(updatedRound);
    }
  }

  /// Step 3: "Kedi Yargısı" - Reveal answers, evaluate with CatJudgeEngine,
  /// calculate streaks, scores, and bird whisper tokens.
  void _revealCatVerdict(RoundAnswer round) {
    final reaction = _judgeEngine.evaluateReaction(round);
    final isP1Correct = round.isP1GuessCorrect;
    final isP2Correct = round.isP2GuessCorrect;
    final bothCorrect = isP1Correct && isP2Correct;

    final isP1Blank = round.player1Guess == null || round.player1Guess!.trim().isEmpty;
    final isP2Blank = round.player2Guess == null || round.player2Guess!.trim().isEmpty;

    // Scores (Doğru, Yanlış, Boş) & Streak
    final newP1Score = state.player1Score + (isP1Correct ? 1 : 0);
    final newP1Wrong = state.player1Wrong + (!isP1Correct && !isP1Blank ? 1 : 0);
    final newP1Blank = state.player1Blank + (isP1Blank ? 1 : 0);

    final newP2Score = state.player2Score + (isP2Correct ? 1 : 0);
    final newP2Wrong = state.player2Wrong + (!isP2Correct && !isP2Blank ? 1 : 0);
    final newP2Blank = state.player2Blank + (isP2Blank ? 1 : 0);

    final newStreak = bothCorrect ? (state.streak + 1) : 0;

    // Bird whisper joker tracking: 1 hint earned per 10 total correct guesses
    final roundCorrectCount = _judgeEngine.countCorrectGuesses(round);
    final oldTotal = state.totalCorrectGuesses;
    final newTotal = oldTotal + roundCorrectCount;
    final hintsEarned = (newTotal ~/ 10) - (oldTotal ~/ 10);
    final newHintsAvailable = state.birdWhisperHintsAvailable + hintsEarned;

    state = state.copyWith(
      phase: GamePhase.revealed,
      activeReaction: reaction,
      player1Score: newP1Score,
      player1Wrong: newP1Wrong,
      player1Blank: newP1Blank,
      player2Score: newP2Score,
      player2Wrong: newP2Wrong,
      player2Blank: newP2Blank,
      streak: newStreak,
      totalCorrectGuesses: newTotal,
      birdWhisperHintsAvailable: newHintsAvailable,
    );
  }

  /// Uses a Bird Whisper Joker (🕊️) to reveal the partner's sealed answer.
  bool useBirdWhisperHint() {
    if (state.birdWhisperHintsAvailable <= 0) return false;
    if (state.phase != GamePhase.waitingGuesses) return false;

    // Identify what the partner sealed
    final partnerSealedAnswer = state.activePlayer == PlayerId.player1
        ? state.currentRound.player2OwnAnswer
        : state.currentRound.player1OwnAnswer;

    if (partnerSealedAnswer == null) return false;

    state = state.copyWith(
      birdWhisperHintsAvailable: state.birdWhisperHintsAvailable - 1,
      activeHintRevealed: partnerSealedAnswer,
    );
    return true;
  }

  /// Dismisses privacy veil after passing the device to the other player.
  void dismissTransitionBarrier() {
    state = state.copyWith(isTransitionBarrierActive: false);
  }

  /// Moves to the next question in the quiz.
  void nextQuestion() {
    final nextIndex = state.currentQuestionIndex + 1;
    state = state.copyWith(
      currentQuestionIndex: nextIndex,
      phase: GamePhase.waitingOwnAnswers,
      activePlayer: PlayerId.player1,
      currentRound: const RoundAnswer(),
      activeReaction: CatReaction.idle,
      clearActiveHint: true,
    );
  }

  /// Restarts the game from question 0 with reset scores.
  void restartGame() {
    state = state.copyWith(
      currentQuestionIndex: 0,
      phase: GamePhase.waitingOwnAnswers,
      activePlayer: PlayerId.player1,
      currentRound: const RoundAnswer(),
      activeReaction: CatReaction.idle,
      streak: 0,
      player1Score: 0,
      player1Wrong: 0,
      player1Blank: 0,
      player2Score: 0,
      player2Wrong: 0,
      player2Blank: 0,
      clearActiveHint: true,
      isTransitionBarrierActive: false,
    );
  }
}
