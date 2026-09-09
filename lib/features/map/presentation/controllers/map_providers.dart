import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/island_board.dart';
import '../../domain/models/island_bet.dart';
import '../../../../core/utils/haptic_utils.dart';

class MapState {
  final int currentIsland;
  final int maxUnlockedIsland;
  final int shipIsland;
  final int player1Position;
  final int player2Position;
  final int player1Steps;
  final int player2Steps;
  final bool isMoving;
  final bool isShipSailing;
  final bool hasReachedIslandGoal;
  final bool hasCompletedAll10Islands;
  final Set<int> completedIslands;
  final Map<int, int> islandP1Positions;
  final Map<int, int> islandP2Positions;
  final Map<int, IslandBet> islandBets;
  final Map<int, String> islandWinners; // islandNum -> winner nickname
  final String? winningPlayerName;
  final IslandBet? winningIslandBet;
  final String? lastActionMessage;

  const MapState({
    this.currentIsland = 1,
    this.maxUnlockedIsland = 1,
    this.shipIsland = 1,
    this.player1Position = 1,
    this.player2Position = 1,
    this.player1Steps = 3,
    this.player2Steps = 0,
    this.isMoving = false,
    this.isShipSailing = false,
    this.hasReachedIslandGoal = false,
    this.hasCompletedAll10Islands = false,
    this.completedIslands = const {},
    this.islandP1Positions = const {},
    this.islandP2Positions = const {},
    this.islandBets = const {},
    this.islandWinners = const {},
    this.winningPlayerName,
    this.winningIslandBet,
    this.lastActionMessage,
  });

  /// Legacy compatibility getter for Player 1 position
  int get playerPosition => player1Position;

  /// Legacy compatibility getter for total earned steps
  int get earnedSteps => player1Steps + player2Steps;

  /// Legacy compatibility getter for island positions
  Map<int, int> get islandPositions => islandP1Positions;

