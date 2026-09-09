import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/island_board.dart';

/// Interactive pin/badge rendered on top of each island in the Archipelago Sea Map.
class IslandPinWidget extends StatelessWidget {
  final IslandInfo island;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isCompleted;
  final VoidCallback onTap;

  const IslandPinWidget({
    super.key,
    required this.island,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Widget statusIcon;

    if (!isUnlocked) {
      badgeColor = const Color(0xFF6C757D);
      statusIcon = const Icon(Icons.lock_rounded, size: 14, color: Colors.white);
    } else if (isCompleted) {
      badgeColor = const Color(0xFF2A9D8F);
      statusIcon = const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFD166));
    } else if (isCurrent) {
      badgeColor = AppColors.player1Badge;
      statusIcon = const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white);
    } else {
      badgeColor = const Color(0xFF457B9D);
      statusIcon = Text(
        '${island.number}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing/Pulsing Badge
          Container(
            width: isCurrent ? 38 : 32,
            height: isCurrent ? 38 : 32,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isCurrent ? 2.5 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCurrent
                      ? AppColors.player1Badge.withOpacity(0.5)
                      : const Color(0x33000000),
                  blurRadius: isCurrent ? 12 : 6,
                  spreadRadius: isCurrent ? 2 : 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: statusIcon),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCurrent ? AppColors.player1Badge : Colors.white24,
                width: 1,
              ),
            ),
            child: Text(
              '${island.number}. ${island.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
