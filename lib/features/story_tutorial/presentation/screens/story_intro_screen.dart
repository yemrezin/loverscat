import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/story_panel.dart';

/// Full-screen cinematic storybook experience for "Aşkın Uçan Rotası".
/// Shows mother bear & father bear from behind, little daughter bear with red heart balloon,
/// and their boat rescue journey across the islands.
class StoryIntroScreen extends StatefulWidget {
  final bool isNewRegistration;
  final VoidCallback? onFinish;

  const StoryIntroScreen({
    super.key,
    this.isNewRegistration = false,
    this.onFinish,
  });

  /// Opens the story as a full-screen route.
  static Future<void> open(
    BuildContext context, {
    bool isNewRegistration = false,
    VoidCallback? onFinish,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryIntroScreen(
          isNewRegistration: isNewRegistration,
          onFinish: onFinish,
        ),
      ),
    );
  }

  @override
  State<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends State<StoryIntroScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final _panels = StoryPanel.introPanels;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishStory() {
    HapticUtils.medium();
    if (widget.onFinish != null) {
      widget.onFinish!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _nextPage() {
    HapticUtils.light();
    if (_currentIndex < _panels.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishStory();
    }
  }

  void _prevPage() {
    HapticUtils.light();
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _panels.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. PageView with Story Illustrations
          PageView.builder(
            controller: _pageController,
            itemCount: _panels.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final panel = _panels[index];
              return _buildStoryPage(panel);
            },
          ),

          // 2. Top Header with Progress Bars & Skip Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Multi-segment progress bar (Stories style)
                    Row(
                      children: List.generate(_panels.length, (i) {
                        final isFilled = i <= _currentIndex;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 4,
                            decoration: BoxDecoration(
                              color: isFilled ? AppColors.player1Badge : Colors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: isFilled
                                  ? [
                                      BoxShadow(
                                        color: AppColors.player1Badge.withOpacity(0.6),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),

                    // Header row: Badge & Skip Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_panels[_currentIndex].illustrationIcon, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                'Bölüm ${_currentIndex + 1} / ${_panels.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: _finishStory,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Atla',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.fast_forward_rounded, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Action Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    if (_currentIndex > 0) ...[
                      InkWell(
                        onTap: _prevPage,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroPinkGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.player1Badge.withOpacity(0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: _nextPage,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLast ? 'Yolculuğa Başla ⛵' : 'Devam Et',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isLast ? Icons.favorite_rounded : Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPage(StoryPanel panel) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Storybook illustration
        Image.asset(
          panel.imageAssetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: const Color(0xFF1E1728),
              child: Center(
                child: Text(
                  panel.illustrationIcon,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
            );
          },
        ),

        // Deep gradient overlay from bottom to make narrative text crisp and prominent
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.96),
                ],
                stops: const [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // Narrative text container at bottom
        Positioned(
          left: 20,
          right: 20,
          bottom: 84, // Space above bottom buttons
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                panel.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 10),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                panel.subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 8),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Heartwarming Quote Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.player1Badge.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.player1Badge.withOpacity(0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  panel.quote,
                  style: const TextStyle(
                    color: Color(0xFFFFD1DC),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
