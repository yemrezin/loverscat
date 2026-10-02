import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loverscat/core/constants/app_colors.dart';
import 'package:loverscat/core/utils/haptic_utils.dart';
import 'package:loverscat/features/online/controllers/online_controller.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/pet/presentation/widgets/pet_display_widget.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AvatarManagerSheet(ref: ref),
    );
  }
}

class _AvatarManagerSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AvatarManagerSheet({required this.ref});

  @override
  State<_AvatarManagerSheet> createState() => _AvatarManagerSheetState();
}

class _AvatarManagerSheetState extends State<_AvatarManagerSheet> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      final success = await widget.ref
          .read(onlineProvider.notifier)
          .uploadCustomAvatar(base64String);

      if (mounted) {
        setState(() => _isUploading = false);
        if (success) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf yüklenemedi: $e'),
            backgroundColor: AppColors.angryRed,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _isUploading = true);
    final success = await widget.ref.read(onlineProvider.notifier).removeCustomAvatar();
    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _selectPet(PetType petType) async {
    HapticUtils.light();
    final notifier = widget.ref.read(onlineProvider.notifier);
    // If user has custom photo, remove it and switch to pet
    final user = widget.ref.read(onlineProvider).user;
    if (user.customAvatarBase64 != null) {
      await notifier.removeCustomAvatar();
    }
    await notifier.updatePet(petType);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlineState = widget.ref.watch(onlineProvider);
    final user = onlineState.user;
    final hasPhoto = user.customAvatarBase64 != null && user.customAvatarBase64!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.player1Badge.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Text('📸', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Fotoğrafı & Karakter',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Kendi fotoğrafını yükleyebilir veya karakter seçebilirsin',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Current Avatar Preview
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CoupleCircleAvatar(
                  username: user.username,
                  petType: user.petType,
                  customAvatarBase64: user.customAvatarBase64,
                  size: 110,
                  borderColor: AppColors.player1Badge,
                  isEditable: false,
                ),
                if (_isUploading)
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasPhoto ? '✅ Kendi fotoğrafını kullanıyorsun' : '🐾 Sevimli karakterini kullanıyorsun',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Action 1: Upload Photo from Gallery
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickAndUploadImage,
            icon: const Icon(Icons.photo_library_rounded, size: 20),
            label: Text(
              hasPhoto ? 'Farklı Bir Fotoğraf Seç' : 'Galeriden Kendi Fotoğrafını Yükle',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.player1Badge,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 10),

          // Action 2: Remove photo if exists
          if (hasPhoto) ...[
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _removePhoto,
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.angryRed),
              label: const Text(
                'Fotoğrafı Kaldır & Karaktere Dön',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.angryRed),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                side: const BorderSide(color: AppColors.angryRed, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          const Divider(height: 24),

          // Action 3: Or choose a pet character
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Veya Sevimli Bir Karakter Seç:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: PetType.values.map((type) {
              final isCurrent = !hasPhoto && user.petType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _selectPet(type),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? type.primaryColor.withOpacity(0.2)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent ? type.primaryColor : Colors.grey.shade300,
                        width: isCurrent ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(type.headAssetPath, width: 34, height: 34),
                        const SizedBox(height: 3),
                        Text(
                          type.displayName.split(' ')[0],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Bilgilendirme: Rumuz değişimi Ayarlar'dan yapılır
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Text('⚙️', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rumuz (kullanıcı adı) değişimi sadece Ayarlar sayfasından yapılmaktadır.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
