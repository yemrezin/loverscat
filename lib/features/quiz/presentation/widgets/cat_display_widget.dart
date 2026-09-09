import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/cat_reaction.dart';

/// Renders the Cat Judge with smooth 60 FPS vector animations for all verdicts:
/// - [CatReactionType.idle]: Gentle purring/breathing.
/// - [CatReactionType.angelWings]: Floats skyward, flaps angelic wings, golden halo.
/// - [CatReactionType.slapPlayer1]: Tilts left and delivers a paw slap.
/// - [CatReactionType.slapPlayer2]: Tilts right and delivers a paw slap.
/// - [CatReactionType.doublePawAngry]: Furrows brows, slams both paws, angry steam.
class CatDisplayWidget extends StatefulWidget {
  final CatReaction reaction;
  final double size;

  const CatDisplayWidget({
    super.key,
    required this.reaction,
    this.size = 200,
  });

  @override
  State<CatDisplayWidget> createState() => _CatDisplayWidgetState();
}

class _CatDisplayWidgetState extends State<CatDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant CatDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reaction.type != widget.reaction.type) {
      _controller.reset();
      _controller.repeat();
    }
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
        return SizedBox(
          width: widget.size * 1.3,
          height: widget.size,
          child: CustomPaint(
            painter: _CatVectorPainter(
              progress: _controller.value,
              reactionType: widget.reaction.type,
            ),
          ),
        );
      },
    );
  }
}

class _CatVectorPainter extends CustomPainter {
  final double progress;
  final CatReactionType reactionType;

  _CatVectorPainter({
    required this.progress,
    required this.reactionType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);
    final baseRadius = size.height * 0.34;

    // Animation offsets based on mode
    double floatY = 0;
    double tiltAngle = 0;
    double pawSlapProgress = 0;

    switch (reactionType) {
      case CatReactionType.angelWings:
        // Gentle floating up and down
        floatY = -18.0 + math.sin(progress * 2 * math.pi) * 8.0;
        break;
      case CatReactionType.slapPlayer1:
        // Lean left and strike
        tiltAngle = -0.15;
        pawSlapProgress = (math.sin(progress * 2 * math.pi) + 1) / 2;
        break;
      case CatReactionType.slapPlayer2:
        // Lean right and strike
        tiltAngle = 0.15;
        pawSlapProgress = (math.sin(progress * 2 * math.pi) + 1) / 2;
        break;
      case CatReactionType.doublePawAngry:
        // Furious shaking
        floatY = math.sin(progress * 10 * math.pi) * 3.0;
        pawSlapProgress = (math.sin(progress * 4 * math.pi) + 1) / 2;
        break;
      case CatReactionType.idle:
        // Calm breathing
        floatY = math.sin(progress * 2 * math.pi) * 3.0;
        break;
    }

    final catCenter = center + Offset(0, floatY);

    canvas.save();
    canvas.translate(catCenter.dx, catCenter.dy);
    canvas.rotate(tiltAngle);
    canvas.translate(-catCenter.dx, -catCenter.dy);

    // 1. Draw Angel Wings & Halo if in angel mode
    if (reactionType == CatReactionType.angelWings) {
      _drawAngelWings(canvas, catCenter, baseRadius, progress);
      _drawAngelHalo(canvas, catCenter, baseRadius, progress);
    }

    // 2. Draw Angry steam if in double angry mode
    if (reactionType == CatReactionType.doublePawAngry) {
      _drawAngrySteam(canvas, catCenter, baseRadius, progress);
    }

    // 3. Draw Cat Body, Ears, Face
    _drawCatBody(canvas, catCenter, baseRadius);
    _drawCatEars(canvas, catCenter, baseRadius);
    _drawCatFace(canvas, catCenter, baseRadius);

    // 4. Draw Paws (or Slapping Paws)
    _drawPaws(canvas, catCenter, baseRadius, pawSlapProgress);

    canvas.restore();
  }

