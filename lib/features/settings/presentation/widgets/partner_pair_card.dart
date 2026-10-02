import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../online/controllers/online_controller.dart';

/// Section card for displaying the active paired partner and allowing unpairing.
class PartnerPairCard extends StatelessWidget {
  final OnlineState onlineState;
  final OnlineController notifier;

  const PartnerPairCard({
    super.key,
    required this.onlineState,
    required this.notifier,
  });

  void _showUnpairConfirmDialog(BuildContext context) {
    HapticUtils.heavy();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Partner Bağlantısını Kes?'),
        content: Text(
          '${onlineState.partner?.formattedUsername ?? "Partnerin"} ile olan eşleşmeniz sonlandırılacak. Tekrar oynamak için yeni arkadaşlık isteği göndermeniz gerekecek.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.unpair();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.angryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Evet, Ayrıl'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!onlineState.isPaired) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.player1Badge, width: 1.8),
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
            '💕 Eşleşilen Partner',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Birbirinizi kabul ettiniz ve ortak odadasınız.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.pastelPink.withOpacity(0.4),
                  AppColors.pastelMint.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.player1Badge.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                // My Side
                Expanded(
                  child: Column(
                    children: [
                      Image.asset(onlineState.user.petType.headAssetPath, width: 44, height: 44),
                      const SizedBox(height: 4),
                      Text(
                        onlineState.user.formattedUsername,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.player1Badge,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Heart Connection Icon
                const Column(
                  children: [
                    Text('💞', style: TextStyle(fontSize: 26)),
                    SizedBox(height: 2),
                    Text('Birlikte', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.player1Badge)),
                  ],
                ),

                // Partner Side
                Expanded(
                  child: Column(
                    children: [
                      Image.asset(onlineState.partner!.petType.headAssetPath, width: 44, height: 44),
                      const SizedBox(height: 4),
                      Text(
                        onlineState.partner!.formattedUsername,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.player2Badge,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: onlineState.partner!.isOnline ? const Color(0xFF2D6A4F) : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            onlineState.partner!.isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: onlineState.partner!.isOnline ? const Color(0xFF2D6A4F) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Unpair Button
          OutlinedButton.icon(
            onPressed: () => _showUnpairConfirmDialog(context),
            icon: const Icon(Icons.link_off_rounded, size: 16, color: AppColors.angryRed),
            label: const Text('Partner Bağlantısını Kes', style: TextStyle(color: AppColors.angryRed, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.angryRed.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
