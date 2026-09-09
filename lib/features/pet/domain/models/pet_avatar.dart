import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum PetType {
  cat,
  rabbit,
  fox,
  cheese;

  String get displayName {
    switch (this) {
      case PetType.cat:
        return 'Kedi 🐱';
      case PetType.rabbit:
        return 'Tavşan 🐰';
      case PetType.fox:
        return 'Tilki 🦊';
      case PetType.cheese:
        return 'Peynir 🧀';
    }
  }

  String get emoji {
    switch (this) {
      case PetType.cat:
        return '🐱';
      case PetType.rabbit:
        return '🐰';
      case PetType.fox:
        return '🦊';
      case PetType.cheese:
        return '🧀';
    }
  }

  Color get primaryColor {
    switch (this) {
      case PetType.cat:
        return AppColors.catBody;
      case PetType.rabbit:
        return const Color(0xFFF7D6E0); // Soft pastel baby pink
      case PetType.fox:
        return const Color(0xFFF27059); // Warm fox terracotta
      case PetType.cheese:
        return const Color(0xFFFFB703); // Warm golden cheese yellow
    }
  }

  String get fullAssetPath {
    switch (this) {
      case PetType.cat:
        return 'assets/images/pet_cat.png';
      case PetType.rabbit:
        return 'assets/images/pet_rabbit.png';
      case PetType.fox:
        return 'assets/images/pet_fox.png';
      case PetType.cheese:
        return 'assets/images/pet_cheese.png';
    }
  }

  String get headAssetPath {
    switch (this) {
      case PetType.cat:
        return 'assets/images/head_cat.png';
      case PetType.rabbit:
        return 'assets/images/head_rabbit.png';
      case PetType.fox:
        return 'assets/images/head_fox.png';
      case PetType.cheese:
        return 'assets/images/head_cheese.png';
    }
  }
}

class PetAvatar {
  final PetType type;
  final String name;

  const PetAvatar({
    required this.type,
    required this.name,
  });

  static const PetAvatar defaultPet = PetAvatar(
    type: PetType.cat,
    name: 'Mırmır',
  );

  PetAvatar copyWith({
    PetType? type,
    String? name,
  }) {
    return PetAvatar(
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'name': name,
    };
  }

  factory PetAvatar.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String?;
    if (typeStr == 'penguin') {
      return PetAvatar(
        type: PetType.cheese,
        name: map['name'] as String? ?? 'Peynirci',
      );
    }
    return PetAvatar(
      type: PetType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => PetType.cat,
      ),
      name: map['name'] as String? ?? 'Mırmır',
    );
  }
}

class CouplePlayers {
  final PetAvatar player1;
  final PetAvatar player2;

  const CouplePlayers({
    required this.player1,
    required this.player2,
  });

  static const CouplePlayers defaultPlayers = CouplePlayers(
    player1: PetAvatar(type: PetType.cat, name: '1. Oyuncu'),
    player2: PetAvatar(type: PetType.rabbit, name: '2. Oyuncu'),
  );

  CouplePlayers copyWith({
    PetAvatar? player1,
    PetAvatar? player2,
  }) {
    return CouplePlayers(
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'player1': player1.toMap(),
      'player2': player2.toMap(),
    };
  }

  factory CouplePlayers.fromMap(Map<String, dynamic> map) {
    return CouplePlayers(
      player1: map['player1'] != null
          ? PetAvatar.fromMap(map['player1'] as Map<String, dynamic>)
          : defaultPlayers.player1,
      player2: map['player2'] != null
          ? PetAvatar.fromMap(map['player2'] as Map<String, dynamic>)
          : defaultPlayers.player2,
    );
  }
}
