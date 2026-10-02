import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loverscat/core/constants/app_colors.dart';
import 'package:loverscat/core/utils/haptic_utils.dart';
import 'package:loverscat/features/online/controllers/online_controller.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import '../widgets/auth_hero_header.dart';
import '../widgets/auth_login_form.dart';
import '../widgets/auth_register_form.dart';

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

  // Register Controllers
  final _registerUsernameController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
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
                  const AuthHeroHeader(),
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
                            ? AuthLoginForm(
                                usernameController: _loginUsernameController,
                                passwordController: _loginPasswordController,
                                isConnecting: onlineState.isConnecting,
                                onSubmit: _handleLogin,
                              )
                            : AuthRegisterForm(
                                usernameController: _registerUsernameController,
                                passwordController: _registerPasswordController,
                                confirmPasswordController: _registerConfirmPasswordController,
                                selectedPet: _selectedPet,
                                onPetChanged: (pet) => setState(() => _selectedPet = pet),
                                isConnecting: onlineState.isConnecting,
                                onSubmit: _handleRegister,
                              );
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
}
