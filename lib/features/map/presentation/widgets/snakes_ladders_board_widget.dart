import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/island_board.dart';
import '../../../pet/domain/models/pet_avatar.dart';
import '../../../pet/presentation/widgets/pet_display_widget.dart';

/// 10x10 Snakes and Ladders board:
/// - Alternating lime green & yellow tiles
/// - Blue & red special squares
/// - Ladders with wooden rungs
/// - Wavy colorful snakes with cute eyes
/// - Star on square 100
/// - Dual Player Tokens:
///   * If on the SAME square: shrunk down side-by-side to fit neatly in one tile.
///   * If on DIFFERENT squares: full size with full nickname pill badges.
/// 6x8 Snakes and Ladders board with tactile checkers piece ("dama taşı") player tokens.
class SnakesLaddersBoardWidget extends StatelessWidget {
  final int player1Position;
  final PetAvatar? player1Pet;
  final int player2Position;
  final PetAvatar? player2Pet;
  final VoidCallback? onPlayer1Tap;
  final VoidCallback? onPlayer2Tap;

  const SnakesLaddersBoardWidget({
    super.key,
    required this.player1Position,
    this.player1Pet,
    required this.player2Position,
    this.player2Pet,
    this.onPlayer1Tap,
    this.onPlayer2Tap,
  });

  /// Legacy constructor for single-player compatibility
  const SnakesLaddersBoardWidget.singlePlayer({
    super.key,
    required int playerPosition,
    PetAvatar? pet,
    VoidCallback? onTap,
  })  : player1Position = playerPosition,
        player1Pet = pet,
        player2Position = 1,
        player2Pet = null,
        onPlayer1Tap = onTap,
        onPlayer2Tap = null;

