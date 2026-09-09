import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../pet/domain/models/pet_avatar.dart';
import '../../domain/models/island_bet.dart';

/// Cute and romantic Bet / Promise modal for couples entering an island.
class IslandBetDialog extends StatefulWidget {
  final int islandNumber;
  final String islandTitle;
  final IslandBet? initialBet;
  final PetAvatar player1;
  final PetAvatar player2;
  final ValueChanged<IslandBet> onSave;

  const IslandBetDialog({
    super.key,
    required this.islandNumber,
    required this.islandTitle,
    this.initialBet,
    required this.player1,
    required this.player2,
    required this.onSave,
  });

  @override
  State<IslandBetDialog> createState() => _IslandBetDialogState();
}

class _IslandBetDialogState extends State<IslandBetDialog> {
  late final TextEditingController _p1Controller;
  late final TextEditingController _p2Controller;

  static const List<String> _presetWishes = [
    '☕ Kahvaltı hazırla',
    '🍕 Akşam yemeği ısmarla',
    '💆 15 dk Masaj yap',
    '🎬 Film/Dizi seçimi',
    '🍨 Tatlı ısmarla',
    '🧺 Bulaşıkları yıka',
  ];

  @override
  void initState() {
    super.initState();
    _p1Controller = TextEditingController(text: widget.initialBet?.player1Bet ?? '');
    _p2Controller = TextEditingController(text: widget.initialBet?.player2Bet ?? '');
  }

  @override
  void dispose() {
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  void _save() {
    HapticUtils.medium();
    final bet = IslandBet(
      player1Bet: _p1Controller.text.trim(),
      player2Bet: _p2Controller.text.trim(),
      winnerPlayer: widget.initialBet?.winnerPlayer,
      winnerName: widget.initialBet?.winnerName,
      isCompleted: widget.initialBet?.isCompleted ?? false,
    );
    widget.onSave(bet);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundWarm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Note Ribbon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.pastelPink,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.player1Badge, width: 1.5),
                    ),
                    child: const Text('💌', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.islandNumber}. Ada Aşk İddiası',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.islandTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.player1Badge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Text(
                  'Bu adayı son kareye (48. kare) ulaşıp ilk kazanan sevgilinin dileği gerçek olacak! Karşı tarafın yapmasını istediğiniz şeyi yazın. ✨',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Player 1 Bet Card
              _buildPlayerBetSection(
                player: widget.player1,
                controller: _p1Controller,
                accentColor: AppColors.player1Badge,
                label: '1. Oyuncu',
              ),
              const SizedBox(height: 16),

              // Player 2 Bet Card
              _buildPlayerBetSection(
                player: widget.player2,
                controller: _p2Controller,
                accentColor: AppColors.player2Badge,
                label: '2. Oyuncu',
              ),
              const SizedBox(height: 20),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Text('💖', style: TextStyle(fontSize: 18)),
                label: const Text(
                  'İddiayı Mühürle & Başla!',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.player1Badge,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Şimdilik Geç / Sonra Belirle',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerBetSection({
    required PetAvatar player,
    required TextEditingController controller,
    required Color accentColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: accentColor.withOpacity(0.2),
                child: Text(player.type.emoji, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Text(
                '${player.name} ($label)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: accentColor,
                ),
              ),
              const Spacer(),
              const Text('Kazanırsa İsteği 🎯', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Örn: Bana kahvaltı hazırla 🥐',
              hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 12),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: AppColors.backgroundWarm,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _presetWishes.map((preset) {
              return InkWell(
                onTap: () {
                  HapticUtils.light();
                  controller.text = preset;
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    preset,
                    style: TextStyle(fontSize: 10.5, color: accentColor, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
