import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../../online/controllers/online_controller.dart';
import '../../../../map/presentation/controllers/map_providers.dart';
import '../../../../map/presentation/screens/world_map_screen.dart';
import '../../../../settings/presentation/screens/settings_screen.dart';

/// Top bar with World Map navigation, How to Play, and Settings with notification badge.
class HomeTopBar extends StatelessWidget {
  final OnlineState onlineState;
  final MapState mapState;
  final VoidCallback onShowHowToPlay;

  const HomeTopBar({
    super.key,
    required this.onlineState,
    required this.mapState,
    required this.onShowHowToPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sol Üstte Harita Butonu
        InkWell(
          onTap: () {
            HapticUtils.light();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WorldMapScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.islandOceanGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330077B6),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🗺️', style: TextStyle(fontSize: 15)),
                SizedBox(width: 6),
                Text(
                  'Haritalar',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sağ Üst Kontroller
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: AppColors.textPrimary, size: 22),
                tooltip: 'Nasıl Oynanır?',
                onPressed: onShowHowToPlay,
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary, size: 22),
                    tooltip: 'Ayarlar & Arkadaş Ekle',
                    onPressed: () {
                      HapticUtils.light();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
                if (onlineState.incomingRequests.isNotEmpty)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.angryRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${onlineState.incomingRequests.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
