import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/island_board.dart';

/// Floating island widget displaying the authentic illustrated artwork from the user's map.
/// Features water foam ripples, locked desaturation, glowing active state,
/// and a shiny level badge (1..10).
class VerticalIslandWidget extends StatefulWidget {
  final IslandInfo island;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isCompleted;
  final String? winnerName;
  final VoidCallback onTap;

  const VerticalIslandWidget({
    super.key,
    required this.island,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isCompleted,
    this.winnerName,
    required this.onTap,
  });

  @override
  State<VerticalIslandWidget> createState() => _VerticalIslandWidgetState();
}

class _VerticalIslandWidgetState extends State<VerticalIslandWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIsland10 = widget.island.number == 10;
    final baseWidth = isIsland10 ? 250.0 : 156.0;
    final baseHeight = isIsland10 ? 175.0 : 124.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: baseWidth,
            height: baseHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Water foam ripple glow under the island
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isIsland10 ? 36 : 28),
                      boxShadow: [
                        BoxShadow(
                          color: widget.isCurrent
                              ? const Color(0xAA00F5D4)
                              : const Color(0x55A0EADE),
                          blurRadius: widget.isCurrent ? 24 : 14,
                          spreadRadius: widget.isCurrent ? 6 : 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Authentic Island Artwork from the User's Image
                Positioned.fill(
                  child: ColorFiltered(
                    colorFilter: widget.isUnlocked
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                        : const ColorFilter.matrix(<double>[
                            0.30, 0.30, 0.30, 0, 0,
                            0.30, 0.30, 0.30, 0, 0,
                            0.30, 0.30, 0.30, 0, 0,
                            0,    0,    0,    0.60, 0,
                          ]),
                    child: Image.asset(
                      'assets/images/island_${widget.island.number}.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),

                // 3. Level Badge (1..10) positioned nicely on the island
                Positioned(
                  top: isIsland10 ? 20 : 6,
                  right: isIsland10 ? 30 : 6,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = widget.isCurrent
                          ? 1.0 + (_pulseController.value * 0.10)
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: _buildLevelBadge(),
                  ),
                ),

                // 4. Crown on Island 10
                if (isIsland10)
                  const Positioned(
                    top: -12,
                    child: Text('👑', style: TextStyle(fontSize: 32)),
                  ),

                // 5. Winner Rumuz Badge (when island is won)
                if (widget.winnerName != null)
                  Positioned(
                    bottom: isIsland10 ? 18 : 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD166), Color(0xFFFFB703)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                          Text(
                            widget.winnerName!,
                            style: const TextStyle(
                              color: Color(0xFF5E3004),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Island Title Pill Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.72),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isCurrent ? AppColors.player1Badge : Colors.white24,
                width: widget.isCurrent ? 1.8 : 1.0,
              ),
              boxShadow: [
                if (widget.isCurrent)
                  BoxShadow(
                    color: AppColors.player1Badge.withOpacity(0.55),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.winnerName != null
                      ? '${widget.island.number}. ${widget.island.title} (🏆 ${widget.winnerName})'
                      : '${widget.island.number}. ${widget.island.title}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: widget.isCurrent ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    const size = 38.0;

    // Completed: Emerald Green with Golden Star
    if (widget.isCompleted) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2EC4B6), Color(0xFF0E7A6E)],
          ),
          border: Border.all(color: const Color(0xFFFFD166), width: 2.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 22),
        ),
      );
    }

    // Active / Current: Radiant Crimson with Island Number
    if (widget.isCurrent) {
      return Container(
        width: size + 4,
        height: size + 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF3366), Color(0xFFC9184A)],
          ),
          border: Border.all(color: const Color(0xFFFFE66D), width: 3.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3366).withOpacity(0.7),
              blurRadius: 14,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.island.number}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              shadows: [
                Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      );
    }

    // Unlocked: Golden Amber Token
    if (widget.isUnlocked) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
          ),
          border: Border.all(color: Colors.white, width: 2.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.island.number}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Locked: Metallic Slate Grey with Padlock
    return Container(
      width: size - 4,
      height: size - 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C757D), Color(0xFF343A40)],
        ),
        border: Border.all(color: const Color(0xFFADB5BD), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.lock_rounded, color: Color(0xFFE9ECEF), size: 16),
      ),
    );
  }
}
