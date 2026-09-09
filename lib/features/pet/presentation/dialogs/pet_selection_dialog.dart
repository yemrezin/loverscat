import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/pet_avatar.dart';
import '../controllers/pet_providers.dart';
import '../widgets/pet_display_widget.dart';

/// Modal dialog for choosing couple mascot pets and nicknames for both Player 1 and Player 2.
class PetSelectionDialog extends ConsumerStatefulWidget {
  const PetSelectionDialog({super.key});

  @override
  ConsumerState<PetSelectionDialog> createState() => _PetSelectionDialogState();
}

class _PetSelectionDialogState extends ConsumerState<PetSelectionDialog> {
  int _activePlayerTab = 1; // 1: Player 1, 2: Player 2

  late PetType _player1Type;
  late TextEditingController _player1NameController;

  late PetType _player2Type;
  late TextEditingController _player2NameController;

  @override
  void initState() {
    super.initState();
    final couple = ref.read(couplePlayersProvider);
    _player1Type = couple.player1.type;
    _player1NameController = TextEditingController(text: couple.player1.name);

    _player2Type = couple.player2.type;
    _player2NameController = TextEditingController(text: couple.player2.name);
  }

  @override
  void dispose() {
    _player1NameController.dispose();
    _player2NameController.dispose();
    super.dispose();
  }

  void _saveBothPlayers() {
    final p1Name = _player1NameController.text.trim();
    final finalP1Name = p1Name.isEmpty ? '1. Oyuncu' : p1Name;

    final p2Name = _player2NameController.text.trim();
    final finalP2Name = p2Name.isEmpty ? '2. Oyuncu' : p2Name;

    HapticUtils.medium();

    final updatedCouple = CouplePlayers(
      player1: PetAvatar(type: _player1Type, name: finalP1Name),
      player2: PetAvatar(type: _player2Type, name: finalP2Name),
    );

    ref.read(couplePlayersProvider.notifier).setPlayers(updatedCouple);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isPlayer1 = _activePlayerTab == 1;
    final currentType = isPlayer1 ? _player1Type : _player2Type;
    final currentController = isPlayer1 ? _player1NameController : _player2NameController;
    final currentAccent = isPlayer1 ? AppColors.player1Badge : AppColors.player2Badge;

    return Dialog(
      backgroundColor: AppColors.backgroundWarm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Çift Maskotları & Rumuzlar 🐾',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Player 1 / Player 2 Switcher Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.light();
                          setState(() => _activePlayerTab = 1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isPlayer1 ? AppColors.player1Badge : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_player1Type.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                '1. Oyuncu',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isPlayer1 ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.light();
                          setState(() => _activePlayerTab = 2);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !isPlayer1 ? AppColors.player2Badge : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_player2Type.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                '2. Oyuncu',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: !isPlayer1 ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Active Animated Preview
              Center(
                child: PetDisplayWidget(
                  petType: currentType,
                  size: 120,
                ),
              ),
              const SizedBox(height: 14),

              // 4 Animal Selectors Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: PetType.values.map((type) {
                  final isSelected = currentType == type;
                  return InkWell(
                    onTap: () {
                      HapticUtils.light();
                      setState(() {
                        if (isPlayer1) {
                          _player1Type = type;
                        } else {
                          _player2Type = type;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? currentAccent.withOpacity(0.18) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? currentAccent : AppColors.borderSubtle,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PetHeadAvatarWidget(
                            petType: type,
                            size: 36,
                            borderColor: isSelected ? currentAccent : Colors.grey.shade300,
                            borderWidth: isSelected ? 2.0 : 1.0,
                            showShadow: isSelected,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            type.displayName.split(' ')[0],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? currentAccent : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Player Nickname TextField
              TextField(
                controller: currentController,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: '${isPlayer1 ? "1." : "2."} Oyuncu Rumuzu / İsmi',
                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  hintText: isPlayer1 ? 'Örn: Mırmır, Yunus...' : 'Örn: Pamuk, Ayşe...',
                  prefixIcon: Icon(Icons.favorite_rounded, color: currentAccent, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveBothPlayers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.player1Badge,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Seçimleri Kaydet ✨',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
