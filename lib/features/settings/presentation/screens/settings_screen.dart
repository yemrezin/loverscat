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
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
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
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: onlineState.isConnected
                      ? const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)])
                      : const LinearGradient(colors: [Color(0xFFFF1744), Color(0xFFD50000)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (onlineState.isConnected ? AppColors.successGreen : AppColors.angryRed).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      onlineState.isConnected ? 'Çevrimiçi' : 'Çevrimdışı',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF2F5), Color(0xFFFFF8F2), Color(0xFFFBF4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Rumuz & Profil Card
                ProfileSettingsCard(
                  ref: ref,
                  onlineState: onlineState,
                ),
                const SizedBox(height: 16),

                // 2. Partner Connection Card (if paired)
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
                _buildLogoutCard(context, notifier),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context, OnlineController notifier) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.cardWhiteGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12FF1493),
            blurRadius: 16,
            offset: Offset(0, 5),
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
                  color: AppColors.angryRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🚪', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hesap & Çıkış',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Mevcut hesabınızdan güvenli şekilde çıkış yapın.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF1744), Color(0xFFFF5252)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.angryRed.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  HapticUtils.heavy();
                  notifier.logout();
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Hesaptan Çıkış Yap',
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
