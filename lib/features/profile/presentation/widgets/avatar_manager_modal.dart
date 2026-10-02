import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../online/controllers/online_controller.dart';
import '../../../pet/domain/models/pet_avatar.dart';
import 'couple_circle_avatar.dart';

/// Modal bottom sheet allowing users to upload a custom avatar photo,
/// switch between pet characters, or remove their custom photo.
class AvatarManagerModal extends StatefulWidget {
  final WidgetRef ref;

  const AvatarManagerModal({super.key, required this.ref});

  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvatarManagerModal(ref: ref),
    );
  }

  @override
  State<AvatarManagerModal> createState() => _AvatarManagerModalState();
}

class _AvatarManagerModalState extends State<AvatarManagerModal> {
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

          // Rumuz değişimi Ayarlar sayfasında yapılır bildirimi
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
