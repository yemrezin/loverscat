import 'package:flutter/material.dart';
import '../../domain/models/cat_reaction.dart';
import 'cat_vector_painter.dart';

export 'cat_vector_painter.dart';

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
            painter: CatVectorPainter(
              progress: _controller.value,
              reactionType: widget.reaction.type,
            ),
          ),
        );
      },
    );
  }
}
