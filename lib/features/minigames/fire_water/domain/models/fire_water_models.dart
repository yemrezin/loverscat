import 'package:flutter/material.dart';

enum CharacterType {
  fire,
  water,
}

enum HazardType {
  fire,
  water,
  acid,
}

class FireWaterPlayer {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double width;
  final double height;
  final bool isGrounded;
  final bool isAlive;
  final CharacterType type;
  final bool inExitDoor;

  const FireWaterPlayer({
    required this.x,
    required this.y,
    this.vx = 0.0,
    this.vy = 0.0,
    this.width = 24.0,
    this.height = 28.0,
    this.isGrounded = false,
    this.isAlive = true,
    required this.type,
    this.inExitDoor = false,
  });

  Rect get rect => Rect.fromLTWH(x, y, width, height);

  FireWaterPlayer copyWith({
    double? x,
    double? y,
    double? vx,
    double? vy,
    double? width,
    double? height,
    bool? isGrounded,
    bool? isAlive,
    CharacterType? type,
    bool? inExitDoor,
  }) {
    return FireWaterPlayer(
      x: x ?? this.x,
      y: y ?? this.y,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      width: width ?? this.width,
      height: height ?? this.height,
      isGrounded: isGrounded ?? this.isGrounded,
      isAlive: isAlive ?? this.isAlive,
      type: type ?? this.type,
      inExitDoor: inExitDoor ?? this.inExitDoor,
    );
  }
}

class FireWaterPlatform {
  final Rect rect;
  final Color color;

  const FireWaterPlatform({
    required this.rect,
    this.color = const Color(0xFF4A4453),
  });
}

class FireWaterHazard {
  final Rect rect;
  final HazardType type;

  const FireWaterHazard({
    required this.rect,
    required this.type,
  });
}

class FireWaterGem {
  final Offset center;
  final CharacterType type;
  final bool isCollected;

  const FireWaterGem({
    required this.center,
    required this.type,
    this.isCollected = false,
  });

  FireWaterGem copyWith({bool? isCollected}) {
    return FireWaterGem(
      center: center,
      type: type,
      isCollected: isCollected ?? this.isCollected,
    );
  }
}

class FireWaterButton {
  final Rect rect;
  final String targetBarrierId;
  final bool isPressed;

  const FireWaterButton({
    required this.rect,
    required this.targetBarrierId,
    this.isPressed = false,
  });

  FireWaterButton copyWith({bool? isPressed}) {
    return FireWaterButton(
      rect: rect,
      targetBarrierId: targetBarrierId,
      isPressed: isPressed ?? this.isPressed,
    );
  }
}

class FireWaterBarrier {
  final String id;
  final Rect closedRect;
  final Rect openRect;
  final bool isOpen;

  const FireWaterBarrier({
    required this.id,
    required this.closedRect,
    required this.openRect,
    this.isOpen = false,
  });

  Rect get currentRect => isOpen ? openRect : closedRect;

  FireWaterBarrier copyWith({bool? isOpen}) {
    return FireWaterBarrier(
      id: id,
      closedRect: closedRect,
      openRect: openRect,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

class FireWaterExitDoor {
  final Rect rect;
  final CharacterType type;
  final bool isReached;

  const FireWaterExitDoor({
    required this.rect,
    required this.type,
    this.isReached = false,
  });

  FireWaterExitDoor copyWith({bool? isReached}) {
    return FireWaterExitDoor(
      rect: rect,
      type: type,
      isReached: isReached ?? this.isReached,
    );
  }
}

class FireWaterGameState {
  final FireWaterPlayer firePlayer;
  final FireWaterPlayer waterPlayer;
  final CharacterType activeCharacter;
  final List<FireWaterPlatform> platforms;
  final List<FireWaterHazard> hazards;
  final List<FireWaterGem> gems;
  final List<FireWaterButton> buttons;
  final List<FireWaterBarrier> barriers;
  final FireWaterExitDoor fireDoor;
  final FireWaterExitDoor waterDoor;
  final bool isCompleted;
  final bool isGameOver;
  final String? statusMessage;

  const FireWaterGameState({
    required this.firePlayer,
    required this.waterPlayer,
    this.activeCharacter = CharacterType.fire,
    this.platforms = const [],
    this.hazards = const [],
    this.gems = const [],
    this.buttons = const [],
    this.barriers = const [],
    required this.fireDoor,
    required this.waterDoor,
    this.isCompleted = false,
    this.isGameOver = false,
    this.statusMessage,
  });

  int get collectedGemsCount => gems.where((g) => g.isCollected).length;
  int get totalGemsCount => gems.length;

  FireWaterGameState copyWith({
    FireWaterPlayer? firePlayer,
    FireWaterPlayer? waterPlayer,
    CharacterType? activeCharacter,
    List<FireWaterPlatform>? platforms,
    List<FireWaterHazard>? hazards,
    List<FireWaterGem>? gems,
    List<FireWaterButton>? buttons,
    List<FireWaterBarrier>? barriers,
    FireWaterExitDoor? fireDoor,
    FireWaterExitDoor? waterDoor,
    bool? isCompleted,
    bool? isGameOver,
    String? statusMessage,
    bool clearStatus = false,
  }) {
    return FireWaterGameState(
      firePlayer: firePlayer ?? this.firePlayer,
      waterPlayer: waterPlayer ?? this.waterPlayer,
      activeCharacter: activeCharacter ?? this.activeCharacter,
      platforms: platforms ?? this.platforms,
      hazards: hazards ?? this.hazards,
      gems: gems ?? this.gems,
      buttons: buttons ?? this.buttons,
      barriers: barriers ?? this.barriers,
      fireDoor: fireDoor ?? this.fireDoor,
      waterDoor: waterDoor ?? this.waterDoor,
      isCompleted: isCompleted ?? this.isCompleted,
      isGameOver: isGameOver ?? this.isGameOver,
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
    );
  }
}
