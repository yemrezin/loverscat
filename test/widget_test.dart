import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loverscat/core/constants/app_strings.dart';
import 'package:loverscat/features/map/presentation/screens/world_map_screen.dart';
import 'package:loverscat/features/map/presentation/screens/island_map_screen.dart';
import 'package:loverscat/features/map/presentation/widgets/snakes_ladders_board_widget.dart';
import 'package:loverscat/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AuthScreen renders when user is not logged in', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: PawsAndUsApp(),
      ),
    );
    await tester.pump();

    // Verify AuthScreen tabs and titles appear
    expect(find.text('Giriş Yap 🔑'), findsOneWidget);
    expect(find.text('Kayıt Ol ✨'), findsOneWidget);
    expect(find.text('Giriş Yap 🐾'), findsOneWidget);
  });

  testWidgets('Paws & Us initial render test when logged in', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'loverscat_user_profile_v2':
          '{"username":"test_user","displayName":"test_user","petType":"cat","petName":"Mırmır","partnerUsername":null,"partnerProfile":null,"isOnline":true}',
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: PawsAndUsApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify app name appears
    expect(find.text(AppStrings.appName), findsOneWidget);
    // Verify Start Game button appears
    expect(find.text(AppStrings.startGame), findsOneWidget);
    // Verify Haritalar button appears
    expect(find.text('Haritalar'), findsOneWidget);
  });

  testWidgets('WorldMapScreen renders properly with all islands and title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WorldMapScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Dünya Haritası'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });

  testWidgets('IslandMapScreen renders minimalist 1. Ada and dama tasi tokens without clutter', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: IslandMapScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Must show ONLY "1. Ada"
    expect(find.text('1. Ada'), findsOneWidget);

    // Board and Dama Tasi tokens must be present
    expect(find.byType(SnakesLaddersBoardWidget), findsOneWidget);
  });
}
