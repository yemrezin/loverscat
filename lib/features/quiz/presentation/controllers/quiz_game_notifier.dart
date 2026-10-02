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

  /// Sets both players' inputs simultaneously in online mode and triggers Cat Verdict.
  void setOnlineRoundAnswers({
    required String p1OwnAnswer,
    required String p1Guess,
    required String p2OwnAnswer,
    required String p2Guess,
  }) {
    final sanitizedP1Own = p1OwnAnswer.trim().isEmpty ? kPartnerNotKnowingAnswer : p1OwnAnswer.trim();
    final sanitizedP2Own = p2OwnAnswer.trim().isEmpty ? kPartnerNotKnowingAnswer : p2OwnAnswer.trim();
    final sanitizedP1Guess = p1Guess.trim();
    final sanitizedP2Guess = p2Guess.trim();

    final round = RoundAnswer(
      player1OwnAnswer: sanitizedP1Own,
      player2OwnAnswer: sanitizedP2Own,
      player1Guess: sanitizedP1Guess,
      player2Guess: sanitizedP2Guess,
    );

    state = state.copyWith(currentRound: round, isTransitionBarrierActive: false);
    _revealCatVerdict(round);
  }


  /// Step 3: "Kedi Yargısı" - Reveal answers, evaluate with CatJudgeEngine,
  /// calculate streaks, scores, and bird whisper tokens.
  void _revealCatVerdict(RoundAnswer round) {
    final currentQ = state.currentQuestion;
    final isOpenEnded = currentQ?.isOpenEnded ?? false;

    final reaction = _judgeEngine.evaluateReaction(round);
    final isP1Correct = round.isP1GuessCorrect;
    final isP2Correct = round.isP2GuessCorrect;
    final bothCorrect = isP1Correct && isP2Correct;

    final isP1Blank = round.player1Guess == null || round.player1Guess!.trim().isEmpty;
    final isP2Blank = round.player2Guess == null || round.player2Guess!.trim().isEmpty;

    // For open-ended questions, scores are decided when players judge
    final p1ScoreAdd = isOpenEnded ? (round.isP1Judged && isP1Correct ? 1 : 0) : (isP1Correct ? 1 : 0);
    final p1WrongAdd = isOpenEnded ? (round.isP1Judged && !isP1Correct && !isP1Blank ? 1 : 0) : (!isP1Correct && !isP1Blank ? 1 : 0);
    final p1BlankAdd = (isP1Blank ? 1 : 0);

    final p2ScoreAdd = isOpenEnded ? (round.isP2Judged && isP2Correct ? 1 : 0) : (isP2Correct ? 1 : 0);
    final p2WrongAdd = isOpenEnded ? (round.isP2Judged && !isP2Correct && !isP2Blank ? 1 : 0) : (!isP2Correct && !isP2Blank ? 1 : 0);
    final p2BlankAdd = (isP2Blank ? 1 : 0);

    // Scores (Doğru, Yanlış, Boş) & Streak
    final newP1Score = state.player1Score + p1ScoreAdd;
    final newP1Wrong = state.player1Wrong + p1WrongAdd;
    final newP1Blank = state.player1Blank + p1BlankAdd;

    final newP2Score = state.player2Score + p2ScoreAdd;
    final newP2Wrong = state.player2Wrong + p2WrongAdd;
    final newP2Blank = state.player2Blank + p2BlankAdd;

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

  /// Evaluates or updates personal judgment of a guess.
  /// judgingPlayer == PlayerId.player1: Player 1 judges Player 2's guess (which attempted to guess Player 1's answer).
  /// judgingPlayer == PlayerId.player2: Player 2 judges Player 1's guess (which attempted to guess Player 2's answer).
  void judgeGuess({
    required PlayerId judgingPlayer,
    required bool isCorrect,
  }) {
    final round = state.currentRound;
    final currentQ = state.currentQuestion;
    final isOpenEnded = currentQ?.isOpenEnded ?? false;

    final prevP1Correct = round.isP1GuessCorrect;
    final prevP2Correct = round.isP2GuessCorrect;
    final prevP1Judged = round.isP1Judged;
    final prevP2Judged = round.isP2Judged;

    RoundAnswer updatedRound;
    if (judgingPlayer == PlayerId.player1) {
      updatedRound = round.copyWith(p2GuessJudgedCorrect: isCorrect);
    } else {
      updatedRound = round.copyWith(p1GuessJudgedCorrect: isCorrect);
    }

    final newP1Correct = updatedRound.isP1GuessCorrect;
    final newP2Correct = updatedRound.isP2GuessCorrect;

    int p1ScoreDelta = 0;
    int p1WrongDelta = 0;
    if (isOpenEnded && !prevP1Judged) {
      if (newP1Correct) p1ScoreDelta = 1; else p1WrongDelta = 1;
    } else if (prevP1Correct != newP1Correct) {
      p1ScoreDelta = newP1Correct ? 1 : -1;
      p1WrongDelta = newP1Correct ? -1 : 1;
    }

    int p2ScoreDelta = 0;
    int p2WrongDelta = 0;
    if (isOpenEnded && !prevP2Judged) {
      if (newP2Correct) p2ScoreDelta = 1; else p2WrongDelta = 1;
    } else if (prevP2Correct != newP2Correct) {
      p2ScoreDelta = newP2Correct ? 1 : -1;
      p2WrongDelta = newP2Correct ? -1 : 1;
    }

    final reaction = _judgeEngine.evaluateReaction(updatedRound);
    final bothCorrect = newP1Correct && newP2Correct;
    final newStreak = bothCorrect ? (state.streak + 1) : 0;

    state = state.copyWith(
      currentRound: updatedRound,
      activeReaction: reaction,
      player1Score: (state.player1Score + p1ScoreDelta).clamp(0, 999),
      player1Wrong: (state.player1Wrong + p1WrongDelta).clamp(0, 999),
      player2Score: (state.player2Score + p2ScoreDelta).clamp(0, 999),
      player2Wrong: (state.player2Wrong + p2WrongDelta).clamp(0, 999),
      streak: newStreak,
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
