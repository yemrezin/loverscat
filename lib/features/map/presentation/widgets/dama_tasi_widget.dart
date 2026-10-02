import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../pet/domain/models/pet_avatar.dart';

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
