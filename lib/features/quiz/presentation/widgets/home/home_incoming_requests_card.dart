import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../../profile/domain/models/friend_request.dart';
import '../../../../online/controllers/online_controller.dart';

/// Notification card displaying list of incoming friend requests with accept/reject buttons.
class HomeIncomingRequestsCard extends StatelessWidget {
  final WidgetRef ref;
  final List<FriendRequest> requests;

  const HomeIncomingRequestsCard({
    super.key,
    required this.ref,
    required this.requests,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(onlineProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.player1Badge, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18FF3366),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('💌', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Yeni Arkadaşlık İsteği!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.player1Badge,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.player1Badge,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${requests.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...requests.map((req) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.pastelPink),
              ),
              child: Row(
                children: [
                  Image.asset(req.fromPetType.headAssetPath, width: 40, height: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${req.fromUsername}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Sana arkadaşlık isteği gönderdi ✨',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    onPressed: () {
                      HapticUtils.heavy();
                      notifier.respondFriendRequest(req.id, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kabul Et 💖',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.angryRed, size: 20),
                    tooltip: 'Reddet',
                    onPressed: () {
                      HapticUtils.light();
                      notifier.respondFriendRequest(req.id, false);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
