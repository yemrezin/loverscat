import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../online/controllers/online_controller.dart';
import '../../../pet/domain/models/pet_avatar.dart';
import '../../../profile/presentation/widgets/couple_circle_avatar.dart';

/// Section Card for editing username (rumuz), pet type, and avatar photo with vibrant candy visuals.
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
        gradient: AppColors.cardWhiteGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.player1Badge.withOpacity(0.35), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18FF1493),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.heroPinkGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.player1Badge.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text('👤', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rumuz (Kullanıcı Adı) & Profil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Rumuzunuz benzersizdir ve oyundaki kimliğinizdir.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.borderSubtle),

          // Avatar with Rumuz fixed inside & Photo Picker
          Center(
            child: CoupleCircleAvatar(
              username: onlineState.user.username,
              petType: _selectedPet ?? onlineState.user.petType,
              customAvatarBase64: onlineState.user.customAvatarBase64,
              size: 104,
              borderColor: AppColors.player1Badge,
              isEditable: true,
              onTap: () {
                HapticUtils.light();
                CoupleCircleAvatar.showAvatarManagerModal(context, widget.ref);
              },
            ),
          ),
          const SizedBox(height: 10),
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
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.player1Badge),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Unique Username (Rumuz) Field
          TextField(
            controller: _usernameController,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Benzersiz Rumuz (Kullanıcı Adı)',
              labelStyle: const TextStyle(color: AppColors.player1Badge, fontWeight: FontWeight.w700),
              hintText: 'örn: kedi_kralice',
              prefixText: '@ ',
              prefixStyle: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.player1Badge, fontSize: 16),
              prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.player1Badge, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.player1Badge, width: 2.2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pet / Rumuz Picker
          const Text(
            'Hayvan / Rumuz Seçimi:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
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
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                type.primaryColor.withOpacity(0.28),
                                type.primaryColor.withOpacity(0.12),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? type.primaryColor : AppColors.borderSubtle,
                        width: isSelected ? 2.5 : 1.4,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: type.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Image.asset(type.headAssetPath, width: 38, height: 38),
                        const SizedBox(height: 4),
                        Text(
                          type.displayName.split(' ')[0],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? type.primaryColor : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Save Profile Button with Vibrant Gradient
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.heroPinkGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.player1Badge.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  HapticUtils.medium();
                  notifier.updateProfile(
                    newUsername: _usernameController.text,
                    petType: _selectedPet,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Rumuz & Bilgileri Kaydet',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
