import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/online/controllers/online_controller.dart';
import 'features/quiz/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode only as requested
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: PawsAndUsApp(),
    ),
  );
}

class PawsAndUsApp extends ConsumerWidget {
  const PawsAndUsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineState = ref.watch(onlineProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child!,
          ),
        );
      },
      home: onlineState.isLoggedIn ? const HomeScreen() : const AuthScreen(),
    );
  }
}
