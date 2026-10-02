/// Active turn player in Pass-and-Play mode.
enum PlayerId {
  player1,
  player2;

  String get displayName => this == PlayerId.player1 ? 'Oyuncu 1 🌸' : 'Oyuncu 2 🌿';
  PlayerId get other => this == PlayerId.player1 ? PlayerId.player2 : PlayerId.player1;
}

/// The 3 core steps defined in the game state machine.
enum GamePhase {
  /// Step 1: "Kendini Anlat" - Both players enter and seal their own answers.
  waitingOwnAnswers,

  /// Step 2: "Zihin Okuma" - Both players guess the other partner's sealed answer.
  waitingGuesses,

  /// Step 3: "Kedi Yargısı" - Answers revealed, Cat Judge reacts, score calculated.
  revealed,
}

/// Stores the inputs for a single round.
class RoundAnswer {
  final String? player1OwnAnswer;
  final String? player2OwnAnswer;
  final String? player1Guess;
  final String? player2Guess;
  final bool? p1GuessJudgedCorrect;
  final bool? p2GuessJudgedCorrect;

  const RoundAnswer({
    this.player1OwnAnswer,
    this.player2OwnAnswer,
    this.player1Guess,
    this.player2Guess,
    this.p1GuessJudgedCorrect,
    this.p2GuessJudgedCorrect,
  });

  bool get isPlayer1Sealed => (player1OwnAnswer?.trim().isNotEmpty ?? false);
  bool get isPlayer2Sealed => (player2OwnAnswer?.trim().isNotEmpty ?? false);
  bool get areBothSealed => isPlayer1Sealed && isPlayer2Sealed;

  bool get isPlayer1Guessed => (player1Guess?.trim().isNotEmpty ?? false);
  bool get isPlayer2Guessed => (player2Guess?.trim().isNotEmpty ?? false);
  bool get areBothGuessesMade => isPlayer1Guessed && isPlayer2Guessed;

  bool get isP1Judged => p1GuessJudgedCorrect != null;
  bool get isP2Judged => p2GuessJudgedCorrect != null;
  bool get areBothJudged => isP1Judged && isP2Judged;

  /// Compares answers with trim and case-insensitivity.
  static bool areMatching(String? a, String? b) {
    if (a == null || b == null) return false;
    final cleanA = a.trim().toLowerCase();
    final cleanB = b.trim().toLowerCase();
    return cleanA.isNotEmpty && cleanA == cleanB;
  }

  /// Did Player 1 correctly guess Player 2's sealed answer?
  /// For open-ended questions, manual judgment takes precedence.
  bool get isP1GuessCorrect => p1GuessJudgedCorrect ?? areMatching(player1Guess, player2OwnAnswer);

  /// Did Player 2 correctly guess Player 1's sealed answer?
  /// For open-ended questions, manual judgment takes precedence.
  bool get isP2GuessCorrect => p2GuessJudgedCorrect ?? areMatching(player2Guess, player1OwnAnswer);

  RoundAnswer copyWith({
    String? player1OwnAnswer,
    String? player2OwnAnswer,
    String? player1Guess,
    String? player2Guess,
    bool? p1GuessJudgedCorrect,
    bool? p2GuessJudgedCorrect,
  }) {
    return RoundAnswer(
      player1OwnAnswer: player1OwnAnswer ?? this.player1OwnAnswer,
      player2OwnAnswer: player2OwnAnswer ?? this.player2OwnAnswer,
      player1Guess: player1Guess ?? this.player1Guess,
      player2Guess: player2Guess ?? this.player2Guess,
      p1GuessJudgedCorrect: p1GuessJudgedCorrect ?? this.p1GuessJudgedCorrect,
      p2GuessJudgedCorrect: p2GuessJudgedCorrect ?? this.p2GuessJudgedCorrect,
    );
  }

  RoundAnswer clear() {
    return const RoundAnswer();
  }
}
