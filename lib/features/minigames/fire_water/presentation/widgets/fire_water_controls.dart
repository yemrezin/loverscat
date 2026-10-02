import 'package:flutter/material.dart';
import 'package:loverscat/core/constants/app_colors.dart';
import 'package:loverscat/core/utils/haptic_utils.dart';
import '../../domain/models/fire_water_models.dart';
import '../controllers/fire_water_controller.dart';

class FireWaterControls extends StatelessWidget {
  final FireWaterGameState state;
  final FireWaterController controller;

  const FireWaterControls({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isFire = state.activeCharacter == CharacterType.fire;
    final activeThemeColor = isFire ? const Color(0xFFFF5722) : const Color(0xFF00B4D8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF333846), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Character Selector & Status Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Character Switcher Pill
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF13151C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF333846)),
                ),
                child: Row(
                  children: [
                    _buildCharacterTab(
                      label: 'Ateş Kedi 🔥',
                      type: CharacterType.fire,
                      isSelected: isFire,
                      activeColor: const Color(0xFFFF5722),
                    ),
                    const SizedBox(width: 4),
                    _buildCharacterTab(
                      label: 'Su Kedi 💧',
                      type: CharacterType.water,
                      isSelected: !isFire,
                      activeColor: const Color(0xFF00B4D8),
                    ),
                  ],
                ),
              ),

              // Gem Counter Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF13151C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF333846)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '${state.collectedGemsCount}/${state.totalGemsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Restart Button
              IconButton(
                onPressed: () {
                  HapticUtils.light();
                  controller.resetLevel();
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 24),
                tooltip: 'Yeniden Başlat',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Directional Movement & Jump Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left / Right D-Pad
              Row(
                children: [
                  _buildHoldButton(
                    icon: Icons.arrow_back_rounded,
                    onStart: () => controller.moveLeft(true),
                    onEnd: () => controller.moveLeft(false),
                    accentColor: activeThemeColor,
                  ),
                  const SizedBox(width: 12),
                  _buildHoldButton(
                    icon: Icons.arrow_forward_rounded,
                    onStart: () => controller.moveRight(true),
                    onEnd: () => controller.moveRight(false),
                    accentColor: activeThemeColor,
                  ),
                ],
              ),

              // Jump Action Button
              _buildTapButton(
                icon: Icons.arrow_upward_rounded,
                label: 'ZIPLA',
                onTap: () {
                  HapticUtils.light();
                  controller.jump();
                },
                accentColor: activeThemeColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterTab({
    required String label,
    required CharacterType type,
    required bool isSelected,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticUtils.light();
        controller.selectCharacter(type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHoldButton({
    required IconData icon,
    required VoidCallback onStart,
    required VoidCallback onEnd,
    required Color accentColor,
  }) {
    return Listener(
      onPointerDown: (_) {
        HapticUtils.light();
        onStart();
      },
      onPointerUp: (_) => onEnd(),
      onPointerCancel: (_) => onEnd(),
      child: Container(
        width: 68,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF272B38),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF3F4658), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildTapButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accentColor, accentColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
