import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Wraps the entire application in a modern smartphone device frame on desktop/web viewports,
/// ensuring genuine mobile aspect ratios (around 9:19.5) and crisp mobile screen dimensions.
///
/// On real mobile devices or small viewport widths (<= 600px), it passes through edge-to-edge
/// without any outer bezels or letterboxing.
class ResponsiveMobileFrame extends StatelessWidget {
  final Widget? child;

  const ResponsiveMobileFrame({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child == null) return const SizedBox.shrink();

    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;

    // On mobile devices or narrow browser windows, render full screen directly
    if (screenSize.width <= 600) {
      return child!;
    }

    // Desktop/Tablet presentation: calculate realistic smartphone dimensions
    // Modern flagship smartphones (iPhone 15 Pro, Galaxy S24, Pixel 8): ~390-412px wide, 844-892px high.
    final availableHeight = screenSize.height;
    final availableWidth = screenSize.width;

    // Target height: up to 92% of screen height, capped at 880px
    final phoneHeight = math.min(availableHeight * 0.94, 880.0);
    // Standard flagship smartphone width (412px), clamped if window is very narrow
    final phoneWidth = math.min(412.0, availableWidth * 0.94);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Modern deep slate desktop backdrop
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient desktop background with radiant couple glows
          _buildAmbientBackdrop(),

          // Centered Mobile Phone Mockup
          Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Desktop indicator badge
                    _buildDeviceHeaderBadge(),
                    const SizedBox(height: 12),

                    // Smartphone Chassis Container
                    Container(
                      width: phoneWidth,
                      height: phoneHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2029), // Premium titanium chassis bezel
                        borderRadius: BorderRadius.circular(46),
                        border: Border.all(
                          color: const Color(0xFF383B4A),
                          width: 3.5,
                        ),
                        boxShadow: [
                          // Deep ambient chassis drop shadow
                          BoxShadow(
                            color: Colors.black.withOpacity(0.55),
                            blurRadius: 40,
                            spreadRadius: 4,
                            offset: const Offset(0, 20),
                          ),
                          // Subtle radiant love glow around the device
                          BoxShadow(
                            color: AppColors.player1Badge.withOpacity(0.22),
                            blurRadius: 60,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(42),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Content wrapped with overridden mobile MediaQuery
                            MediaQuery(
                              data: mediaQuery.copyWith(
                                size: Size(phoneWidth, phoneHeight),
                                padding: const EdgeInsets.only(top: 40, bottom: 20),
                                viewPadding: const EdgeInsets.only(top: 40, bottom: 20),
                              ),
                              child: child!,
                            ),

                            // Dynamic Island / Camera Pill at the top
                            Positioned(
                              top: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 96,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF1A2234),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Bottom Home Indicator Bar
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 120,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildAmbientBackdrop() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D1117),
            Color(0xFF161B26),
            Color(0xFF1F1B2C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Top-left pink ambient glow orb
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.player1Badge.withOpacity(0.12),
              ),
            ),
          ),
          // Bottom-right teal/cyan ambient glow orb
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.player2Badge.withOpacity(0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceHeaderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📱', style: TextStyle(fontSize: 13)),
          SizedBox(width: 6),
          Text(
            'Paws & Us - Mobil Boyut Görünümü',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
