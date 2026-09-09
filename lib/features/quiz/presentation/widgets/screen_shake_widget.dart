import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Screen shake wrapper triggered during cat slap reactions.
class ScreenShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shouldShake;
  final bool isDoubleSlap;

  const ScreenShakeWidget({
    super.key,
    required this.child,
    required this.shouldShake,
    this.isDoubleSlap = false,
  });

  @override
  State<ScreenShakeWidget> createState() => _ScreenShakeWidgetState();
}

class _ScreenShakeWidgetState extends State<ScreenShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    if (widget.shouldShake) {
      _triggerShake();
    }
  }

  @override
  void didUpdateWidget(covariant ScreenShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _triggerShake();
    }
  }

  void _triggerShake() {
    _controller.forward(from: 0.0);
    if (widget.isDoubleSlap) {
      HapticUtils.doubleSlap();
    } else {
      HapticUtils.heavy();
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
        if (!_controller.isAnimating) {
          return widget.child;
        }

        // Decaying damped sine oscillation
        final decay = 1.0 - _controller.value;
        final intensity = widget.isDoubleSlap ? 20.0 : 12.0;
        final offsetX = math.sin(_controller.value * 24 * math.pi) * intensity * decay;
        final offsetY = math.cos(_controller.value * 18 * math.pi) * (intensity * 0.6) * decay;

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: widget.child,
        );
      },
    );
  }
}
