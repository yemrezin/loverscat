import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/fire_water_models.dart';

class FireWaterCanvas extends StatelessWidget {
  final FireWaterGameState state;

  const FireWaterCanvas({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16181F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3A3F4D), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x60000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          painter: _FireWaterPainter(state),
        ),
      ),
    );
  }
}

class _FireWaterPainter extends CustomPainter {
  final FireWaterGameState state;

  _FireWaterPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate scale from virtual 400x400 to actual canvas size
    final scaleX = size.width / 400.0;
    final scaleY = size.height / 400.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    _drawBackground(canvas);
    _drawPlatforms(canvas);
    _drawHazards(canvas);
    _drawBarriers(canvas);
    _drawButtons(canvas);
    _drawDoors(canvas);
    _drawGems(canvas);
    _drawPlayers(canvas);

    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E222D), Color(0xFF13151C)],
      ).createShader(const Rect.fromLTWH(0, 0, 400, 400));
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 400), bgPaint);

    // Subtle stone brick grid lines
    final linePaint = Paint()
      ..color = const Color(0x18FFFFFF)
      ..strokeWidth = 1.0;

    for (double y = 40; y < 400; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(400, y), linePaint);
    }
  }

  void _drawPlatforms(Canvas canvas) {
    final fillPaint = Paint()..color = const Color(0xFF383C48);
    final topHighlightPaint = Paint()
      ..color = const Color(0xFF5B6275)
      ..strokeWidth = 2.0;

    for (final p in state.platforms) {
      final r = p.rect;
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), fillPaint);
      canvas.drawLine(Offset(r.left, r.top + 1), Offset(r.right, r.top + 1), topHighlightPaint);
    }
  }

  void _drawHazards(Canvas canvas) {
    for (final h in state.hazards) {
      final r = h.rect;
      Color startColor;
      Color endColor;
      Color glowColor;

      switch (h.type) {
        case HazardType.fire:
          startColor = const Color(0xFFFF3D00);
          endColor = const Color(0xFFFF9100);
          glowColor = const Color(0x66FF3D00);
          break;
        case HazardType.water:
          startColor = const Color(0xFF00B0FF);
          endColor = const Color(0xFF0066FF);
          glowColor = const Color(0x6600B0FF);
          break;
        case HazardType.acid:
          startColor = const Color(0xFF00E676);
          endColor = const Color(0xFF1DE9B6);
          glowColor = const Color(0x6600E676);
          break;
      }

      // Glow under pool
      final glowPaint = Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRect(r, glowPaint);

      // Liquid pool
      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [endColor, startColor],
        ).createShader(r);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), liquidPaint);

      // Surface ripples
      final ripplePaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(r.left + 4, r.top + 2), Offset(r.right - 4, r.top + 2), ripplePaint);
    }
  }

  void _drawBarriers(Canvas canvas) {
    for (final b in state.barriers) {
      final r = b.currentRect;
      final paint = Paint()..color = const Color(0xFF8D99AE);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), paint);

      // Grate stripes
      final stripePaint = Paint()
        ..color = const Color(0xFF2B2D42)
        ..strokeWidth = 1.5;
      for (double y = r.top + 4; y < r.bottom - 2; y += 8) {
        canvas.drawLine(Offset(r.left + 2, y), Offset(r.right - 2, y), stripePaint);
      }
    }
  }

  void _drawButtons(Canvas canvas) {
    for (final btn in state.buttons) {
      final r = btn.rect;
      final color = btn.isPressed ? const Color(0xFF4CAF50) : const Color(0xFFFF5252);
      final btnPaint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(r.left, btn.isPressed ? r.top + 2 : r.top, r.width, btn.isPressed ? 4 : 6),
          const Radius.circular(2),
        ),
        btnPaint,
      );
    }
  }

  void _drawDoors(Canvas canvas) {
    _drawDoor(canvas, state.fireDoor, const Color(0xFFFF3366), '🔥');
    _drawDoor(canvas, state.waterDoor, const Color(0xFF00B4D8), '💧');
  }

  void _drawDoor(Canvas canvas, FireWaterExitDoor door, Color color, String icon) {
    final r = door.rect;
    final reached = door.isReached;

    if (reached) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(8)), glowPaint);
    }

    final framePaint = Paint()
      ..color = reached ? color : const Color(0xFF424754)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final bodyPaint = Paint()..color = reached ? color.withOpacity(0.3) : const Color(0xFF252934);

    final rrect = RRect.fromRectAndRadius(r, const Radius.circular(8));
    canvas.drawRRect(rrect, bodyPaint);
    canvas.drawRRect(rrect, framePaint);

    // Arch icon
    final tp = TextPainter(
      text: TextSpan(text: icon, style: const TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(r.center.dx - 8, r.top + 8));
  }

  void _drawGems(Canvas canvas) {
    for (final gem in state.gems) {
      if (gem.isCollected) continue;
      final isFire = gem.type == CharacterType.fire;
      final color = isFire ? const Color(0xFFFF3864) : const Color(0xFF00F0FF);

      final path = Path()
        ..moveTo(gem.center.dx, gem.center.dy - 7)
        ..lineTo(gem.center.dx + 6, gem.center.dy)
        ..lineTo(gem.center.dx, gem.center.dy + 7)
        ..lineTo(gem.center.dx - 6, gem.center.dy)
        ..close();

      final glow = Paint()
        ..color = color.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, glow);

      final paint = Paint()..color = color;
      canvas.drawPath(path, paint);

      // Shimmer dot
      final shimmer = Paint()..color = Colors.white.withOpacity(0.9);
      canvas.drawCircle(Offset(gem.center.dx - 1.5, gem.center.dy - 2), 1.5, shimmer);
    }
  }

  void _drawPlayers(Canvas canvas) {
    _drawPlayer(canvas, state.firePlayer, isFire: true);
    _drawPlayer(canvas, state.waterPlayer, isFire: false);
  }

  void _drawPlayer(Canvas canvas, FireWaterPlayer p, {required bool isFire}) {
    final isActive = (isFire && state.activeCharacter == CharacterType.fire) ||
        (!isFire && state.activeCharacter == CharacterType.water);
    final baseColor = isFire ? const Color(0xFFFF5722) : const Color(0xFF00B4D8);
    final accentColor = isFire ? const Color(0xFFFF9800) : const Color(0xFF90E0EF);

    final r = p.rect;

    // Active player highlight halo
    if (isActive) {
      final haloPaint = Paint()
        ..color = baseColor.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawOval(r.inflate(4), haloPaint);

      // Arrow indicator above active character
      final arrowPath = Path()
        ..moveTo(r.center.dx - 4, r.top - 10)
        ..lineTo(r.center.dx + 4, r.top - 10)
        ..lineTo(r.center.dx, r.top - 5)
        ..close();
      canvas.drawPath(arrowPath, Paint()..color = accentColor);
    }

    // Body (cute rounded cat silhouette)
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [accentColor, baseColor],
      ).createShader(r);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(r.left + 2, r.top + 6, r.width - 4, r.height - 6),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Cat ears
    final earPaint = Paint()..color = baseColor;
    final leftEar = Path()
      ..moveTo(r.left + 3, r.top + 8)
      ..lineTo(r.left + 6, r.top)
      ..lineTo(r.left + 10, r.top + 7)
      ..close();
    final rightEar = Path()
      ..moveTo(r.right - 10, r.top + 7)
      ..lineTo(r.right - 6, r.top)
      ..lineTo(r.right - 3, r.top + 8)
      ..close();
    canvas.drawPath(leftEar, earPaint);
    canvas.drawPath(rightEar, earPaint);

    // Cat face
    final eyePaint = Paint()..color = const Color(0xFF1E222D);
    canvas.drawCircle(Offset(r.left + 8, r.top + 13), 2.0, eyePaint);
    canvas.drawCircle(Offset(r.right - 8, r.top + 13), 2.0, eyePaint);

    // Eye glints
    final glintPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(r.left + 7.5, r.top + 12.5), 0.7, glintPaint);
    canvas.drawCircle(Offset(r.right - 8.5, r.top + 12.5), 0.7, glintPaint);

    // Elemental symbol on chest
    final symbol = isFire ? '🔥' : '💧';
    final tp = TextPainter(
      text: TextSpan(text: symbol, style: const TextStyle(fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(r.center.dx - 5, r.top + 16));
  }

  @override
  bool shouldRepaint(covariant _FireWaterPainter oldDelegate) => true;
}
