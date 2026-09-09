import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Painter drawing white dashed sailing routes with directional arrows
/// and organic floating stepping stones on the water between two islands.
class SteppingStonesPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final bool isPathUnlocked;

  SteppingStonesPainter({
    required this.start,
    required this.end,
    this.isPathUnlocked = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Determine curve control points for an organic gentle S-curve
    final midY = (start.dy + end.dy) / 2;
    final controlX = (start.dx + end.dx) / 2 + (start.dx < end.dx ? 24 : -24);
    final controlPoint = Offset(controlX, midY);

    // Create curved navigation path
    final curvePath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    final pathMetrics = curvePath.computeMetrics();

    // 1. Draw White Dashed Sailing Route (as shown in original map)
    final dashPaint = Paint()
      ..color = isPathUnlocked
          ? Colors.white.withOpacity(0.85)
          : Colors.white.withOpacity(0.35)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arrowPaint = Paint()
      ..color = isPathUnlocked
          ? Colors.white.withOpacity(0.90)
          : Colors.white.withOpacity(0.40)
      ..style = PaintingStyle.fill;

    for (final metric in pathMetrics) {
      final totalLen = metric.length;
      if (totalLen <= 0) continue;

      // Draw dashed segments
      double distance = 16.0; // offset slightly from island centers
      const dashLength = 8.0;
      const dashSpace = 6.0;

      while (distance < totalLen - 16.0) {
        final nextDist = math.min(distance + dashLength, totalLen - 16.0);
        final segment = metric.extractPath(distance, nextDist);
        canvas.drawPath(segment, dashPaint);
        distance += dashLength + dashSpace;
      }

      // Draw 2 directional navigation arrows along the sailing route
      final arrowPositions = [totalLen * 0.35, totalLen * 0.70];
      for (final arrowPos in arrowPositions) {
        final tangent = metric.getTangentForOffset(arrowPos);
        if (tangent != null) {
          final pos = tangent.position;
          final angle = tangent.angle;

          canvas.save();
          canvas.translate(pos.dx, pos.dy);
          canvas.rotate(angle);

          // Arrowhead pointing forward along tangent
          final arrowPath = Path()
            ..moveTo(5.0, 0.0)
            ..lineTo(-4.0, -3.5)
            ..lineTo(-2.0, 0.0)
            ..lineTo(-4.0, 3.5)
            ..close();

          canvas.drawPath(arrowPath, arrowPaint);
          canvas.restore();
        }
      }
    }

    // 2. Draw Floating Stepping Stones
    const stoneCount = 4;
    for (int i = 1; i <= stoneCount; i++) {
      final t = i / (stoneCount + 1);

      // Quadratic Bezier interpolation: B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
      final stoneX = (1 - t) * (1 - t) * start.dx + 2 * (1 - t) * t * controlPoint.dx + t * t * end.dx;
      final stoneY = (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * controlPoint.dy + t * t * end.dy;

      final stoneCenter = Offset(stoneX, stoneY);
      final stoneWidth = 18.0 - (i % 2) * 3;
      final stoneHeight = 13.0 - (i % 2) * 2;

      // Water foam ripple around rock
      final ripplePaint = Paint()
        ..color = const Color(0x66E0FAFF)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: stoneCenter.translate(0, 1.5),
          width: stoneWidth + 6,
          height: stoneHeight + 5,
        ),
        ripplePaint,
      );

      // Stepping Stone Base
      final stonePaint = Paint()
        ..color = isPathUnlocked ? const Color(0xFF8D5B28) : const Color(0xFF5A4D41)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: stoneCenter,
          width: stoneWidth,
          height: stoneHeight,
        ),
        stonePaint,
      );

      // Stone Top Highlight
      final topPaint = Paint()
        ..color = isPathUnlocked ? const Color(0xFFB07D48) : const Color(0xFF6C5D50)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: stoneCenter.translate(-1.0, -1.5),
          width: stoneWidth * 0.72,
          height: stoneHeight * 0.65,
        ),
        topPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SteppingStonesPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.isPathUnlocked != isPathUnlocked;
  }
}
