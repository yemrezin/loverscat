import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/pet_avatar.dart';

class CouplePlayersNotifier extends StateNotifier<CouplePlayers> {
  static const _coupleKey = 'paws_couple_players_v1';

  CouplePlayersNotifier() : super(CouplePlayers.defaultPlayers) {
    _loadCouple();
  }

  Future<void> _loadCouple() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_coupleKey);
      if (savedStr != null) {
        final map = jsonDecode(savedStr) as Map<String, dynamic>;
        state = CouplePlayers.fromMap(map);
      }
    } catch (_) {}
  }

  Future<void> setPlayers(CouplePlayers players) async {
    state = players;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_coupleKey, jsonEncode(players.toMap()));
    } catch (_) {}
  }

  Future<void> updatePlayer1(PetAvatar avatar) async {
    setPlayers(state.copyWith(player1: avatar));
  }

  Future<void> updatePlayer2(PetAvatar avatar) async {
    setPlayers(state.copyWith(player2: avatar));
  }
}

final couplePlayersProvider =
    StateNotifierProvider<CouplePlayersNotifier, CouplePlayers>((ref) {
  return CouplePlayersNotifier();
});

/// Legacy compatibility PetNotifier for tests and single-pet usage
class PetNotifier extends StateNotifier<PetAvatar> {
  static const _key = 'paws_active_pet_v1';

  PetNotifier() : super(PetAvatar.defaultPet) {
    _loadPet();
  }

  Future<void> _loadPet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_key);
      if (savedStr != null) {
        final map = jsonDecode(savedStr) as Map<String, dynamic>;
        state = PetAvatar.fromMap(map);
      }
    } catch (_) {}
  }

  Future<void> setPet(PetAvatar pet) async {
    state = pet;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(pet.toMap()));
    } catch (_) {}
  }
}

final petNotifierProvider = StateNotifierProvider<PetNotifier, PetAvatar>((ref) {
  return PetNotifier();
});

/// Legacy compatibility provider pointing to Player 1's pet avatar
final activePetProvider = Provider<PetAvatar>((ref) {
  return ref.watch(couplePlayersProvider).player1;
});

