import 'package:flutter/material.dart';
import 'models/fire_water_models.dart';

/// Level builder defining platforms, hazards, buttons, barriers, gems, and doors.
/// Virtual coordinate space: 400x400 square.
class FireWaterLevelBuilder {
  static FireWaterGameState buildLevel1() {
    // 1. Boundary & Solid Platforms
    final platforms = <FireWaterPlatform>[
      // Outer boundaries
      const FireWaterPlatform(rect: Rect.fromLTWH(0, 0, 16, 400)), // Left wall
      const FireWaterPlatform(rect: Rect.fromLTWH(384, 0, 16, 400)), // Right wall
      const FireWaterPlatform(rect: Rect.fromLTWH(0, 0, 400, 16)), // Ceiling

      // Ground segments
      const FireWaterPlatform(rect: Rect.fromLTWH(16, 376, 70, 24)),
      const FireWaterPlatform(rect: Rect.fromLTWH(146, 376, 50, 24)),
      const FireWaterPlatform(rect: Rect.fromLTWH(256, 376, 40, 24)),
      const FireWaterPlatform(rect: Rect.fromLTWH(346, 376, 38, 24)),

      // Tier 1 (Lower-mid)
      const FireWaterPlatform(rect: Rect.fromLTWH(16, 300, 110, 14)),
      const FireWaterPlatform(rect: Rect.fromLTWH(150, 280, 90, 14)),
      const FireWaterPlatform(rect: Rect.fromLTWH(270, 300, 114, 14)),

      // Tier 2 (Mid-high)
      const FireWaterPlatform(rect: Rect.fromLTWH(40, 205, 120, 14)),
      const FireWaterPlatform(rect: Rect.fromLTWH(190, 190, 100, 14)),
      const FireWaterPlatform(rect: Rect.fromLTWH(310, 205, 74, 14)),

      // Tier 3 (Top floor with doors)
      const FireWaterPlatform(rect: Rect.fromLTWH(16, 110, 154, 14)),
      const FireWaterPlatform(rect: Rect.fromLTWH(230, 110, 154, 14)),
    ];

    // 2. Liquid Pools / Hazards
    final hazards = <FireWaterHazard>[
      // Ground Lava (Ateş passes, Su dies)
      const FireWaterHazard(
        rect: Rect.fromLTWH(86, 382, 60, 18),
        type: HazardType.fire,
      ),
      // Ground Water (Su passes, Ateş dies)
      const FireWaterHazard(
        rect: Rect.fromLTWH(196, 382, 60, 18),
        type: HazardType.water,
      ),
      // Ground Green Acid (Both die)
      const FireWaterHazard(
        rect: Rect.fromLTWH(296, 382, 50, 18),
        type: HazardType.acid,
      ),
      // Top bridge hazard (Water pool between top platforms)
      const FireWaterHazard(
        rect: Rect.fromLTWH(170, 112, 60, 12),
        type: HazardType.water,
      ),
    ];

    // 3. Gems
    final gems = <FireWaterGem>[
      // Fire (Red) Gems
      const FireWaterGem(center: Offset(116, 360), type: CharacterType.fire),
      const FireWaterGem(center: Offset(90, 180), type: CharacterType.fire),
      const FireWaterGem(center: Offset(260, 90), type: CharacterType.fire),

      // Water (Blue) Gems
      const FireWaterGem(center: Offset(226, 360), type: CharacterType.water),
      const FireWaterGem(center: Offset(240, 165), type: CharacterType.water),
      const FireWaterGem(center: Offset(130, 90), type: CharacterType.water),
    ];

    // 4. Buttons & Barriers
    final buttons = <FireWaterButton>[
      const FireWaterButton(
        rect: Rect.fromLTWH(60, 294, 28, 6),
        targetBarrierId: 'gate_1',
      ),
    ];

    final barriers = <FireWaterBarrier>[
      const FireWaterBarrier(
        id: 'gate_1',
        closedRect: Rect.fromLTWH(258, 220, 12, 60),
        openRect: Rect.fromLTWH(258, 220, 12, 6), // Retracted
        isOpen: false,
      ),
    ];

    // 5. Exit Doors
    final fireDoor = const FireWaterExitDoor(
      rect: Rect.fromLTWH(40, 62, 34, 48),
      type: CharacterType.fire,
    );

    final waterDoor = const FireWaterExitDoor(
      rect: Rect.fromLTWH(320, 62, 34, 48),
      type: CharacterType.water,
    );

    // 6. Players
    final firePlayer = const FireWaterPlayer(
      x: 30,
      y: 345,
      type: CharacterType.fire,
    );

    final waterPlayer = const FireWaterPlayer(
      x: 55,
      y: 345,
      type: CharacterType.water,
    );

    return FireWaterGameState(
      firePlayer: firePlayer,
      waterPlayer: waterPlayer,
      activeCharacter: CharacterType.fire,
      platforms: platforms,
      hazards: hazards,
      gems: gems,
      buttons: buttons,
      barriers: barriers,
      fireDoor: fireDoor,
      waterDoor: waterDoor,
    );
  }
}
