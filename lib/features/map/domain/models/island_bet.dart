/// Represents a romantic or fun bet placed between the couple for a specific island.
class IslandBet {
  final String player1Bet;
  final String player2Bet;
  final String? winnerPlayer; // 'player1' or 'player2'
  final String? winnerName;
  final bool isCompleted;

  const IslandBet({
    required this.player1Bet,
    required this.player2Bet,
    this.winnerPlayer,
    this.winnerName,
    this.isCompleted = false,
  });

  IslandBet copyWith({
    String? player1Bet,
    String? player2Bet,
    String? winnerPlayer,
    String? winnerName,
    bool? isCompleted,
  }) {
    return IslandBet(
      player1Bet: player1Bet ?? this.player1Bet,
      player2Bet: player2Bet ?? this.player2Bet,
      winnerPlayer: winnerPlayer ?? this.winnerPlayer,
      winnerName: winnerName ?? this.winnerName,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'player1Bet': player1Bet,
      'player2Bet': player2Bet,
      'winnerPlayer': winnerPlayer,
      'winnerName': winnerName,
      'isCompleted': isCompleted,
    };
  }

  factory IslandBet.fromMap(Map<String, dynamic> map) {
    return IslandBet(
      player1Bet: map['player1Bet'] as String? ?? '',
      player2Bet: map['player2Bet'] as String? ?? '',
      winnerPlayer: map['winnerPlayer'] as String?,
      winnerName: map['winnerName'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}
