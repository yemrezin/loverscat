import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/game_state.dart';
import '../../../../map/presentation/controllers/map_providers.dart';

/// Row of 3 vibrant gradient stat cards: Aşk Serisi, Ada/Raftel Yolu, Kuş Fısıltısı.
class HomeVibrantStats extends StatelessWidget {
  final QuizGameState gameState;
  final MapState mapState;

  const HomeVibrantStats({
    super.key,
    required this.gameState,
    required this.mapState,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildVibrantStatCard(
            icon: '🔥',
            value: '${gameState.streak}',
            label: 'Aşk Serisi',
            gradient: AppColors.vibrantOrangeGradient,
            shadowColor: const Color(0x33FF6B00),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildVibrantStatCard(
            icon: '⛵',
            value: '${mapState.currentIsland}. Ada',
            label: 'Raftel Yolu',
            gradient: AppColors.islandOceanGradient,
            shadowColor: const Color(0x330077B6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildVibrantStatCard(
            icon: '🕊️',
            value: '${gameState.birdWhisperHintsAvailable}',
            label: 'Fısıltı',
            gradient: AppColors.vibrantPurpleGradient,
            shadowColor: const Color(0x338338EC),
          ),
        ),
      ],
    );
  }

  Widget _buildVibrantStatCard({
    required String icon,
    required String value,
    required String label,
    required LinearGradient gradient,
    required Color shadowColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.92),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
