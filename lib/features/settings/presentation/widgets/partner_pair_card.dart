import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../online/controllers/online_controller.dart';

/// Section card for displaying the active paired partner with vibrant glowing connection visuals.
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('💔', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Partner Bağlantısını Kes?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          ],
        ),
        content: Text(
          '${onlineState.partner?.formattedUsername ?? "Partnerin"} ile olan eşleşmeniz sonlandırılacak. Tekrar oynamak için yeni arkadaşlık isteği göndermeniz gerekecek.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.unpair();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.angryRed,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            child: const Text('Evet, Ayrıl', style: TextStyle(fontWeight: FontWeight.w900)),
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
        gradient: AppColors.cardWhiteGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.player1Badge.withOpacity(0.4), width: 1.8),
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
                child: const Text('💕', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eşleşilen Partner',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Birbirinizi kabul ettiniz ve ortak odadasınız.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.borderSubtle),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.player1Badge.withOpacity(0.12),
                  AppColors.player2Badge.withOpacity(0.14),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.player1Badge.withOpacity(0.35), width: 1.5),
            ),
            child: Row(
              children: [
                // My Side
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.player1Badge, width: 2),
                          color: Colors.white,
                        ),
                        child: Image.asset(onlineState.user.petType.headAssetPath, width: 44, height: 44),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        onlineState.user.formattedUsername,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: AppColors.player1Badge,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Heart Connection Icon with Radiant Glow
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33FF1493),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text('💞', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroPinkGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Birlikte',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                // Partner Side
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.player2Badge, width: 2),
                          color: Colors.white,
                        ),
                        child: Image.asset(onlineState.partner!.petType.headAssetPath, width: 44, height: 44),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        onlineState.partner!.formattedUsername,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: AppColors.player2Badge,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: onlineState.partner!.isOnline ? AppColors.successGreen : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            onlineState.partner!.isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: onlineState.partner!.isOnline ? const Color(0xFF00A854) : Colors.grey.shade600,
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
          const SizedBox(height: 14),

          // Unpair Button
          OutlinedButton.icon(
            onPressed: () => _showUnpairConfirmDialog(context),
            icon: const Icon(Icons.link_off_rounded, size: 16, color: AppColors.angryRed),
            label: const Text('Partner Bağlantısını Kes', style: TextStyle(color: AppColors.angryRed, fontSize: 13, fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.angryRed.withOpacity(0.5), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
