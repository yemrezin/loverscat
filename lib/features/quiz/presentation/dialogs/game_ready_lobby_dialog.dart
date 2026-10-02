import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../online/controllers/online_controller.dart';
import '../../../pet/presentation/widgets/pet_display_widget.dart';
import '../../data/datasources/default_questions.dart';
import '../../domain/models/question.dart';
import '../controllers/quiz_providers.dart';
import '../screens/quiz_play_screen.dart';

/// Modal dialog showing the 2-player Ready Lobby.
/// The 10-question synced game only begins when BOTH players click "Hazırım".
class GameReadyLobbyDialog extends ConsumerStatefulWidget {
  const GameReadyLobbyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GameReadyLobbyDialog(),
    );
  }

  @override
  ConsumerState<GameReadyLobbyDialog> createState() => _GameReadyLobbyDialogState();
}

class _GameReadyLobbyDialogState extends ConsumerState<GameReadyLobbyDialog> {
  bool _hasStartedGame = false;

  @override
  void dispose() {
    // If dialog is closed without starting, cancel self ready
    final online = ref.read(onlineProvider);
    if (online.isSelfReady && !_hasStartedGame) {
      ref.read(onlineProvider.notifier).setReady(false);
    }
    super.dispose();
  }

  void _onSyncedGameStart(Map<String, dynamic> actionData) {
    if (_hasStartedGame) return;
    _hasStartedGame = true;

    final rawQuestions = actionData['questions'] as List? ?? [];
    List<QuizQuestion> questions = rawQuestions
        .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
        .toList();

    if (questions.isEmpty) {
      // Fallback
      questions = defaultQuizQuestions;
    }

    HapticUtils.heavy();
    ref.read(quizGameProvider.notifier).startCustomGame(questions);

    Navigator.of(context).pop(); // Close lobby dialog
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(onlineProvider);
    final isSelfReady = online.isSelfReady;
    final isPartnerReady = online.isPartnerReady;
    final partner = online.partner;

    // Listen to synced game start
    ref.listen<OnlineState>(onlineProvider, (previous, next) {
      final lastAction = next.lastGameAction;
      if (lastAction != null && lastAction != previous?.lastGameAction) {
        final actionType = lastAction['actionType'] as String?;
        final actionData = lastAction['actionData'] as Map<String, dynamic>? ?? {};

        if (actionType == 'start_synced_game') {
          _onSyncedGameStart(actionData);
        }
      }
    });

    return Dialog(
      backgroundColor: AppColors.backgroundWarm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('🎮', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'Oyun Lobisi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () {
                    HapticUtils.light();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'İki kullanıcı da hazır verdiğinde 10 soruluk oyun otomatik başlayacaktır!',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Two Players Cards
            Row(
              children: [
                // Player 1 (You)
                Expanded(
                  child: _buildPlayerCard(
                    title: 'Sen',
                    username: online.user.formattedUsername,
                    petType: online.user.petType,
                    isReady: isSelfReady,
                    accentColor: AppColors.player1Badge,
                  ),
                ),
                const SizedBox(width: 12),
                // Player 2 (Partner)
                Expanded(
                  child: partner != null
                      ? _buildPlayerCard(
                          title: 'Partnerin',
                          username: partner.formattedUsername,
                          petType: partner.petType,
                          isReady: isPartnerReady,
                          accentColor: AppColors.player2Badge,
                          isOnline: partner.isOnline,
                        )
                      : Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: const Column(
                            children: [
                              Text('⌛', style: TextStyle(fontSize: 32)),
                              SizedBox(height: 6),
                              Text(
                                'Partner Yok',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Ayarlardan eşleşin',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status message
            if (isSelfReady && !isPartnerReady)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.pastelYellow.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF854D0E)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Harika! ${partner?.formattedUsername ?? 'Partnerin'} hazır olması bekleniyor...',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF854D0E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (isSelfReady && isPartnerReady)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F3DC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF52B788), width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🚀 ', style: TextStyle(fontSize: 16)),
                    Text(
                      'İkiniz de hazırsınız! Oyun başlatılıyor...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),

            // Ready Toggle Button
            ElevatedButton(
              onPressed: () {
                HapticUtils.medium();
                ref.read(onlineProvider.notifier).setReady(!isSelfReady);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelfReady ? const Color(0xFFE63946) : AppColors.player1Badge,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                isSelfReady ? 'Hazırlığı İptal Et 🛑' : 'Ben Hazırım! 🐾✨',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard({
    required String title,
    required String username,
    required dynamic petType,
    required bool isReady,
    required Color accentColor,
    bool isOnline = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isReady ? AppColors.successGreen : AppColors.borderSubtle,
          width: isReady ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (isReady)
            BoxShadow(
              color: AppColors.successGreen.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          PetDisplayWidget(petType: petType, size: 55),
          const SizedBox(height: 6),
          Text(
            username,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isReady
                  ? AppColors.successGreen.withOpacity(0.18)
                  : (isOnline ? Colors.grey.withOpacity(0.15) : Colors.red.withOpacity(0.12)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isReady ? '🟢 Hazır' : (isOnline ? '⏳ Bekleniyor' : '⚪ Çevrimdışı'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isReady
                        ? AppColors.successGreen
                        : (isOnline ? AppColors.textSecondary : Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