  MapState copyWith({
    int? currentIsland,
    int? maxUnlockedIsland,
    int? shipIsland,
    int? player1Position,
    int? player2Position,
    int? player1Steps,
    int? player2Steps,
    int? playerPosition, // Legacy support
    int? earnedSteps,    // Legacy support
    bool? isMoving,
    bool? isShipSailing,
    bool? hasReachedIslandGoal,
    bool? hasCompletedAll10Islands,
    Set<int>? completedIslands,
    Map<int, int>? islandP1Positions,
    Map<int, int>? islandP2Positions,
    Map<int, int>? islandPositions, // Legacy support
    Map<int, IslandBet>? islandBets,
    Map<int, String>? islandWinners,
    String? winningPlayerName,
    IslandBet? winningIslandBet,
    bool clearWinningDialog = false,
    String? lastActionMessage,
    bool clearActionMessage = false,
  }) {
    return MapState(
      currentIsland: currentIsland ?? this.currentIsland,
      maxUnlockedIsland: maxUnlockedIsland ?? this.maxUnlockedIsland,
      shipIsland: shipIsland ?? this.shipIsland,
      player1Position: playerPosition ?? (player1Position ?? this.player1Position),
      player2Position: player2Position ?? this.player2Position,
      player1Steps: player1Steps ?? (earnedSteps != null ? earnedSteps : this.player1Steps),
      player2Steps: player2Steps ?? (earnedSteps != null ? 0 : this.player2Steps),
      isMoving: isMoving ?? this.isMoving,
      isShipSailing: isShipSailing ?? this.isShipSailing,
      hasReachedIslandGoal: hasReachedIslandGoal ?? this.hasReachedIslandGoal,
      hasCompletedAll10Islands: hasCompletedAll10Islands ?? this.hasCompletedAll10Islands,
      completedIslands: completedIslands ?? this.completedIslands,
      islandP1Positions: islandPositions ?? (islandP1Positions ?? this.islandP1Positions),
      islandP2Positions: islandP2Positions ?? this.islandP2Positions,
      islandBets: islandBets ?? this.islandBets,
      islandWinners: islandWinners ?? this.islandWinners,
      winningPlayerName: clearWinningDialog ? null : (winningPlayerName ?? this.winningPlayerName),
      winningIslandBet: clearWinningDialog ? null : (winningIslandBet ?? this.winningIslandBet),
      lastActionMessage: clearActionMessage ? null : (lastActionMessage ?? this.lastActionMessage),
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  static const _islandKey = 'paws_map_island_v3';
  static const _maxUnlockedKey = 'paws_map_unlocked_v3';
  static const _shipKey = 'paws_map_ship_v3';
  static const _p1PosKey = 'paws_map_p1_pos_v3';
  static const _p2PosKey = 'paws_map_p2_pos_v3';
  static const _p1StepsKey = 'paws_map_p1_steps_v3';
  static const _p2StepsKey = 'paws_map_p2_steps_v3';
  static const _completedKey = 'paws_map_completed_v3';
  static const _winnersKey = 'paws_map_winners_v3';
  static const _betsKey = 'paws_map_bets_v3';

  Future<void>? loadFuture;

  MapNotifier() : super(const MapState()) {
    loadFuture = _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final island = prefs.getInt(_islandKey) ?? 1;
      final maxUnlocked = prefs.getInt(_maxUnlockedKey) ?? 1;
      final ship = prefs.getInt(_shipKey) ?? 1;
      final p1Pos = prefs.getInt(_p1PosKey) ?? 1;
      final p2Pos = prefs.getInt(_p2PosKey) ?? 1;
      final p1Steps = prefs.getInt(_p1StepsKey) ?? 3;
      final p2Steps = prefs.getInt(_p2StepsKey) ?? 0;

      final completedList = prefs.getStringList(_completedKey) ?? [];
      final completed = completedList.map((e) => int.tryParse(e) ?? 1).toSet();

      final winnersRaw = prefs.getString(_winnersKey);
      Map<int, String> winners = {};
      if (winnersRaw != null) {
        final decoded = jsonDecode(winnersRaw) as Map<String, dynamic>;
        winners = decoded.map((k, v) => MapEntry(int.tryParse(k) ?? 1, v.toString()));
      }

      final betsRaw = prefs.getString(_betsKey);
      Map<int, IslandBet> bets = {};
      if (betsRaw != null) {
        final decoded = jsonDecode(betsRaw) as Map<String, dynamic>;
        bets = decoded.map((k, v) => MapEntry(int.tryParse(k) ?? 1, IslandBet.fromMap(v as Map<String, dynamic>)));
      }

      state = state.copyWith(
        currentIsland: island.clamp(1, 10),
        maxUnlockedIsland: maxUnlocked.clamp(1, 10),
        shipIsland: ship.clamp(1, 10),
        player1Position: p1Pos.clamp(1, SnakesAndLaddersConfig.totalSquares),
        player2Position: p2Pos.clamp(1, SnakesAndLaddersConfig.totalSquares),
        player1Steps: p1Steps,
        player2Steps: p2Steps,
        completedIslands: completed,
        islandWinners: winners,
        islandBets: bets,
        hasReachedIslandGoal: p1Pos >= SnakesAndLaddersConfig.totalSquares || p2Pos >= SnakesAndLaddersConfig.totalSquares,
        hasCompletedAll10Islands: completed.contains(10) || (island >= 10 && (p1Pos >= SnakesAndLaddersConfig.totalSquares || p2Pos >= SnakesAndLaddersConfig.totalSquares)),
      );
    } catch (_) {}
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_islandKey, state.currentIsland);
      await prefs.setInt(_maxUnlockedKey, state.maxUnlockedIsland);
      await prefs.setInt(_shipKey, state.shipIsland);
      await prefs.setInt(_p1PosKey, state.player1Position);
      await prefs.setInt(_p2PosKey, state.player2Position);
      await prefs.setInt(_p1StepsKey, state.player1Steps);
      await prefs.setInt(_p2StepsKey, state.player2Steps);
      await prefs.setStringList(
        _completedKey,
        state.completedIslands.map((e) => e.toString()).toList(),
      );

      final winnersMap = state.islandWinners.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_winnersKey, jsonEncode(winnersMap));

