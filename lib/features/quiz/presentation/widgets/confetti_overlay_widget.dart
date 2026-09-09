import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Pastel hearts and confetti particles burst when both players are correct!
class ConfettiOverlayWidget extends StatefulWidget {
  final bool active;
  final Widget child;

  const ConfettiOverlayWidget({
    super.key,
    required this.active,
    required this.child,
  });

  @override
  State<ConfettiOverlayWidget> createState() => _ConfettiOverlayWidgetState();
}

class _ConfettiOverlayWidgetState extends State<ConfettiOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.active) {
      _spawnParticles();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _spawnParticles();
    }
  }

  void _spawnParticles() {
    _particles.clear();
    const colors = [
      AppColors.pastelPink,
      AppColors.pastelLavender,
      AppColors.pastelMint,
      AppColors.pastelYellow,
      AppColors.player1Badge,
      AppColors.angelHalo,
    ];

    for (int i = 0; i < 45; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: -0.1 - _random.nextDouble() * 0.2,
          size: 6.0 + _random.nextDouble() * 8.0,
          speedY: 0.4 + _random.nextDouble() * 0.7,
          speedX: (_random.nextDouble() - 0.5) * 0.3,
          color: colors[_random.nextInt(colors.length)],
          isHeart: _random.nextBool(),
          rotation: _random.nextDouble() * 2 * math.pi,
        ),
      );
    }
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.active)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _controller.value,
                      particles: _particles,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double speedY;
  final double speedX;
  final Color color;
  final bool isHeart;
  final double rotation;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.color,
    required this.isHeart,
    required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ConfettiPainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final currentY = (p.y + p.speedY * progress) * size.height;
      final currentX = (p.x + p.speedX * progress) * size.width;

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.rotation + progress * 4);

      if (p.isHeart) {
        _drawSmallHeart(canvas, p.size, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.7),
            const Radius.circular(2),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  void _drawSmallHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final width = size;
    final height = size;
    path.moveTo(0, height * 0.3);
    path.cubicTo(-width * 0.5, -height * 0.3, -width, height * 0.3, 0, height);
    path.cubicTo(width, height * 0.3, width * 0.5, -height * 0.3, 0, height * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
