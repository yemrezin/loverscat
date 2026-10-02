import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/fire_water_level_builder.dart';
import '../../domain/models/fire_water_models.dart';

class FireWaterController extends StateNotifier<FireWaterGameState> {
  Timer? _ticker;
  bool _isMovingLeft = false;
  bool _isMovingRight = false;

  static const double gravity = 0.55;
  static const double maxFallSpeed = 9.5;
  static const double moveSpeed = 3.4;
  static const double jumpVelocity = -8.8;

  FireWaterController() : super(FireWaterLevelBuilder.buildLevel1()) {
    _startLoop();
  }

  @override
  void dispose() {
    _stopLoop();
    super.dispose();
  }

  void _startLoop() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _tick();
    });
  }

  void _stopLoop() {
    _ticker?.cancel();
    _ticker = null;
  }

  void resetLevel() {
    _isMovingLeft = false;
    _isMovingRight = false;
    state = FireWaterLevelBuilder.buildLevel1();
    _startLoop();
  }

  void switchCharacter() {
    final nextType = state.activeCharacter == CharacterType.fire
        ? CharacterType.water
        : CharacterType.fire;
    _isMovingLeft = false;
    _isMovingRight = false;
    state = state.copyWith(activeCharacter: nextType);
  }

  void selectCharacter(CharacterType type) {
    if (state.activeCharacter != type) {
      _isMovingLeft = false;
      _isMovingRight = false;
      state = state.copyWith(activeCharacter: type);
    }
  }

  void moveLeft(bool active) {
    _isMovingLeft = active;
  }

  void moveRight(bool active) {
    _isMovingRight = active;
  }

  void jump() {
    if (state.isGameOver || state.isCompleted) return;

    final isFire = state.activeCharacter == CharacterType.fire;
    final player = isFire ? state.firePlayer : state.waterPlayer;

    if (player.isGrounded) {
      final updatedPlayer = player.copyWith(vy: jumpVelocity, isGrounded: false);
      state = isFire
          ? state.copyWith(firePlayer: updatedPlayer)
          : state.copyWith(waterPlayer: updatedPlayer);
    }
  }

  void _tick() {
    if (state.isGameOver || state.isCompleted) return;

    // 1. Calculate active player horizontal intent
    double targetVx = 0.0;
    if (_isMovingLeft && !_isMovingRight) {
      targetVx = -moveSpeed;
    } else if (_isMovingRight && !_isMovingLeft) {
      targetVx = moveSpeed;
    }

    // Update active player's vx
    FireWaterPlayer fire = state.firePlayer;
    FireWaterPlayer water = state.waterPlayer;

    if (state.activeCharacter == CharacterType.fire) {
      fire = fire.copyWith(vx: targetVx);
    } else {
      water = water.copyWith(vx: targetVx);
    }

    // 2. Physics & collisions for both players
    final solidRects = <Rect>[
      for (final p in state.platforms) p.rect,
      for (final b in state.barriers)
        if (!b.isOpen) b.currentRect,
    ];

    fire = _updatePlayerPhysics(fire, solidRects);
    water = _updatePlayerPhysics(water, solidRects);

    // 3. Hazard checks
    String? deathReason;
    bool isGameOver = false;

    for (final h in state.hazards) {
      if (fire.rect.overlaps(h.rect)) {
        if (h.type == HazardType.water || h.type == HazardType.acid) {
          deathReason = '🔥 Ateş suya veya aside düştü!';
          isGameOver = true;
          break;
        }
      }
      if (water.rect.overlaps(h.rect)) {
        if (h.type == HazardType.fire || h.type == HazardType.acid) {
          deathReason = '💧 Su lav veya aside düştü!';
          isGameOver = true;
          break;
        }
      }
    }

    if (fire.y > 420 || water.y > 420) {
      deathReason = 'Düşüş gerçekleşti!';
      isGameOver = true;
    }

    // 4. Buttons & Barriers
    final updatedButtons = <FireWaterButton>[];
    final activePressedBarriers = <String>{};

    for (final btn in state.buttons) {
      final isPressed = fire.rect.overlaps(btn.rect) || water.rect.overlaps(btn.rect);
      updatedButtons.add(btn.copyWith(isPressed: isPressed));
      if (isPressed) {
        activePressedBarriers.add(btn.targetBarrierId);
      }
    }

    final updatedBarriers = state.barriers.map((b) {
      final shouldBeOpen = activePressedBarriers.contains(b.id);
      return b.copyWith(isOpen: shouldBeOpen);
    }).toList();

    // 5. Gem Collection
    final updatedGems = state.gems.map((g) {
      if (g.isCollected) return g;
      final hitFire = g.type == CharacterType.fire && fire.rect.contains(g.center);
      final hitWater = g.type == CharacterType.water && water.rect.contains(g.center);
      if (hitFire || hitWater) {
        return g.copyWith(isCollected: true);
      }
      return g;
    }).toList();

    // 6. Exit Door Check
    final inFireDoor = fire.rect.overlaps(state.fireDoor.rect);
    final inWaterDoor = water.rect.overlaps(state.waterDoor.rect);

    final updatedFireDoor = state.fireDoor.copyWith(isReached: inFireDoor);
    final updatedWaterDoor = state.waterDoor.copyWith(isReached: inWaterDoor);

    fire = fire.copyWith(inExitDoor: inFireDoor);
    water = water.copyWith(inExitDoor: inWaterDoor);

    final isVictory = inFireDoor && inWaterDoor;

    state = state.copyWith(
      firePlayer: fire,
      waterPlayer: water,
      buttons: updatedButtons,
      barriers: updatedBarriers,
      gems: updatedGems,
      fireDoor: updatedFireDoor,
      waterDoor: updatedWaterDoor,
      isGameOver: isGameOver,
      isCompleted: isVictory,
      statusMessage: deathReason,
    );

    if (isGameOver || isVictory) {
      _stopLoop();
    }
  }

  FireWaterPlayer _updatePlayerPhysics(FireWaterPlayer p, List<Rect> solids) {
    double newX = p.x;
    double newY = p.y;
    double newVx = p.vx;
    double newVy = p.vy + gravity;
    if (newVy > maxFallSpeed) newVy = maxFallSpeed;

    // Horizontal pass
    newX += newVx;
    Rect xRect = Rect.fromLTWH(newX, p.y, p.width, p.height);
    for (final s in solids) {
      if (xRect.overlaps(s)) {
        if (newVx > 0) {
          newX = s.left - p.width;
        } else if (newVx < 0) {
          newX = s.right;
        }
        newVx = 0.0;
        xRect = Rect.fromLTWH(newX, p.y, p.width, p.height);
      }
    }

    // Vertical pass
    newY += newVy;
    bool grounded = false;
    Rect yRect = Rect.fromLTWH(newX, newY, p.width, p.height);
    for (final s in solids) {
      if (yRect.overlaps(s)) {
        if (newVy > 0) {
          newY = s.top - p.height;
          grounded = true;
          newVy = 0.0;
        } else if (newVy < 0) {
          newY = s.bottom;
          newVy = 0.0;
        }
        yRect = Rect.fromLTWH(newX, newY, p.width, p.height);
      }
    }

    return p.copyWith(
      x: newX,
      y: newY,
      vx: newVx,
      vy: newVy,
      isGrounded: grounded,
    );
  }
}

final fireWaterProvider =
    StateNotifierProvider.autoDispose<FireWaterController, FireWaterGameState>((ref) {
  return FireWaterController();
});
