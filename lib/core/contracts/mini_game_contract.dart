import 'package:flutter/material.dart';

/// Game play types across the 10 islands.
enum MiniGameMode {
  /// 1v1 friendly competitive duel
  competitive1v1,

  /// Pure co-op collaboration where players share controls or goals
  cooperative,

  /// Turn-based or sequential matching
  sequential,

  /// Mixed / dynamic role switching
  mixed,
}

/// The 10 canonical mini-games corresponding to each island in "Aşkın Uçan Rotası".
enum MiniGameId {
  shellsCoveBallDrop(1, 'Üstten Top Atma', MiniGameMode.competitive1v1),
  syrupWoodsArchery(2, 'Okçuluk Düellosu', MiniGameMode.competitive1v1),
  baratieAirHockey(3, 'Air Hokeyi', MiniGameMode.competitive1v1),
  arlongHotPotato(4, 'Bomba Paslamaca', MiniGameMode.mixed),
  drumMemoryMatch(5, 'Hafıza Oyunu', MiniGameMode.sequential),
  alabastaHideAndSeek(6, 'Labirentte Saklambaç', MiniGameMode.competitive1v1),
  skypieaElementalRun(7, 'Ateş ve Su', MiniGameMode.cooperative),
  waterSevenLaserMirror(8, 'Lazer & Ayna', MiniGameMode.cooperative),
  sabaodyMinecart(9, 'Raylı Maden Arabası', MiniGameMode.cooperative),
  wanoLavaEscape(10, 'Lavdan Kaçış (BÜYÜK FİNAL)', MiniGameMode.cooperative);

  final int islandNumber;
  final String title;
  final MiniGameMode mode;

  const MiniGameId(this.islandNumber, this.title, this.mode);
}

/// Interface Segregation Principle (ISP): Frame-by-frame update capability.
abstract interface class ITickable {
  void onUpdate(double dt);
}

/// Interface Segregation Principle (ISP): Touch and drag input handling.
abstract interface class ITouchInputHandler {
  void onTouchDown(Offset position, int pointerId);
  void onTouchMove(Offset position, int pointerId);
  void onTouchUp(Offset position, int pointerId);
}

/// Interface Segregation Principle (ISP): Hardware-accelerated physics and collision contract.
abstract interface class IPhysicsOptimized {
  void resetPhysicsPool();
  void stepPhysics(double dt);
}

/// Metadata and story payload associated with an island mini-game.
class MiniGameMetadata {
  final MiniGameId id;
  final String islandName;
  final String description;
  final String controlGuide;
  final String droppedChildItemName;
  final String droppedChildItemIcon;
  final String storyClue;
  final bool isReadyForPlay;

  const MiniGameMetadata({
    required this.id,
    required this.islandName,
    required this.description,
    required this.controlGuide,
    required this.droppedChildItemName,
    required this.droppedChildItemIcon,
    required this.storyClue,
    this.isReadyForPlay = false,
  });
}

/// Result payload emitted upon mini-game completion.
class MiniGameResult {
  final MiniGameId gameId;
  final bool wasCompleted;
  final String? winnerPlayerName;
  final int player1Score;
  final int player2Score;
  final Duration duration;
  final bool itemRecovered;
  final String summaryMessage;

  const MiniGameResult({
    required this.gameId,
    required this.wasCompleted,
    this.winnerPlayerName,
    this.player1Score = 0,
    this.player2Score = 0,
    this.duration = Duration.zero,
    this.itemRecovered = true,
    required this.summaryMessage,
  });
}

/// Open/Closed & Liskov Substitution Principle: Base contract for all mini-game controllers.
abstract class MiniGameBaseController implements ITickable {
  final MiniGameMetadata metadata;
  bool isPaused = false;
  bool isDisposed = false;

  MiniGameBaseController(this.metadata);

  /// Initializes game assets, memory pools, and physics parameters.
  Future<void> initialize();

  /// Pauses game loop ticker.
  void pause() => isPaused = true;

  /// Resumes game loop ticker.
  void resume() => isPaused = false;

  /// Cleans up tickers, subscriptions, and allocations.
  void dispose() => isDisposed = true;
}
