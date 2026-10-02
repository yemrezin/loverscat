import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:loverscat/core/constants/app_colors.dart';
import 'package:loverscat/core/utils/haptic_utils.dart';
import 'package:loverscat/features/online/controllers/online_controller.dart';
import 'package:loverscat/features/profile/domain/models/user_profile.dart';
import '../widgets/profile_settings_card.dart';
import '../widgets/partner_pair_card.dart';
import '../widgets/friend_management_card.dart';

/// Settings screen for configuring user profile / rumuz, pet avatar,
/// managing partner connection, searching friends, and logging out.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  List<UserProfile> _allUsers = [];
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    _loadRegisteredUsers();
  }

  Future<void> _loadRegisteredUsers() async {
    if (!mounted) return;
    setState(() => _loadingUsers = true);
    try {
      final serverUrl = ref.read(onlineProvider).serverUrl;
      final uri = Uri.parse('$serverUrl/api/users');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (mounted) {
          setState(() {
            _allUsers = list.map((e) => UserProfile.fromMap(e as Map<String, dynamic>)).toList();
            _loadingUsers = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loadingUsers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlineState = ref.watch(onlineProvider);
    final notifier = ref.read(onlineProvider.notifier);

    // Show snackbars for errors or status messages
    ref.listen<OnlineState>(onlineProvider, (prev, next) {
      if (next.lastError != null && next.lastError != prev?.lastError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.lastError!),
            backgroundColor: AppColors.angryRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next.statusMessage != null && next.statusMessage != prev?.statusMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.statusMessage!),
            backgroundColor: const Color(0xFF2D6A4F),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ayarlar & Arkadaş Ekle ⚙️',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: onlineState.isConnected
                      ? const Color(0xFFD8F3DC)
                      : const Color(0xFFFFE3E3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: onlineState.isConnected
                        ? const Color(0xFF52B788)
                        : const Color(0xFFE63946),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: onlineState.isConnected
                            ? const Color(0xFF2D6A4F)
                            : const Color(0xFFE63946),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      onlineState.isConnected ? 'Bağlı' : 'Çevrimdışı',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: onlineState.isConnected
                            ? const Color(0xFF2D6A4F)
                            : const Color(0xFFE63946),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Rumuz & Profil
              ProfileSettingsCard(
                ref: ref,
                onlineState: onlineState,
              ),
              const SizedBox(height: 16),

              // 2. Partner Connection Card
              if (onlineState.isPaired) ...[
                PartnerPairCard(
                  onlineState: onlineState,
                  notifier: notifier,
                ),
                const SizedBox(height: 16),
              ],

              // 3. Friend Management & Requests
              FriendManagementCard(
                onlineState: onlineState,
                notifier: notifier,
                allUsers: _allUsers,
                loadingUsers: _loadingUsers,
                onRefreshUsers: _loadRegisteredUsers,
              ),
              const SizedBox(height: 16),

              // 4. Logout Section Card
              Container(
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
                      '🚪 Hesap & Çıkış',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mevcut hesabınızdan güvenli şekilde çıkış yapın.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticUtils.heavy();
                        notifier.logout();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Hesaptan Çıkış Yap', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.angryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
