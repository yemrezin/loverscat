import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../online/controllers/online_controller.dart';
import '../../../pet/domain/models/pet_avatar.dart';
import '../../../profile/presentation/widgets/couple_circle_avatar.dart';

/// Section Card for editing username (rumuz), pet type, and avatar photo.
class ProfileSettingsCard extends StatefulWidget {
  final WidgetRef ref;
  final OnlineState onlineState;

  const ProfileSettingsCard({
    super.key,
    required this.ref,
    required this.onlineState,
  });

  @override
  State<ProfileSettingsCard> createState() => _ProfileSettingsCardState();
}

class _ProfileSettingsCardState extends State<ProfileSettingsCard> {
  late TextEditingController _usernameController;
  PetType? _selectedPet;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.onlineState.user.username);
    _selectedPet = widget.onlineState.user.petType;
  }

  @override
  void didUpdateWidget(covariant ProfileSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onlineState.user.username != widget.onlineState.user.username) {
      _usernameController.text = widget.onlineState.user.username;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onlineState = widget.onlineState;
    final notifier = widget.ref.read(onlineProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '👤 Rumuz (Kullanıcı Adı) & Profil',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rumuzunuz benzersizdir ve oyundaki kimliğinizdir. Rumuzunuzu sadece bu ekrandan değiştirebilirsiniz.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const Divider(height: 24),

          // Avatar with Rumuz fixed inside & Photo Picker
          Center(
            child: CoupleCircleAvatar(
              username: onlineState.user.username,
              petType: _selectedPet ?? onlineState.user.petType,
              customAvatarBase64: onlineState.user.customAvatarBase64,
              size: 100,
              borderColor: AppColors.player1Badge,
              isEditable: true,
              onTap: () {
                HapticUtils.light();
                CoupleCircleAvatar.showAvatarManagerModal(context, widget.ref);
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                HapticUtils.light();
                CoupleCircleAvatar.showAvatarManagerModal(context, widget.ref);
              },
              icon: const Icon(Icons.photo_camera_rounded, size: 16, color: AppColors.player1Badge),
              label: Text(
                onlineState.user.customAvatarBase64 != null
                    ? 'Fotoğrafı Değiştir / Kaldır'
                    : 'Fotoğraf Yükle veya Karakter Değiştir',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.player1Badge),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Unique Username (Rumuz) Field
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Benzersiz Rumuz (Kullanıcı Adı)',
              hintText: 'örn: kedi_kralice',
              prefixText: '@ ',
              prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.player1Badge, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.player1Badge, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pet / Rumuz Picker
          const Text(
            'Hayvan / Rumuz Seçimi:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: PetType.values.map((type) {
              final isSelected = (_selectedPet ?? onlineState.user.petType) == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.light();
                    setState(() {
                      _selectedPet = type;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? type.primaryColor.withOpacity(0.2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? type.primaryColor : AppColors.borderSubtle,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Image.asset(type.headAssetPath, width: 36, height: 36),
                        const SizedBox(height: 4),
                        Text(
                          type.displayName.split(' ')[0],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Save Profile Button
          ElevatedButton.icon(
            onPressed: () {
              HapticUtils.medium();
              notifier.updateProfile(
                newUsername: _usernameController.text,
                petType: _selectedPet,
              );
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('Rumuz & Bilgileri Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.player1Badge,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
