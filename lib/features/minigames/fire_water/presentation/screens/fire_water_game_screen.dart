import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loverscat/core/constants/app_colors.dart';
import 'package:loverscat/core/utils/haptic_utils.dart';
import 'package:loverscat/features/map/presentation/controllers/map_providers.dart';
import '../controllers/fire_water_controller.dart';
import '../widgets/fire_water_canvas.dart';
import '../widgets/fire_water_controls.dart';

class FireWaterGameScreen extends ConsumerWidget {
  const FireWaterGameScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FireWaterGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fireWaterProvider);
    final controller = ref.read(fireWaterProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF111319),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181B24),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            HapticUtils.light();
            Navigator.of(context).pop();
          },
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔥 ', style: TextStyle(fontSize: 18)),
            Text(
              'Ateş ve Su Tapınağı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(' 💧', style: TextStyle(fontSize: 18)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              // Hint Strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C202B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C3242)),
                ),
                child: const Row(
                  children: [
                    Text('💡 ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        'Ateş lavda, Su suda yürür. Asitten kaçının ve kapılara ulaşın!',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Square Canvas (1:1 Ratio)
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FireWaterCanvas(state: state),

                      // Game Over Overlay
                      if (state.isGameOver)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xEE1E222D),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFF5252), width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('😿', style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              Text(
                                state.statusMessage ?? 'Karakter düştü!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  HapticUtils.light();
                                  controller.resetLevel();
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Tekrar Dene'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5252),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Victory Overlay
                      if (state.isCompleted)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xF018261F),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF00E676), width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x8000E676),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 44)),
                              const SizedBox(height: 8),
                              const Text(
                                'Tapınak Tamamlandı!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Çocuğunuzun Ahşap Korsan Dürbününü (🔭) buldunuz!',
                                style: TextStyle(
                                  color: Color(0xFFB9F6CA),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  HapticUtils.doubleSlap();
                                  // Mark 2. island as completed and unlock next island
                                  final mapNotifier = ref.read(mapGameProvider.notifier);
                                  await mapNotifier.completeMiniGame(2);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                icon: const Text('⛵', style: TextStyle(fontSize: 18)),
                                label: const Text(
                                  'Sonraki Adaya Yelken Aç!',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E676),
                                  foregroundColor: const Color(0xFF0A2E1A),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Bottom Ergonomic Controls
              FireWaterControls(state: state, controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
