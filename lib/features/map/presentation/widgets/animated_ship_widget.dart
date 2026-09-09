import 'dart:math';
import 'package:flutter/material.dart';

/// Animated sailing ship matching the red-and-white sail wooden caravel from the map artwork.
/// Gently bobs and rocks on water waves at 60 FPS.
class AnimatedShipWidget extends StatefulWidget {
  final double size;
  final bool isSailing;

  const AnimatedShipWidget({
    super.key,
    this.size = 46.0,
    this.isSailing = false,
  });

  @override
  State<AnimatedShipWidget> createState() => _AnimatedShipWidgetState();
}

class _AnimatedShipWidgetState extends State<AnimatedShipWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 * pi;
        final bobY = sin(t) * 3.5;
        final rockAngle = sin(t * 0.8) * 0.08;

        return Transform.translate(
          offset: Offset(0, bobY),
          child: Transform.rotate(
            angle: rockAngle,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ShipPainter(),
      ),
    );
  }
}

class _ShipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Water ripple shadow
    final shadowPaint = Paint()
      ..color = const Color(0x33004466)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.88),
        width: w * 0.85,
        height: h * 0.22,
      ),
      shadowPaint,
    );

    // Hull (Wooden body)
    final hullPaint = Paint()..color = const Color(0xFF8B4513);
    final hullDarkPaint = Paint()..color = const Color(0xFF5C2C16);
    final hullPath = Path();
    hullPath.moveTo(w * 0.15, h * 0.62);
    hullPath.quadraticBezierTo(w * 0.25, h * 0.88, w * 0.85, h * 0.84);
    hullPath.lineTo(w * 0.90, h * 0.60);
    hullPath.quadraticBezierTo(w * 0.55, h * 0.68, w * 0.15, h * 0.62);
    hullPath.close();
    canvas.drawPath(hullPath, hullPaint);

    // Hull Rim
    final rimPaint = Paint()
      ..color = const Color(0xFFD4A373)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(hullPath, rimPaint);

    // Mast
    final mastPaint = Paint()
      ..color = const Color(0xFF5C2C16)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.52, h * 0.70), Offset(w * 0.52, h * 0.18), mastPaint);

    // Front Bowsprit (front stick)
    canvas.drawLine(Offset(w * 0.20, h * 0.63), Offset(w * 0.06, h * 0.50), mastPaint);

    // Main Sail (Billowing cream canvas with red stripes)
    final sailPath = Path();
    sailPath.moveTo(w * 0.52, h * 0.25);
    sailPath.quadraticBezierTo(w * 0.30, h * 0.35, w * 0.34, h * 0.60);
    sailPath.quadraticBezierTo(w * 0.50, h * 0.55, w * 0.68, h * 0.60);
    sailPath.quadraticBezierTo(w * 0.62, h * 0.35, w * 0.52, h * 0.25);
    sailPath.close();

    final sailBgPaint = Paint()..color = const Color(0xFFFFF8EE);
    canvas.drawPath(sailPath, sailBgPaint);

    // Red Center Stripe on Sail
    final stripePaint = Paint()
      ..color = const Color(0xFFE63946)
      ..style = PaintingStyle.fill;
    final stripePath = Path();
    stripePath.moveTo(w * 0.48, h * 0.26);
    stripePath.lineTo(w * 0.54, h * 0.26);
    stripePath.lineTo(w * 0.55, h * 0.58);
    stripePath.lineTo(w * 0.47, h * 0.58);
    stripePath.close();
    canvas.drawPath(stripePath, stripePaint);

    // Sail Border
    final sailBorder = Paint()
      ..color = const Color(0xFF5C2C16)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(sailPath, sailBorder);

    // Red Pennant Flag atop mast
    final flagPaint = Paint()..color = const Color(0xFFE63946);
    final flagPath = Path();
    flagPath.moveTo(w * 0.52, h * 0.18);
    flagPath.lineTo(w * 0.70, h * 0.14);
    flagPath.lineTo(w * 0.52, h * 0.10);
    flagPath.close();
    canvas.drawPath(flagPath, flagPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
