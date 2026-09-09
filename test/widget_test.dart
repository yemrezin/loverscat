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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Paws & Us initial render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PawsAndUsApp(),
      ),
    );

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
    expect(find.byType(DamaTasiWidget), findsWidgets);

    // No clutter text
    expect(find.text('Kedi Koyu'), findsNothing);
    expect(find.text('Aşk Yolculuğu Başlıyor'), findsNothing);
    expect(find.textContaining('1. Oyuncu ('), findsNothing);
    expect(find.textContaining('Adım İlerle'), findsNothing);
  });
}
