import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loverscat/features/story_tutorial/domain/models/story_panel.dart';
import 'package:loverscat/features/story_tutorial/presentation/screens/story_intro_screen.dart';

void main() {
  test('StoryPanel intro panels contain bear family and red heart balloon narrative', () {
    final panels = StoryPanel.introPanels;
    expect(panels.length, equals(3));

    // Panel 1: Mother and father bear seen from behind on picnic, daughter with red balloon
    expect(panels[0].title, equals('Huzurlu Ada Sabahı'));
    expect(panels[0].imageAssetPath, equals('assets/images/story_bear_family.jpg'));
    expect(panels[0].subtitle.contains('Anne ve baba ayı'), isTrue);
    expect(panels[0].subtitle.contains('kırmızı kalp balonu'), isTrue);

    // Panel 2: Storm lifts daughter and red balloon into sky
    expect(panels[1].title, equals('Mistik Rüzgar & Kırmızı Balon'));
    expect(panels[1].imageAssetPath, equals('assets/images/story_bear_floating.jpg'));
    expect(panels[1].subtitle.contains('kırmızı kalp balonunu'), isTrue);

    // Panel 3: Mother and father bear sail on boat to rescue her
    expect(panels[2].title, equals('Büyük Kurtarma Yolculuğu'));
    expect(panels[2].imageAssetPath, equals('assets/images/story_bear_boat.jpg'));
    expect(panels[2].subtitle.contains('teknelerine atladılar'), isTrue);
  });

  testWidgets('StoryIntroScreen renders full-screen panels and navigates smoothly', (WidgetTester tester) async {
    bool finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StoryIntroScreen(
          isNewRegistration: true,
          onFinish: () {
            finished = true;
          },
        ),
      ),
    );
    await tester.pump();

    // Verify first panel elements appear
    expect(find.text('Huzurlu Ada Sabahı'), findsOneWidget);
    expect(find.text('Bölüm 1 / 3'), findsOneWidget);
    expect(find.text('Devam Et'), findsOneWidget);
    expect(find.text('Atla'), findsOneWidget);

    // Tap "Atla" (Skip)
    await tester.tap(find.text('Atla'));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
  });
}
