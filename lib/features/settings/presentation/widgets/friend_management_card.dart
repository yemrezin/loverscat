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
          icon: '💌',
          title: 'Arkadaş Ekle',
          subtitle: 'Arkadaşının @kullanıcı_adı bilgisini girerek anında istek gönder.',
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _friendUsernameController,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'kullanıcı_adı (örn: gizem_99)',
                      prefixText: '@ ',
                      prefixStyle: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.player1Badge, fontSize: 16),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    onSubmitted: (_) => _sendRequest(),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.vibrantOrangeGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.catBody.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _sendRequest,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Text(
                          'İstek Gönder',
                          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.allUsers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kayıtlı Oyuncular (Hızlı Seç):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      HapticUtils.light();
                      widget.onRefreshUsers();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        children: [
                          if (widget.loadingUsers)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.refresh_rounded, size: 16, color: AppColors.player1Badge),
                          const SizedBox(width: 4),
                          const Text('Yenile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.player1Badge)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.allUsers
                    .where((u) => u.username.toLowerCase() != onlineState.user.username.toLowerCase())
                    .map((u) {
                  return ActionChip(
                    avatar: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: u.isOnline ? AppColors.successGreen : AppColors.borderSubtle,
                          width: 1.5,
                        ),
                      ),
                      child: Image.asset(u.petType.headAssetPath, width: 22, height: 22),
                    ),
                    label: Text(
                      '@${u.username}${u.isOnline ? " 🟢" : ""}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: u.isOnline ? const Color(0xFF007A3D) : AppColors.textPrimary,
                      ),
                    ),
                    backgroundColor: u.isOnline ? const Color(0xFFE8FDF3) : Colors.white,
                    side: BorderSide(
                      color: u.isOnline ? AppColors.successGreen : AppColors.borderSubtle,
                      width: u.isOnline ? 1.8 : 1.2,
                    ),
                    elevation: 1,
                    shadowColor: u.isOnline ? AppColors.successGreen.withOpacity(0.2) : Colors.black12,
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
            icon: '📬',
            title: 'Gelen Arkadaşlık İstekleri (${onlineState.incomingRequests.length})',
            subtitle: 'Seni arkadaş olarak eklemek isteyenler:',
            borderColor: AppColors.successGreen,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: onlineState.incomingRequests.length,
                separatorBuilder: (_, __) => const Divider(height: 16, color: AppColors.borderSubtle),
                itemBuilder: (context, index) {
                  final req = onlineState.incomingRequests[index];
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.player2Badge, width: 2),
                          color: Colors.white,
                        ),
                        child: Image.asset(req.fromPetType.headAssetPath, width: 36, height: 36),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '@${req.fromUsername}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(color: Color(0x3300E676), blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              HapticUtils.heavy();
                              notifier.respondFriendRequest(req.id, true);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Text('Kabul Et', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.angryRed, size: 22),
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
            icon: '📤',
            title: 'Gönderilen Bekleyen İstekler (${onlineState.sentRequests.length})',
            subtitle: 'Karşı tarafın kabul etmesi bekleniyor:',
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: onlineState.sentRequests.length,
                separatorBuilder: (_, __) => const Divider(height: 14, color: AppColors.borderSubtle),
                itemBuilder: (context, index) {
                  final req = onlineState.sentRequests[index];
                  return Row(
                    children: [
                      const Text('⏳', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '@${req.toUsername}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFEEBA)),
                        ),
                        child: const Text(
                          'Cevap Bekleniyor',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                        ),
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
    required String icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardWhiteGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor ?? AppColors.player1Badge.withOpacity(0.35),
          width: 1.8,
        ),
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
                child: Text(icon, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.borderSubtle),
          ...children,
        ],
      ),
    );
  }
}