  @override
  Widget build(BuildContext context) {
    final safeP1 = player1Pet ?? CouplePlayers.defaultPlayers.player1;
    final safeP2 = player2Pet ?? CouplePlayers.defaultPlayers.player2;
    final p1Type = safeP1.type;
    final p2Type = safeP2.type;

    return AspectRatio(
      aspectRatio: 6.0 / 8.0, // X: 6 columns, Y: 8 rows
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF264653), width: 3.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellW = constraints.maxWidth / SnakesAndLaddersConfig.gridCols;
              final cellH = constraints.maxHeight / SnakesAndLaddersConfig.gridRows;

              final p1Grid = SnakesAndLaddersConfig.getGridPosition(player1Position);
              final p2Grid = SnakesAndLaddersConfig.getGridPosition(player2Position);
              final isSameSquare = player1Position == player2Position;

              return Stack(
                children: [
                  // 1. Board Background Tiles, Ladders, Snakes, Numbers & Star
                  Positioned.fill(
                    child: CustomPaint(
                      painter: const _BoardPainter(),
                    ),
                  ),

                  // 2. Tactile Dama Taşı Tokens with Player Avatars in their squares
                  if (isSameSquare) ...[
                    // Both on the SAME square: side-by-side checkers pieces inside the cell
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      left: p1Grid.x * cellW + cellW * 0.04,
                      top: p1Grid.y * cellH + (cellH - cellW * 0.44) / 2,
                      width: cellW * 0.44,
                      height: cellW * 0.44,
                      child: DamaTasiWidget(
                        petType: p1Type,
                        size: cellW * 0.44,
                        isPlayer1: true,
                        onTap: onPlayer1Tap,
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      left: p1Grid.x * cellW + cellW * 0.52,
                      top: p1Grid.y * cellH + (cellH - cellW * 0.44) / 2,
                      width: cellW * 0.44,
                      height: cellW * 0.44,
                      child: DamaTasiWidget(
                        petType: p2Type,
                        size: cellW * 0.44,
                        isPlayer1: false,
                        onTap: onPlayer2Tap,
                      ),
                    ),
                  ] else ...[
                    // Different squares: centered checkers piece inside each player's square
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      left: p1Grid.x * cellW + (cellW - cellW * 0.74) / 2,
                      top: p1Grid.y * cellH + (cellH - cellW * 0.74) / 2,
                      width: cellW * 0.74,
                      height: cellW * 0.74,
                      child: DamaTasiWidget(
                        petType: p1Type,
                        size: cellW * 0.74,
                        isPlayer1: true,
                        onTap: onPlayer1Tap,
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      left: p2Grid.x * cellW + (cellW - cellW * 0.74) / 2,
                      top: p2Grid.y * cellH + (cellH - cellW * 0.74) / 2,
                      width: cellW * 0.74,
                      height: cellW * 0.74,
                      child: DamaTasiWidget(
                        petType: p2Type,
                        size: cellW * 0.74,
                        isPlayer1: false,
                        onTap: onPlayer2Tap,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A tactile checkers piece ("dama taşı") that houses the player's pet face avatar in its center.
/// Has a raised outer rim, 3D ridge bevel, and drop shadow characteristic of board game checker draughts.
class DamaTasiWidget extends StatelessWidget {
  final PetType? petType;
  final double size;
  final bool isPlayer1;
  final VoidCallback? onTap;

  const DamaTasiWidget({
    super.key,
    this.petType,
    this.size = 36,
    this.isPlayer1 = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveType = petType ?? (isPlayer1 ? PetType.cat : PetType.rabbit);
    final baseGradient = isPlayer1
        ? const [Color(0xFFFF3366), Color(0xFFC70039), Color(0xFF900C3F)]
        : const [Color(0xFF2EC4B6), Color(0xFF0F9D58), Color(0xFF006644)];
    final ringColor = isPlayer1 ? const Color(0xFFFFD1DC) : const Color(0xFFB7E4C7);
    final shadowColor = isPlayer1 ? const Color(0x66FF3366) : const Color(0x662EC4B6);

    Widget piece = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: baseGradient,
        ),
        border: Border.all(
          color: ringColor,
          width: math.max(2.0, size * 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.72,
          height: size * 0.72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: ringColor.withOpacity(0.9),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              effectiveType.headAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    effectiveType.emoji,
                    style: TextStyle(fontSize: size * 0.42),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: piece,
      );
    }
    return piece;
  }
}

class _BoardPainter extends CustomPainter {
  const _BoardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / SnakesAndLaddersConfig.gridCols;
    final cellH = size.height / SnakesAndLaddersConfig.gridRows;

    // 1. Draw Grid Squares (1..48)
    for (int num = 1; num <= SnakesAndLaddersConfig.totalSquares; num++) {
      final pos = SnakesAndLaddersConfig.getGridPosition(num);
      final rect = Rect.fromLTWH(pos.x * cellW, pos.y * cellH, cellW, cellH);

      Color cellColor;
      if (SnakesAndLaddersConfig.blueSquares.contains(num)) {
        cellColor = const Color(0xFF64B5F6); // Soft bright blue (lucky ladder / safe)
      } else if (SnakesAndLaddersConfig.redSquares.contains(num)) {
        cellColor = const Color(0xFFEF5350); // Coral red (snake danger)
      } else {
        // Alternating green & yellow
        final isEven = (pos.x + pos.y) % 2 == 0;
        cellColor = isEven ? const Color(0xFFD4E157) : const Color(0xFFFFEE58);
      }

      // Draw cell fill
      canvas.drawRect(rect, Paint()..color = cellColor);
      // Subtle cell borders
      canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0x18000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );

      // Draw square number
      _drawCellNumber(canvas, rect, num);
    }

    // 2. Draw Ladders
    for (final entry in SnakesAndLaddersConfig.ladders.entries) {
      final startCenter = _getCellCenter(entry.key, cellW, cellH);
      final endCenter = _getCellCenter(entry.value, cellW, cellH);
      _drawLadder(canvas, startCenter, endCenter);
    }

    // 3. Draw Snakes
    _drawSnakes(canvas, cellW, cellH);

    // 4. Draw Star on Goal Square (48)
    final starCenter = _getCellCenter(SnakesAndLaddersConfig.totalSquares, cellW, cellH);
    _drawStar(canvas, starCenter, cellW * 0.42);
  }

  Offset _getCellCenter(int squareNum, double cellW, double cellH) {
    final pos = SnakesAndLaddersConfig.getGridPosition(squareNum);
    return Offset(pos.x * cellW + cellW / 2, pos.y * cellH + cellH / 2);
  }

  void _drawCellNumber(Canvas canvas, Rect rect, int num) {
    if (num == SnakesAndLaddersConfig.totalSquares) return; // Star replaces goal number
    final textSpan = TextSpan(
      text: '$num',
      style: const TextStyle(
        color: Color(0xFF264653),
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(rect.left + 3, rect.top + 2));
  }

  void _drawLadder(Canvas canvas, Offset bottom, Offset top) {
    final dx = top.dx - bottom.dx;
    final dy = top.dy - bottom.dy;
    final angle = math.atan2(dy, dx);
    final perp = angle + math.pi / 2;

    const ladderWidth = 7.0;
    final side1Start = bottom + Offset(math.cos(perp) * ladderWidth, math.sin(perp) * ladderWidth);
    final side1End = top + Offset(math.cos(perp) * ladderWidth, math.sin(perp) * ladderWidth);

    final side2Start = bottom - Offset(math.cos(perp) * ladderWidth, math.sin(perp) * ladderWidth);
    final side2End = top - Offset(math.cos(perp) * ladderWidth, math.sin(perp) * ladderWidth);

    final railPaint = Paint()
      ..color = const Color(0xFF1D3557)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final rungPaint = Paint()
      ..color = const Color(0xFF1D3557)
      ..strokeWidth = 2.4;

    // Draw rails
    canvas.drawLine(side1Start, side1End, railPaint);
    canvas.drawLine(side2Start, side2End, railPaint);

    // Draw rungs along the ladder
    final dist = math.sqrt(dx * dx + dy * dy);
    const rungStep = 14.0;
    final numRungs = (dist / rungStep).floor();

    for (int i = 1; i <= numRungs; i++) {
      final t = i / (numRungs + 1);
      final r1 = Offset.lerp(side1Start, side1End, t)!;
      final r2 = Offset.lerp(side2Start, side2End, t)!;
      canvas.drawLine(r1, r2, rungPaint);
    }
  }

  void _drawSnakes(Canvas canvas, double cellW, double cellH) {
    // Snake 1: 46 -> 30 (Red/Pink wavy)
    _drawCurvedSnake(
      canvas,
      head: _getCellCenter(46, cellW, cellH),
      tail: _getCellCenter(30, cellW, cellH),
      bodyColor: const Color(0xFFE63946),
      bellyColor: const Color(0xFFFFD166),
    );

    // Snake 2: 39 -> 26 (Orange wavy)
    _drawCurvedSnake(
      canvas,
      head: _getCellCenter(39, cellW, cellH),
      tail: _getCellCenter(26, cellW, cellH),
      bodyColor: const Color(0xFFF77F00),
      bellyColor: Colors.white,
    );

    // Snake 3: 32 -> 19 (Purple wavy)
    _drawCurvedSnake(
      canvas,
      head: _getCellCenter(32, cellW, cellH),
      tail: _getCellCenter(19, cellW, cellH),
      bodyColor: const Color(0xFF9D4EDD),
      bellyColor: const Color(0xFFE0AAFF),
    );

    // Snake 4: 23 -> 8 (Blue wavy)
    _drawCurvedSnake(
      canvas,
      head: _getCellCenter(23, cellW, cellH),
      tail: _getCellCenter(8, cellW, cellH),
      bodyColor: const Color(0xFF0077B6),
      bellyColor: const Color(0xFF90E0EF),
    );

    // Snake 5: 16 -> 5 (Cyan wavy)
    _drawCurvedSnake(
      canvas,
      head: _getCellCenter(16, cellW, cellH),
      tail: _getCellCenter(5, cellW, cellH),
      bodyColor: const Color(0xFF06D6A0),
      bellyColor: const Color(0xFFE8F5E9),
    );
  }

  void _drawCurvedSnake(
    Canvas canvas, {
    required Offset head,
    required Offset tail,
    required Color bodyColor,
    required Color bellyColor,
  }) {
    final mid = Offset((head.dx + tail.dx) / 2 + 16, (head.dy + tail.dy) / 2 - 8);

    final path = Path()
      ..moveTo(head.dx, head.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, tail.dx, tail.dy);

    // Body
    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bodyPaint);

    // Inner stripe
    final stripePaint = Paint()
      ..color = bellyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, stripePaint);

    // Head
    canvas.drawCircle(head, 7.5, Paint()..color = bodyColor);
    // Eyes
    canvas.drawCircle(Offset(head.dx - 2, head.dy - 2), 1.6, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(head.dx - 2, head.dy - 2), 0.9, Paint()..color = Colors.black);
  }

  void _drawStar(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = const Color(0xFFFFC107);
    final border = Paint()
      ..color = const Color(0xFFFF8F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerA = -math.pi / 2 + i * (2 * math.pi / 5);
      final innerA = outerA + math.pi / 5;
      final ox = center.dx + math.cos(outerA) * size;
      final oy = center.dy + math.sin(outerA) * size;
      final ix = center.dx + math.cos(innerA) * (size * 0.45);
      final iy = center.dy + math.sin(innerA) * (size * 0.45);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => false;
}
