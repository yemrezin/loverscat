import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/pet/presentation/widgets/pet_display_widget.dart';
import 'avatar_manager_modal.dart';

/// Reusable circular avatar that keeps the username/rumuz fixed INSIDE the circle,
/// supports either a custom photo (Base64) or pet character, and provides
/// one-tap image upload or character selection.
class CoupleCircleAvatar extends StatelessWidget {
  final String username;
  final PetType petType;
  final String? customAvatarBase64;
  final double size;
  final Color borderColor;
  final VoidCallback? onTap;
  final bool isEditable;
  final bool? isOnline;

  const CoupleCircleAvatar({
    super.key,
    required this.username,
    required this.petType,
    this.customAvatarBase64,
    this.size = 96,
    required this.borderColor,
    this.onTap,
    this.isEditable = false,
    this.isOnline,
  });

  String get formattedUsername => username.startsWith('@') ? username : '@$username';

  @override
  Widget build(BuildContext context) {
    final hasCustomPhoto = customAvatarBase64 != null && customAvatarBase64!.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Main Circular Container with Fixed Inside Rumuz
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: borderColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // 1. Avatar Content (Photo or Pet)
                  if (hasCustomPhoto)
                    Image.memory(
                      base64Decode(customAvatarBase64!),
                      fit: BoxFit.cover,
                      width: size,
                      height: size,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade100,
                        child: PetDisplayWidget(
                          petType: petType,
                          size: size * 0.9,
                          animate: false,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: petType.primaryColor.withOpacity(0.12),
                      alignment: Alignment.center,
                      child: PetDisplayWidget(
                        petType: petType,
                        size: size * 0.95,
                        animate: false,
                      ),
                    ),

                  // 2. Fixed Inside Rumuz Dock (Bottom Gradient Overlay)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: size * 0.12,
                        bottom: size * 0.04,
                        left: 4,
                        right: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                            Colors.black.withOpacity(0.85),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                      child: Text(
                        formattedUsername,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size < 110 ? 11 : 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Online Status Dot if specified
          if (isOnline != null)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: isOnline! ? const Color(0xFF00C49F) : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),

          // Camera / Edit Badge for Self Avatar
          if (isEditable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Opens the modal sheet where user can upload a custom photo,
  /// switch to animal pet avatars, or remove their custom photo.
  static void showAvatarManagerModal(BuildContext context, WidgetRef ref) {
    AvatarManagerModal.show(context, ref);
  }
}
