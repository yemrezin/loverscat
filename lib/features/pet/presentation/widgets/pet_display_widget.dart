import 'package:flutter/material.dart';
import '../../domain/models/pet_avatar.dart';

/// Renders the chosen Pet character illustration (Cat, Rabbit, Fox, Cheese)
/// with a gentle floating / breathing animation and soft drop shadow.
class PetDisplayWidget extends StatefulWidget {
  final PetType petType;
  final double size;
  final bool animate;

  const PetDisplayWidget({
    super.key,
    required this.petType,
    this.size = 190,
    this.animate = true,
  });

  @override
  State<PetDisplayWidget> createState() => _PetDisplayWidgetState();
}

class _PetDisplayWidgetState extends State<PetDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PetDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
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
        final progress = Curves.easeInOut.transform(_controller.value);
        final floatY = widget.animate ? progress * 6.0 : 0.0;
        final scale = widget.animate ? 1.0 + (progress * 0.02) : 1.0;

        return SizedBox(
          width: widget.size * 1.05,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft ground shadow underneath
              Positioned(
                bottom: 2,
                child: Container(
                  width: widget.size * 0.52 * scale,
                  height: widget.size * 0.10,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.09),
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(widget.size * 0.52, widget.size * 0.10),
                    ),
                  ),
                ),
              ),
              // Floating Pet Illustration
              Positioned(
                bottom: 8 + floatY,
                child: Transform.scale(
                  scale: scale,
                  child: Image.asset(
                    widget.petType.fullAssetPath,
                    width: widget.size * 0.92,
                    height: widget.size * 0.88,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          widget.petType.emoji,
                          style: TextStyle(fontSize: widget.size * 0.45),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Circular head avatar widget for the chosen pet (Cat, Rabbit, Fox, Cheese).
/// Used in the board squares so ONLY the head is visible in each square.
class PetHeadAvatarWidget extends StatelessWidget {
  final PetType petType;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final bool showShadow;

  const PetHeadAvatarWidget({
    super.key,
    required this.petType,
    this.size = 28,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.38),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 1.5),
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          petType.headAssetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                petType.emoji,
                style: TextStyle(fontSize: size * 0.55),
              ),
            );
          },
        ),
      ),
    );
  }
}