  void _drawAngelWings(Canvas canvas, Offset center, double radius, double anim) {
    final wingPaint = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.fill;
    final wingBorder = Paint()
      ..color = const Color(0xFFFFE5EC)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final flap = math.sin(anim * 2 * math.pi) * 0.18;

    // Left Wing
    canvas.save();
    canvas.translate(center.dx - radius * 0.6, center.dy);
    canvas.rotate(-0.35 + flap);
    final leftPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(-radius * 0.9, -radius * 0.7, -radius * 1.3, -radius * 0.2, -radius * 0.9, radius * 0.5)
      ..cubicTo(-radius * 0.5, radius * 0.4, -radius * 0.3, radius * 0.2, 0, 0);
    canvas.drawPath(leftPath, wingPaint);
    canvas.drawPath(leftPath, wingBorder);
    canvas.restore();

    // Right Wing
    canvas.save();
    canvas.translate(center.dx + radius * 0.6, center.dy);
    canvas.rotate(0.35 - flap);
    final rightPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(radius * 0.9, -radius * 0.7, radius * 1.3, -radius * 0.2, radius * 0.9, radius * 0.5)
      ..cubicTo(radius * 0.5, radius * 0.4, radius * 0.3, radius * 0.2, 0, 0);
    canvas.drawPath(rightPath, wingPaint);
    canvas.drawPath(rightPath, wingBorder);
    canvas.restore();
  }

  void _drawAngelHalo(Canvas canvas, Offset center, double radius, double anim) {
    final haloY = center.dy - radius * 1.25 + math.sin(anim * 2 * math.pi) * 2.0;
    final haloPaint = Paint()
      ..color = AppColors.angelHalo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppColors.angelHalo.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;

    final haloRect = Rect.fromCenter(
      center: Offset(center.dx, haloY),
      width: radius * 1.1,
      height: radius * 0.35,
    );

    canvas.drawOval(haloRect, glowPaint);
    canvas.drawOval(haloRect, haloPaint);
  }

  void _drawAngrySteam(Canvas canvas, Offset center, double radius, double anim) {
    final steamPaint = Paint()
      ..color = AppColors.angryRed.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Anger symbol on forehead/ears
    final angleX = center.dx + radius * 0.7;
    final angleY = center.dy - radius * 0.7;
    canvas.drawLine(Offset(angleX - 10, angleY), Offset(angleX + 10, angleY), steamPaint);
    canvas.drawLine(Offset(angleX, angleY - 10), Offset(angleX, angleY + 10), steamPaint);
  }

