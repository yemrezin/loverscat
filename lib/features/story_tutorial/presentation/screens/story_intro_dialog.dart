import 'package:flutter/material.dart';
import 'story_intro_screen.dart';

export 'story_intro_screen.dart';

/// Legacy bridge for opening the storybook cinematic.
/// Automatically forwards to full-screen [StoryIntroScreen].
class StoryIntroDialog extends StatelessWidget {
  const StoryIntroDialog({super.key});

  static Future<void> show(BuildContext context) {
    return StoryIntroScreen.open(context);
  }

  @override
  Widget build(BuildContext context) {
    return const StoryIntroScreen();
  }
}
