import 'cat_reaction.dart';
import 'question.dart';
import 'round_answer.dart';

const String kPartnerNotKnowingAnswer =
    'Partneriniz şapşal ve daha ne cevap vereceğini bilmiyor';

/// Full immutable state for the Quiz Game.
class QuizGameState {
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final PlayerId activePlayer;
  final GamePhase phase;
  final RoundAnswer currentRound;
  final CatReaction activeReaction;
  final int streak;
  final int totalCorrectGuesses;
  final int birdWhisperHintsAvailable;
  final String? activeHintRevealed;
  final int player1Score; // Correct answers
  final int player1Wrong;
  final int player1Blank;
  final int player2Score; // Correct answers
  final int player2Wrong;
  final int player2Blank;
  final bool isTransitionBarrierActive;
  final bool isLoading;
  final String? errorMessage;

  const QuizGameState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.activePlayer = PlayerId.player1,
    this.phase = GamePhase.waitingOwnAnswers,
    this.currentRound = const RoundAnswer(),
    this.activeReaction = CatReaction.idle,
    this.streak = 0,
    this.totalCorrectGuesses = 0,
    this.birdWhisperHintsAvailable = 0,
    this.activeHintRevealed,
    this.player1Score = 0,
    this.player1Wrong = 0,
    this.player1Blank = 0,
    this.player2Score = 0,
    this.player2Wrong = 0,
    this.player2Blank = 0,
    this.isTransitionBarrierActive = false,
    this.isLoading = false,
    this.errorMessage,
  });

  int get player1Correct => player1Score;
  int get player2Correct => player2Score;

  QuizQuestion? get currentQuestion =>
      (questions.isNotEmpty && currentQuestionIndex < questions.length)
          ? questions[currentQuestionIndex]
          : null;

  bool get isGameOver =>
      questions.isNotEmpty && currentQuestionIndex >= questions.length;

  int get totalQuestions => questions.length;

  QuizGameState copyWith({
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    PlayerId? activePlayer,
    GamePhase? phase,
    RoundAnswer? currentRound,
    CatReaction? activeReaction,
    int? streak,
    int? totalCorrectGuesses,
    int? birdWhisperHintsAvailable,
    String? activeHintRevealed,
    bool clearActiveHint = false,
    int? player1Score,
    int? player1Wrong,
    int? player1Blank,
    int? player2Score,
    int? player2Wrong,
    int? player2Blank,
    bool? isTransitionBarrierActive,
    bool? isLoading,
    String? errorMessage,
  }) {
    return QuizGameState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      activePlayer: activePlayer ?? this.activePlayer,
      phase: phase ?? this.phase,
      currentRound: currentRound ?? this.currentRound,
      activeReaction: activeReaction ?? this.activeReaction,
      streak: streak ?? this.streak,
      totalCorrectGuesses: totalCorrectGuesses ?? this.totalCorrectGuesses,
      birdWhisperHintsAvailable:
          birdWhisperHintsAvailable ?? this.birdWhisperHintsAvailable,
      activeHintRevealed: clearActiveHint
          ? null
          : (activeHintRevealed ?? this.activeHintRevealed),
      player1Score: player1Score ?? this.player1Score,
      player1Wrong: player1Wrong ?? this.player1Wrong,
      player1Blank: player1Blank ?? this.player1Blank,
      player2Score: player2Score ?? this.player2Score,
      player2Wrong: player2Wrong ?? this.player2Wrong,
      player2Blank: player2Blank ?? this.player2Blank,
      isTransitionBarrierActive:
          isTransitionBarrierActive ?? this.isTransitionBarrierActive,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