  void _drawCatBody(Canvas canvas, Offset center, double radius) {
    final bodyPaint = Paint()
      ..color = AppColors.catBody
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = AppColors.catFurDark.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Lower subtle shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.95),
        width: radius * 1.5,
        height: radius * 0.35,
      ),
      shadowPaint,
    );

    // Head / Body circle
    canvas.drawCircle(center, radius, bodyPaint);

    // Inner lighter belly/chest patch
    final bellyPaint = Paint()
      ..color = AppColors.catBelly
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.3),
        width: radius * 0.9,
        height: radius * 0.75,
      ),
      bellyPaint,
    );
  }

  void _drawCatEars(Canvas canvas, Offset center, double radius) {
    final earOuterPaint = Paint()..color = AppColors.catBody;
    final earInnerPaint = Paint()..color = AppColors.catCheeks;

    // Left Ear
    final leftEarPath = Path()
      ..moveTo(center.dx - radius * 0.75, center.dy - radius * 0.4)
      ..lineTo(center.dx - radius * 0.85, center.dy - radius * 1.15)
      ..lineTo(center.dx - radius * 0.25, center.dy - radius * 0.85)
      ..close();
    canvas.drawPath(leftEarPath, earOuterPaint);

    final leftInnerPath = Path()
      ..moveTo(center.dx - radius * 0.7, center.dy - radius * 0.48)
      ..lineTo(center.dx - radius * 0.78, center.dy - radius * 1.0)
      ..lineTo(center.dx - radius * 0.35, center.dy - radius * 0.8)
      ..close();
    canvas.drawPath(leftInnerPath, earInnerPaint);

    // Right Ear
    final rightEarPath = Path()
      ..moveTo(center.dx + radius * 0.75, center.dy - radius * 0.4)
      ..lineTo(center.dx + radius * 0.85, center.dy - radius * 1.15)
      ..lineTo(center.dx + radius * 0.25, center.dy - radius * 0.85)
      ..close();
    canvas.drawPath(rightEarPath, earOuterPaint);

    final rightInnerPath = Path()
      ..moveTo(center.dx + radius * 0.7, center.dy - radius * 0.48)
      ..lineTo(center.dx + radius * 0.78, center.dy - radius * 1.0)
      ..lineTo(center.dx + radius * 0.35, center.dy - radius * 0.8)
      ..close();
    canvas.drawPath(rightInnerPath, earInnerPaint);
  }

  void _drawCatFace(Canvas canvas, Offset center, double radius) {
    final eyePaint = Paint()
      ..color = AppColors.catEyes
      ..style = PaintingStyle.fill;
    final nosePaint = Paint()
      ..color = AppColors.catCheeks
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = AppColors.catEyes
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final leftEyeCenter = Offset(center.dx - radius * 0.35, center.dy - radius * 0.1);
    final rightEyeCenter = Offset(center.dx + radius * 0.35, center.dy - radius * 0.1);

    if (reactionType == CatReactionType.angelWings) {
      // Joyful closed crescent eyes (^ ^)
      final leftArc = Path()
        ..moveTo(leftEyeCenter.dx - 12, leftEyeCenter.dy + 4)
        ..quadraticBezierTo(leftEyeCenter.dx, leftEyeCenter.dy - 10, leftEyeCenter.dx + 12, leftEyeCenter.dy + 4);
      final rightArc = Path()
        ..moveTo(rightEyeCenter.dx - 12, rightEyeCenter.dy + 4)
        ..quadraticBezierTo(rightEyeCenter.dx, rightEyeCenter.dy - 10, rightEyeCenter.dx + 12, rightEyeCenter.dy + 4);
      canvas.drawPath(leftArc, linePaint);
      canvas.drawPath(rightArc, linePaint);
    } else if (reactionType == CatReactionType.doublePawAngry ||
        reactionType == CatReactionType.slapPlayer1 ||
        reactionType == CatReactionType.slapPlayer2) {
      // Furious angled eyes ( \ / )
      canvas.drawCircle(leftEyeCenter, radius * 0.1, eyePaint);
      canvas.drawCircle(rightEyeCenter, radius * 0.1, eyePaint);

      // Angled angry brows
      canvas.drawLine(
        Offset(leftEyeCenter.dx - 14, leftEyeCenter.dy - 16),
        Offset(leftEyeCenter.dx + 12, leftEyeCenter.dy - 8),
        linePaint..strokeWidth = 3.5,
      );
      canvas.drawLine(
        Offset(rightEyeCenter.dx + 14, rightEyeCenter.dy - 16),
        Offset(rightEyeCenter.dx - 12, rightEyeCenter.dy - 8),
        linePaint..strokeWidth = 3.5,
      );
      linePaint.strokeWidth = 2.5; // restore
    } else {
      // Normal cute round glossy eyes
      canvas.drawCircle(leftEyeCenter, radius * 0.12, eyePaint);
      canvas.drawCircle(rightEyeCenter, radius * 0.12, eyePaint);
      // Highlights
      canvas.drawCircle(
        Offset(leftEyeCenter.dx - 3, leftEyeCenter.dy - 3),
        radius * 0.04,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx - 3, rightEyeCenter.dy - 3),
        radius * 0.04,
        Paint()..color = Colors.white,
      );
    }

    // Rosy Cheeks
    final cheekPaint = Paint()
      ..color = AppColors.catCheeks.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(leftEyeCenter.dx - 8, leftEyeCenter.dy + 16),
        width: 16,
        height: 10,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rightEyeCenter.dx + 8, rightEyeCenter.dy + 16),
        width: 16,
        height: 10,
      ),
      cheekPaint,
    );

    // Cute Triangle Nose
    final noseCenter = Offset(center.dx, center.dy + radius * 0.08);
    final nosePath = Path()
      ..moveTo(noseCenter.dx - 6, noseCenter.dy - 4)
      ..lineTo(noseCenter.dx + 6, noseCenter.dy - 4)
      ..lineTo(noseCenter.dx, noseCenter.dy + 3)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // Mouth
    final mouthPath = Path()
      ..moveTo(noseCenter.dx - 10, noseCenter.dy + 10)
      ..quadraticBezierTo(noseCenter.dx - 5, noseCenter.dy + 14, noseCenter.dx, noseCenter.dy + 6)
      ..quadraticBezierTo(noseCenter.dx + 5, noseCenter.dy + 14, noseCenter.dx + 10, noseCenter.dy + 10);
    canvas.drawPath(mouthPath, linePaint);

    // Whiskers
    _drawWhiskers(canvas, center, radius, linePaint);
  }

  void _drawWhiskers(Canvas canvas, Offset center, double radius, Paint paint) {
    paint.strokeWidth = 1.8;
    final leftOrigin = Offset(center.dx - radius * 0.45, center.dy + radius * 0.12);
    final rightOrigin = Offset(center.dx + radius * 0.45, center.dy + radius * 0.12);

    // Left whiskers
    canvas.drawLine(leftOrigin, Offset(leftOrigin.dx - 22, leftOrigin.dy - 6), paint);
    canvas.drawLine(leftOrigin, Offset(leftOrigin.dx - 25, leftOrigin.dy + 4), paint);
    canvas.drawLine(leftOrigin, Offset(leftOrigin.dx - 20, leftOrigin.dy + 14), paint);

    // Right whiskers
    canvas.drawLine(rightOrigin, Offset(rightOrigin.dx + 22, rightOrigin.dy - 6), paint);
    canvas.drawLine(rightOrigin, Offset(rightOrigin.dx + 25, rightOrigin.dy + 4), paint);
    canvas.drawLine(rightOrigin, Offset(rightOrigin.dx + 20, rightOrigin.dy + 14), paint);
  }

  void _drawPaws(Canvas canvas, Offset center, double radius, double slapProgress) {
    final pawPaint = Paint()..color = AppColors.catBody;
    final padPaint = Paint()..color = AppColors.catCheeks;

    if (reactionType == CatReactionType.slapPlayer1) {
      // Strike left paw forward aggressively
      final strikeOffset = slapProgress * 40;
      final leftPaw = Offset(center.dx - radius * 0.65 - strikeOffset, center.dy + radius * 0.45);
      _drawSinglePaw(canvas, leftPaw, radius * 0.35, pawPaint, padPaint, true);

      // Resting right paw
      final rightPaw = Offset(center.dx + radius * 0.35, center.dy + radius * 0.6);
      _drawSinglePaw(canvas, rightPaw, radius * 0.22, pawPaint, padPaint, false);
    } else if (reactionType == CatReactionType.slapPlayer2) {
      // Strike right paw forward aggressively
      final strikeOffset = slapProgress * 40;
      final rightPaw = Offset(center.dx + radius * 0.65 + strikeOffset, center.dy + radius * 0.45);
      _drawSinglePaw(canvas, rightPaw, radius * 0.35, pawPaint, padPaint, true);

      // Resting left paw
      final leftPaw = Offset(center.dx - radius * 0.35, center.dy + radius * 0.6);
      _drawSinglePaw(canvas, leftPaw, radius * 0.22, pawPaint, padPaint, false);
    } else if (reactionType == CatReactionType.doublePawAngry) {
      // DOUBLE PAW SLAM into the screen
      final strikeScale = 1.0 + slapProgress * 0.4;
      final leftPaw = Offset(center.dx - radius * 0.55, center.dy + radius * 0.5);
      final rightPaw = Offset(center.dx + radius * 0.55, center.dy + radius * 0.5);

      _drawSinglePaw(canvas, leftPaw, radius * 0.32 * strikeScale, pawPaint, padPaint, true);
      _drawSinglePaw(canvas, rightPaw, radius * 0.32 * strikeScale, pawPaint, padPaint, true);
    } else {
      // Normal cute resting paws on chest/belly
      final leftPaw = Offset(center.dx - radius * 0.35, center.dy + radius * 0.65);
      final rightPaw = Offset(center.dx + radius * 0.35, center.dy + radius * 0.65);

      _drawSinglePaw(canvas, leftPaw, radius * 0.22, pawPaint, padPaint, false);
      _drawSinglePaw(canvas, rightPaw, radius * 0.22, pawPaint, padPaint, false);
    }
  }

  void _drawSinglePaw(
    Canvas canvas,
    Offset position,
    double pawRadius,
    Paint pawPaint,
    Paint padPaint,
    bool showPads,
  ) {
    // Main paw ball
    canvas.drawCircle(position, pawRadius, pawPaint);

    if (showPads) {
      // Center pink heart/bean pad
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(position.dx, position.dy + pawRadius * 0.1),
          width: pawRadius * 0.9,
          height: pawRadius * 0.65,
        ),
        padPaint,
      );
      // 3 cute toe beans
      canvas.drawCircle(Offset(position.dx - pawRadius * 0.5, position.dy - pawRadius * 0.4), pawRadius * 0.22, padPaint);
      canvas.drawCircle(Offset(position.dx, position.dy - pawRadius * 0.6), pawRadius * 0.22, padPaint);
      canvas.drawCircle(Offset(position.dx + pawRadius * 0.5, position.dy - pawRadius * 0.4), pawRadius * 0.22, padPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CatVectorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.reactionType != reactionType;
  }
}
