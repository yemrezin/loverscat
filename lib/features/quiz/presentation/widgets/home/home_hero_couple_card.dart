import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../../online/controllers/online_controller.dart';
import '../../../../map/presentation/controllers/map_providers.dart';
import '../../../../pet/domain/models/pet_avatar.dart';
import '../../../../profile/presentation/widgets/couple_circle_avatar.dart';
import '../../../../settings/presentation/screens/settings_screen.dart';

/// Hero display presenting either the paired couple or single player pet avatar with invitation prompt.
class HomeHeroCoupleCard extends StatelessWidget {
  final WidgetRef ref;
  final OnlineState onlineState;
  final MapState mapState;
  final PetAvatar pet;

  const HomeHeroCoupleCard({
    super.key,
    required this.ref,
    required this.onlineState,
    required this.mapState,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    if (onlineState.isPaired) {
      return _buildOnlineCoupleCard(context);
    } else {
      return _buildSinglePetWithInvite(context);
    }
  }

  Widget _buildOnlineCoupleCard(BuildContext context) {
    final user = onlineState.user;
    final partner = onlineState.partner!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.player1Badge, width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22FF2A6D),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Player 1 (You) with Rumuz fixed INSIDE the circle
              Expanded(
                child: Column(
                  children: [
                    CoupleCircleAvatar(
                      username: user.username,
                      petType: user.petType,
                      customAvatarBase64: user.customAvatarBase64,
                      size: 96,
                      borderColor: AppColors.player1Badge,
                      isEditable: true,
                      onTap: () {
                        HapticUtils.light();
                        CoupleCircleAvatar.showAvatarManagerModal(context, ref);
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.customAvatarBase64 != null ? '📸 Fotoğrafınız' : user.petType.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Center Love Connection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    const Text('💕', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: partner.isOnline ? const Color(0xFF00C49F) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (partner.isOnline)
                            const BoxShadow(
                              color: Color(0x3300C49F),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        partner.isOnline ? 'Bağlısınız 🟢' : 'Eşleşti ⚪',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: partner.isOnline ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Player 2 (Partner) with Rumuz fixed INSIDE the circle
              Expanded(
                child: Column(
                  children: [
                    CoupleCircleAvatar(
                      username: partner.username,
                      petType: partner.petType,
                      customAvatarBase64: partner.customAvatarBase64,
                      size: 96,
                      borderColor: AppColors.player2Badge,
                      isOnline: partner.isOnline,
                      isEditable: false,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      partner.customAvatarBase64 != null ? '📸 Fotoğrafı' : partner.petType.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF2A6D), Color(0xFFFF9F1C)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x25FF2A6D),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⛵', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Raftel Yolculuğuna Birlikte Hazırsınız! (Ada ${mapState.currentIsland}/10)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePetWithInvite(BuildContext context) {
    final user = onlineState.user;
    final hasPhoto = user.customAvatarBase64 != null && user.customAvatarBase64!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.player1Badge.withOpacity(0.5), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15FF2A6D),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: CoupleCircleAvatar(
              username: user.username,
              petType: pet.type,
              customAvatarBase64: user.customAvatarBase64,
              size: 130,
              borderColor: AppColors.player1Badge,
              isEditable: true,
              onTap: () {
                HapticUtils.light();
                CoupleCircleAvatar.showAvatarManagerModal(context, ref);
              },
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              HapticUtils.light();
              CoupleCircleAvatar.showAvatarManagerModal(context, ref);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.player1Badge.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.player1Badge.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasPhoto ? Icons.photo_camera_rounded : Icons.pets_rounded,
                    size: 15,
                    color: AppColors.player1Badge,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      hasPhoto ? 'Fotoğrafı Değiştir' : 'Fotoğraf / Karakter Değiştir',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.player1Badge,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              HapticUtils.light();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.vibrantPurpleGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x338338EC),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('💌', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Partnerini Ekle & Canlı Oyna ✨',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
