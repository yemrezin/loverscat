import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loverscat/core/constants/app_colors.dart';
import 'package:loverscat/core/constants/app_strings.dart';
import 'package:loverscat/core/utils/haptic_utils.dart';
import 'package:loverscat/features/online/controllers/online_controller.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login Controllers
  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;

  // Register Controllers
  final _registerUsernameController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  bool _registerObscurePassword = true;
  PetType _selectedPet = PetType.cat;

  String? _localError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _localError = null;
        });
        ref.read(onlineProvider.notifier).clearStatus();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    HapticUtils.medium();
    final username = _loginUsernameController.text.trim();
    final password = _loginPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _localError = 'Lütfen kullanıcı adı ve şifrenizi girin.';
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    final success = await ref.read(onlineProvider.notifier).login(
      username: username,
      password: password,
    );

    if (!mounted) return;
    if (!success) {
      setState(() {
        _localError = ref.read(onlineProvider).lastError ?? 'Giriş yapılamadı.';
      });
    }
  }

  Future<void> _handleRegister() async {
    HapticUtils.medium();
    final username = _registerUsernameController.text.trim();
    final password = _registerPasswordController.text;
    final confirm = _registerConfirmPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _localError = 'Lütfen tüm alanları doldurun.';
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _localError = 'Kullanıcı adı en az 3 karakter olmalıdır.';
      });
      return;
    }

    if (password.length < 4) {
      setState(() {
        _localError = 'Şifre en az 4 karakter olmalıdır.';
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _localError = 'Şifreler birbiriyle eşleşmiyor!';
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    final success = await ref.read(onlineProvider.notifier).register(
      username: username,
      password: password,
      petType: _selectedPet,
      petName: _selectedPet.displayName.split(' ')[0],
    );

    if (!mounted) return;
    if (!success) {
      setState(() {
        _localError = ref.read(onlineProvider).lastError ?? 'Kayıt yapılamadı.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlineState = ref.watch(onlineProvider);
    final displayedError = _localError ?? onlineState.lastError;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Mascot and Header
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.catBody.withOpacity(0.2),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/pet_cat.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Çiftler & Arkadaşlar İçin Canlı Ada Macerası 🐾✨',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Tab Selector: Giriş Yap / Kayıt Ol
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A4A4453),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.player1Badge,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Giriş Yap 🔑'),
                        Tab(text: 'Kayıt Ol ✨'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Message Banner (if any)
                  if (displayedError != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEAEA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.angryRed.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.angryRed, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              displayedError,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.angryRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Tab Content Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C4A4453),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                    ),
                    child: AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        return _tabController.index == 0
                            ? _buildLoginForm(onlineState)
                            : _buildRegisterForm(onlineState);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  // SQL Database Info Note
                  const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Kullanıcı adı ve şifreniz SQL veritabanında saklanır.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(OnlineState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Hesabına Giriş Yap',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kullanıcı adınızı ve şifrenizi girerek bağlanın.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),

        // Username
        TextField(
          controller: _loginUsernameController,
          decoration: InputDecoration(
            labelText: 'Kullanıcı Adı',
            hintText: 'örn: kedi_asigi',
            prefixText: '@ ',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.player1Badge, size: 20),
            filled: true,
            fillColor: AppColors.backgroundWarm.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player1Badge, width: 2)),
          ),
          autocorrect: false,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),

        // Password
        TextField(
          controller: _loginPasswordController,
          obscureText: _loginObscurePassword,
          decoration: InputDecoration(
            labelText: 'Şifre',
            prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.player1Badge, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _loginObscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _loginObscurePassword = !_loginObscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: AppColors.backgroundWarm.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player1Badge, width: 2)),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 22),

        // Submit Button
        ElevatedButton(
          onPressed: state.isConnecting ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.player1Badge,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          child: state.isConnecting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Giriş Yap 🐾',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(OnlineState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Yeni Hesap Oluştur',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kullanıcı adınız benzersiz olmalı ve sadece size ait olacaktır.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Pet Selection
        const Text(
          'Karakterini / Rumuzunu Seç:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: PetType.values.map((type) {
            final isSelected = _selectedPet == type;
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
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? type.primaryColor.withOpacity(0.2) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? type.primaryColor : AppColors.borderSubtle,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.asset(type.headAssetPath, width: 34, height: 34),
                      const SizedBox(height: 2),
                      Text(
                        type.displayName.split(' ')[0],
                        style: TextStyle(
                          fontSize: 10,
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

        // Username
        TextField(
          controller: _registerUsernameController,
          decoration: InputDecoration(
            labelText: 'Benzersiz Kullanıcı Adı',
            hintText: 'örn: tilki_reis',
            prefixText: '@ ',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.player2Badge, size: 20),
            filled: true,
            fillColor: AppColors.backgroundWarm.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player2Badge, width: 2)),
          ),
          autocorrect: false,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),

        // Password
        TextField(
          controller: _registerPasswordController,
          obscureText: _registerObscurePassword,
          decoration: InputDecoration(
            labelText: 'Şifre (En az 4 karakter)',
            prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.player2Badge, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _registerObscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _registerObscurePassword = !_registerObscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: AppColors.backgroundWarm.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player2Badge, width: 2)),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),

        // Confirm Password
        TextField(
          controller: _registerConfirmPasswordController,
          obscureText: _registerObscurePassword,
          decoration: InputDecoration(
            labelText: 'Şifre Tekrar',
            prefixIcon: const Icon(Icons.lock_clock_rounded, color: AppColors.player2Badge, size: 20),
            filled: true,
            fillColor: AppColors.backgroundWarm.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player2Badge, width: 2)),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleRegister(),
        ),
        const SizedBox(height: 22),

        // Submit Button
        ElevatedButton(
          onPressed: state.isConnecting ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.player2Badge,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          child: state.isConnecting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Kayıt Ol ve Başla ✨',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
