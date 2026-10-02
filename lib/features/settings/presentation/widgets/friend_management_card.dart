import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../online/controllers/online_controller.dart';
import '../../../profile/domain/models/user_profile.dart';

/// Section card for searching friends, quick pick registered users, and managing requests.
class FriendManagementCard extends StatefulWidget {
  final OnlineState onlineState;
  final OnlineController notifier;
  final List<UserProfile> allUsers;
  final bool loadingUsers;
  final VoidCallback onRefreshUsers;

  const FriendManagementCard({
    super.key,
    required this.onlineState,
    required this.notifier,
    required this.allUsers,
    required this.loadingUsers,
    required this.onRefreshUsers,
  });

  @override
  State<FriendManagementCard> createState() => _FriendManagementCardState();
}

class _FriendManagementCardState extends State<FriendManagementCard> {
  late TextEditingController _friendUsernameController;

  @override
  void initState() {
    super.initState();
    _friendUsernameController = TextEditingController();
  }

  @override
  void dispose() {
    _friendUsernameController.dispose();
    super.dispose();
  }

  void _sendRequest() {
    final text = _friendUsernameController.text.trim();
    if (text.isNotEmpty) {
      HapticUtils.medium();
      widget.notifier.sendFriendRequest(text);
      _friendUsernameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlineState = widget.onlineState;
    final notifier = widget.notifier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Send Request Form
        _buildContainer(
          title: '💌 Arkadaş Ekle',
          subtitle: 'Arkadaşının @kullanıcı_adı bilgisini girerek anında istek gönder.',
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _friendUsernameController,
                    decoration: InputDecoration(
                      hintText: 'kullanıcı_adı (örn: gizem_99)',
                      prefixText: '@ ',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        borderSide: const BorderSide(color: AppColors.catBody, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _sendRequest(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.catBody,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('İstek Gönder', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (widget.allUsers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Veritabanındaki Kayıtlı Oyuncular (Hızlı Seçim):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      HapticUtils.light();
                      widget.onRefreshUsers();
                    },
                    child: Row(
                      children: [
                        if (widget.loadingUsers)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        const Text('Yenile', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.allUsers
                    .where((u) => u.username.toLowerCase() != onlineState.user.username.toLowerCase())
                    .map((u) {
                  return ActionChip(
                    avatar: Image.asset(u.petType.headAssetPath, width: 22, height: 22),
                    label: Text(
                      '@${u.username}${u.isOnline ? " 🟢" : ""}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: u.isOnline ? const Color(0xFF52B788) : AppColors.borderSubtle,
                      width: u.isOnline ? 1.5 : 1,
                    ),
                    onPressed: () {
                      HapticUtils.light();
                      _friendUsernameController.text = u.username;
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),

        // 2. Incoming Requests
        if (onlineState.incomingRequests.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildContainer(
            title: '📬 Gelen Arkadaşlık İstekleri (${onlineState.incomingRequests.length})',
            subtitle: 'Seni arkadaş olarak eklemek isteyenler:',
            borderColor: const Color(0xFF52B788),
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: onlineState.incomingRequests.length,
                separatorBuilder: (_, __) => const Divider(height: 14),
                itemBuilder: (context, index) {
                  final req = onlineState.incomingRequests[index];
                  return Row(
                    children: [
                      Image.asset(req.fromPetType.headAssetPath, width: 36, height: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '@${req.fromUsername}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          HapticUtils.heavy();
                          notifier.respondFriendRequest(req.id, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D6A4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Kabul Et', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.angryRed, size: 20),
                        onPressed: () {
                          HapticUtils.light();
                          notifier.respondFriendRequest(req.id, false);
                        },
                        tooltip: 'Reddet',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],

        // 3. Sent Pending Requests
        if (onlineState.sentRequests.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildContainer(
            title: '📤 Gönderilen Bekleyen İstekler (${onlineState.sentRequests.length})',
            subtitle: 'Karşı tarafın kabul etmesi bekleniyor:',
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: onlineState.sentRequests.length,
                separatorBuilder: (_, __) => const Divider(height: 14),
                itemBuilder: (context, index) {
                  final req = onlineState.sentRequests[index];
                  return Row(
                    children: [
                      const Icon(Icons.hourglass_top_rounded, color: AppColors.pastelYellow, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '@${req.toUsername}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const Text(
                        'Bekleniyor...',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContainer({
    required String title,
    required String subtitle,
    Color? borderColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor ?? AppColors.borderSubtle, width: borderColor != null ? 1.8 : 1.5),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}