      final betsMap = state.islandBets.map((k, v) => MapEntry(k.toString(), v.toMap()));
      await prefs.setString(_betsKey, jsonEncode(betsMap));
    } catch (_) {}
  }

  void saveIslandBet(int islandNum, IslandBet bet) {
    final updatedBets = Map<int, IslandBet>.from(state.islandBets);
    updatedBets[islandNum] = bet;
    state = state.copyWith(
      islandBets: updatedBets,
      lastActionMessage: '💌 $islandNum. Ada iddiası mühürlendi!',
    );
    _saveProgress();
  }

  void selectIsland(int islandNum) {
    if (islandNum < 1 || islandNum > 10) return;
    if (islandNum > state.maxUnlockedIsland) return;

    final p1Pos = state.islandP1Positions[islandNum] ?? (state.completedIslands.contains(islandNum) ? SnakesAndLaddersConfig.totalSquares : 1);
    final p2Pos = state.islandP2Positions[islandNum] ?? (state.completedIslands.contains(islandNum) ? SnakesAndLaddersConfig.totalSquares : 1);

    state = state.copyWith(
      currentIsland: islandNum,
      player1Position: p1Pos,
      player2Position: p2Pos,
      hasReachedIslandGoal: p1Pos >= SnakesAndLaddersConfig.totalSquares || p2Pos >= SnakesAndLaddersConfig.totalSquares,
    );
    _saveProgress();
  }

  void addPlayerSteps({required int player1Steps, required int player2Steps}) {
    state = state.copyWith(
      player1Steps: state.player1Steps + player1Steps,
      player2Steps: state.player2Steps + player2Steps,
      lastActionMessage: 'Quizden 1. Oyuncu +$player1Steps, 2. Oyuncu +$player2Steps adım kazandı! 🐾',
    );
    _saveProgress();
  }

  /// Legacy compatibility method
  void addStepsFromQuiz(int count) {
    if (count <= 0) return;
    state = state.copyWith(
      player1Steps: state.player1Steps + count,
      lastActionMessage: 'Quizden $count adım kazandınız! 🐾',
    );
    _saveProgress();
  }

  /// Move a specific player (1 or 2) by a single step
  Future<void> usePlayerStep(int playerNum, {String? player1Name, String? player2Name}) async {
    final isP1 = playerNum == 1;
    final currentSteps = isP1 ? state.player1Steps : state.player2Steps;
    final currentPos = isP1 ? state.player1Position : state.player2Position;
    final currentPName = isP1 ? (player1Name ?? '1. Oyuncu') : (player2Name ?? '2. Oyuncu');

    if (currentSteps <= 0 || state.isMoving || state.hasReachedIslandGoal) return;

    state = state.copyWith(
      isMoving: true,
      player1Steps: isP1 ? state.player1Steps - 1 : state.player1Steps,
      player2Steps: !isP1 ? state.player2Steps - 1 : state.player2Steps,
      clearActionMessage: true,
    );
    await HapticUtils.light();

    // Advance 1 step
    int nextPos = (currentPos + 1).clamp(1, SnakesAndLaddersConfig.totalSquares);
    final updatedP1Map = Map<int, int>.from(state.islandP1Positions);
    final updatedP2Map = Map<int, int>.from(state.islandP2Positions);

    if (isP1) {
      updatedP1Map[state.currentIsland] = nextPos;
      state = state.copyWith(player1Position: nextPos, islandP1Positions: updatedP1Map);
    } else {
      updatedP2Map[state.currentIsland] = nextPos;
      state = state.copyWith(player2Position: nextPos, islandP2Positions: updatedP2Map);
    }
    await Future.delayed(const Duration(milliseconds: 240));

    // Check if player reached goal square (Island Winner!)
    if (nextPos >= SnakesAndLaddersConfig.totalSquares) {
      final isFinalIsland = state.currentIsland >= 10;
      final updatedCompleted = Set<int>.from(state.completedIslands)..add(state.currentIsland);
      final nextMax = min(10, max(state.maxUnlockedIsland, state.currentIsland + 1));

      // Record Winner
      final updatedWinners = Map<int, String>.from(state.islandWinners);
      updatedWinners[state.currentIsland] = currentPName;

      // Update Island Bet if exists
      final currentBet = state.islandBets[state.currentIsland];
      final IslandBet? updatedBet = currentBet?.copyWith(
        winnerPlayer: isP1 ? 'player1' : 'player2',
        winnerName: currentPName,
        isCompleted: true,
      );
      final updatedBets = Map<int, IslandBet>.from(state.islandBets);
      if (updatedBet != null) {
        updatedBets[state.currentIsland] = updatedBet;
      }

      state = state.copyWith(
        hasReachedIslandGoal: true,
        completedIslands: updatedCompleted,
        maxUnlockedIsland: nextMax,
        hasCompletedAll10Islands: isFinalIsland,
        islandWinners: updatedWinners,
        islandBets: updatedBets,
        winningPlayerName: currentPName,
        winningIslandBet: updatedBet,
        isMoving: false,
        lastActionMessage: isFinalIsland
            ? '🏆 10. ADAYI $currentPName KAZANDI! BÜYÜK ŞAMPİYON!'
            : '🎉 $currentPName ${state.currentIsland}. Adayı kazandı ve iddiayı aldı! ⛵',
      );
      await HapticUtils.doubleSlap();
      _saveProgress();
      return;
    }

    // Check Ladder
    if (SnakesAndLaddersConfig.ladders.containsKey(nextPos)) {
      final ladderTop = SnakesAndLaddersConfig.ladders[nextPos]!;
      await Future.delayed(const Duration(milliseconds: 280));
      await HapticUtils.medium();

      if (isP1) {
        updatedP1Map[state.currentIsland] = ladderTop;
        state = state.copyWith(
          player1Position: ladderTop,
          islandP1Positions: updatedP1Map,
          lastActionMessage: '🪜 $currentPName Merdiven buldu! $nextPos -> $ladderTop karesine tırmandı!',
        );
      } else {
        updatedP2Map[state.currentIsland] = ladderTop;
        state = state.copyWith(
          player2Position: ladderTop,
          islandP2Positions: updatedP2Map,
          lastActionMessage: '🪜 $currentPName Merdiven buldu! $nextPos -> $ladderTop karesine tırmandı!',
        );
      }
    }
    // Check Snake
    else if (SnakesAndLaddersConfig.snakes.containsKey(nextPos)) {
      final snakeTail = SnakesAndLaddersConfig.snakes[nextPos]!;
      await Future.delayed(const Duration(milliseconds: 280));
      await HapticUtils.heavy();

      if (isP1) {
        updatedP1Map[state.currentIsland] = snakeTail;
        state = state.copyWith(
          player1Position: snakeTail,
          islandP1Positions: updatedP1Map,
          lastActionMessage: '🐍 Yılan soktu! $currentPName $nextPos -> $snakeTail karesine kaydı!',
        );
      } else {
        updatedP2Map[state.currentIsland] = snakeTail;
        state = state.copyWith(
          player2Position: snakeTail,
          islandP2Positions: updatedP2Map,
          lastActionMessage: '🐍 Yılan soktu! $currentPName $nextPos -> $snakeTail karesine kaydı!',
        );
      }
    }

    state = state.copyWith(isMoving: false);
    _saveProgress();
  }

  /// Legacy compatibility method
  Future<void> useSingleStep() async {
    if (state.player1Steps > 0) {
      await usePlayerStep(1);
    } else if (state.player2Steps > 0) {
      await usePlayerStep(2);
    }
  }

  void dismissWinningDialog() {
    state = state.copyWith(clearWinningDialog: true);
  }

  Future<void> sailToNextIsland() async {
    if (state.currentIsland >= 10) {
      state = state.copyWith(hasCompletedAll10Islands: true);
      return;
    }
    final nextIsland = state.currentIsland + 1;
    final nextMax = max(state.maxUnlockedIsland, nextIsland);
    final updatedCompleted = Set<int>.from(state.completedIslands)..add(state.currentIsland);

    state = state.copyWith(
      isShipSailing: true,
      completedIslands: updatedCompleted,
      maxUnlockedIsland: nextMax,
      clearWinningDialog: true,
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    state = state.copyWith(
      currentIsland: nextIsland,
      shipIsland: nextIsland,
      player1Position: 1,
      player2Position: 1,
      hasReachedIslandGoal: false,
      isShipSailing: false,
      lastActionMessage: '$nextIsland. Adaya ulaştınız! Hoş geldiniz! 🌴',
    );
    await HapticUtils.medium();
    _saveProgress();
  }

  void resetProgress() {
    state = const MapState(
      currentIsland: 1,
      maxUnlockedIsland: 1,
      shipIsland: 1,
      player1Position: 1,
      player2Position: 1,
      player1Steps: 3,
      player2Steps: 3,
      completedIslands: {},
      islandP1Positions: {},
      islandP2Positions: {},
      islandBets: {},
      islandWinners: {},
    );
    _saveProgress();
  }
}

final mapGameProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});

