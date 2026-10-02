import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:loverscat/core/constants/app_colors.dart';
import 'package:loverscat/core/utils/haptic_utils.dart';
import 'package:loverscat/features/online/controllers/online_controller.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/profile/domain/models/user_profile.dart';
import 'package:loverscat/features/profile/presentation/widgets/couple_circle_avatar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _friendUsernameController;
  PetType? _selectedPet;
  List<UserProfile> _allUsers = [];
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    final online = ref.read(onlineProvider);
    _usernameController = TextEditingController(text: online.user.username);
    _friendUsernameController = TextEditingController();
    _selectedPet = online.user.petType;
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
  void dispose() {
    _usernameController.dispose();
    _friendUsernameController.dispose();
    super.dispose();
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
          // Connection status chip
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
              // 1. Rumuz (Kullanıcı Adı) Değiştirme ve Profil Ayarları
              _buildSectionCard(
                title: '👤 Rumuz (Kullanıcı Adı) & Profil',
                subtitle: 'Rumuzunuz benzersizdir ve oyundaki kimliğinizdir. Rumuzunuzu sadece bu ekrandan değiştirebilirsiniz.',
                children: [
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
                        CoupleCircleAvatar.showAvatarManagerModal(context, ref);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        HapticUtils.light();
                        CoupleCircleAvatar.showAvatarManagerModal(context, ref);
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
              const SizedBox(height: 16),

              // 2. Mevcut Partner Durumu (Eğer Eşleşilmişse)
              if (onlineState.isPaired)
                _buildSectionCard(
                  title: '💕 Eşleşilen Partner',
                  subtitle: 'Birbirinizi kabul ettiniz ve ortak odadasınız.',
                  borderColor: AppColors.player1Badge,
                  children: [
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
                      onPressed: () => _showUnpairConfirmDialog(context, notifier),
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
              if (onlineState.isPaired) const SizedBox(height: 16),

              // 3. Arkadaş Ekle (Discord / Instagram Tarzı Kullanıcı Adı ile)
              _buildSectionCard(
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
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              HapticUtils.medium();
                              notifier.sendFriendRequest(val);
                              _friendUsernameController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final text = _friendUsernameController.text.trim();
                          if (text.isNotEmpty) {
                            HapticUtils.medium();
                            notifier.sendFriendRequest(text);
                            _friendUsernameController.clear();
                          }
                        },
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
                  // Kayıtlı Kullanıcılar (Hızlı İstek Gönder)
                  if (_allUsers.isNotEmpty) ...[
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
                            _loadRegisteredUsers();
                          },
                          child: Row(
                            children: [
                              if (_loadingUsers)
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
                      children: _allUsers
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
              const SizedBox(height: 16),

              // 4. Gelen Arkadaşlık İstekleri
              if (onlineState.incomingRequests.isNotEmpty)
                _buildSectionCard(
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
                            // Accept button
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
                            // Reject button
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
              if (onlineState.incomingRequests.isNotEmpty) const SizedBox(height: 16),

              // 5. Gönderilen Bekleyen İstekler
              if (onlineState.sentRequests.isNotEmpty)
                _buildSectionCard(
                  title: '📤 Gönderilen İstekler',
                  subtitle: 'Karşı tarafın onaylamasını bekleyen istekleriniz:',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: onlineState.sentRequests.map((req) {
                        return Chip(
                          avatar: const Icon(Icons.hourglass_top_rounded, size: 14, color: AppColors.catBody),
                          label: Text('@${req.toUsername}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          backgroundColor: AppColors.pastelYellow.withOpacity(0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              if (onlineState.sentRequests.isNotEmpty) const SizedBox(height: 16),

              // 6. Çıkış Yap (Logout)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutConfirmDialog(context, notifier),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.angryRed, size: 18),
                  label: const Text(
                    'Hesaptan Çıkış Yap',
                    style: TextStyle(
                      color: AppColors.angryRed,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.angryRed.withOpacity(0.5), width: 1.5),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor ?? AppColors.borderSubtle, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x084A4453),
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
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  void _showUnpairConfirmDialog(BuildContext context, OnlineController notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Partner Bağlantısını Kes?'),
        content: const Text('Mevcut partneriniz ile eşleşmeyi kaldırmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.angryRed),
            onPressed: () {
              notifier.unpair();
              Navigator.of(ctx).pop();
            },
            child: const Text('Evet, Ayrıl'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, OnlineController notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Çıkış Yapılsın mı?'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz? Tekrar giriş yaparak maceraya devam edebilirsiniz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.angryRed),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              await notifier.logout();
              if (context.mounted) {
                Navigator.of(context).pop(); // Close Settings Screen
              }
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
