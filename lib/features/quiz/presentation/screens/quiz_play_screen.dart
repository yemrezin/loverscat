import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/cat_reaction.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/round_answer.dart';
import '../controllers/quiz_game_notifier.dart';
import '../controllers/quiz_providers.dart';
import '../widgets/answer_input_card.dart';
import '../widgets/cat_display_widget.dart';
import '../widgets/confetti_overlay_widget.dart';
import '../widgets/screen_shake_widget.dart';
import '../widgets/whispering_bird_button.dart';
import 'package:loverscat/features/map/domain/models/island_board.dart';
import 'package:loverscat/features/map/presentation/controllers/map_providers.dart';
import 'package:loverscat/features/pet/presentation/controllers/pet_providers.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/online/controllers/online_controller.dart';

/// Primary Game Screen orchestrating the 3-step couple quiz loop.
class QuizPlayScreen extends ConsumerStatefulWidget {
  const QuizPlayScreen({super.key});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  bool _stepsAwarded = false;
  Timer? _questionTimer;
  int _remainingSeconds = 10;
  int _onlineStep = 0; // 0 = own answer, 1 = guess partner, 2 = waiting for partner
  String? _myOwnAnswer;
  String? _myGuess;
  Map<String, dynamic>? _partnerSubmission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(quizGameProvider);
      if (!state.isLoading &&
          !state.isGameOver &&
          !state.isTransitionBarrierActive &&
          state.phase != GamePhase.revealed) {
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _questionTimer?.cancel();
    setState(() {
      _remainingSeconds = 10;
    });
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
        if (_remainingSeconds <= 3) {
          HapticUtils.light();
        }
      } else {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        _handleTimeout();
      }
    });
  }

  void _stopTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  void _finalizeOnlineRound(OnlineState online, CouplePlayers couple, QuizGameNotifier notifier) {
    _stopTimer();
    final myUname = online.user.username.toLowerCase();
    final isMeP1 = myUname == couple.player1.name.toLowerCase();

    final p1Own = isMeP1 ? (_myOwnAnswer ?? kPartnerNotKnowingAnswer) : (_partnerSubmission?['ownAnswer'] ?? kPartnerNotKnowingAnswer);
    final p1Guess = isMeP1 ? (_myGuess ?? '') : (_partnerSubmission?['guess'] ?? '');
    final p2Own = isMeP1 ? (_partnerSubmission?['ownAnswer'] ?? kPartnerNotKnowingAnswer) : (_myOwnAnswer ?? kPartnerNotKnowingAnswer);
    final p2Guess = isMeP1 ? (_partnerSubmission?['guess'] ?? '') : (_myGuess ?? '');

    notifier.setOnlineRoundAnswers(
      p1OwnAnswer: p1Own,
      p1Guess: p1Guess,
      p2OwnAnswer: p2Own,
      p2Guess: p2Guess,
    );
  }

  void _advanceToNextQuestion(QuizGameNotifier notifier) {
    setState(() {
      _onlineStep = 0;
      _myOwnAnswer = null;
      _myGuess = null;
      _partnerSubmission = null;
    });
    final online = ref.read(onlineProvider);
    if (online.isPaired) {
      ref.read(onlineProvider.notifier).sendGameAction('quiz_next', {});
    }
    notifier.nextQuestion();
    _startTimer();
  }

  void _handleTimeout() {
    if (!mounted) return;
    final gameState = ref.read(quizGameProvider);
    final notifier = ref.read(quizGameProvider.notifier);
    final online = ref.read(onlineProvider);
    final couple = ref.read(couplePlayersProvider);

    if (gameState.isTransitionBarrierActive ||
        gameState.phase == GamePhase.revealed ||
        gameState.isGameOver) {
      return;
    }

    HapticUtils.heavy();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏱️ Süre doldu! (10 saniye)'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (online.isPaired) {
      if (_onlineStep == 0) {
        _myOwnAnswer = kPartnerNotKnowingAnswer;
        setState(() {
          _onlineStep = 1;
        });
        _startTimer();
      } else if (_onlineStep == 1) {
        _myGuess = '';
        setState(() {
          _onlineStep = 2;
        });
        _stopTimer();
        ref.read(onlineProvider.notifier).sendGameAction('quiz_player_round', {
          'username': online.user.username,
          'ownAnswer': _myOwnAnswer,
          'guess': _myGuess,
        });
        if (_partnerSubmission != null) {
          _finalizeOnlineRound(online, couple, notifier);
        }
      }
    } else {
      if (gameState.phase == GamePhase.waitingOwnAnswers) {
        notifier.sealOwnAnswer(null);
      } else if (gameState.phase == GamePhase.waitingGuesses) {
        notifier.submitGuess(null);
      }
    }
  }

  void _awardSteps(int p1Steps, int p2Steps) {
    if (!_stepsAwarded && (p1Steps > 0 || p2Steps > 0)) {
      ref.read(mapGameProvider.notifier).addPlayerSteps(
        player1Steps: p1Steps,
        player2Steps: p2Steps,
      );
      _stepsAwarded = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    ref.listen<QuizGameState>(quizGameProvider, (previous, next) {
      if (next.isLoading ||
          next.isGameOver ||
          next.isTransitionBarrierActive ||
          next.phase == GamePhase.revealed) {
        _stopTimer();
        return;
      }

      final wasActive = previous != null &&
          !previous.isLoading &&
          !previous.isGameOver &&
          !previous.isTransitionBarrierActive &&
          previous.phase != GamePhase.revealed;

      final playerChanged = previous?.activePlayer != next.activePlayer;
      final phaseChanged = previous?.phase != next.phase;
      final questionChanged = previous?.currentQuestionIndex != next.currentQuestionIndex;

      if (!wasActive || playerChanged || phaseChanged || questionChanged) {
        _startTimer();
      }
    });

    final gameState = ref.watch(quizGameProvider);
    final notifier = ref.read(quizGameProvider.notifier);
    final couple = ref.watch(couplePlayersProvider);
    final onlineState = ref.watch(onlineProvider);

    // Listen to remote partner quiz actions
    ref.listen<OnlineState>(onlineProvider, (prev, next) {
      final lastAction = next.lastGameAction;
      if (lastAction != null && lastAction != prev?.lastGameAction) {
        final actionType = lastAction['actionType'] as String?;
        final actionData = lastAction['actionData'] as Map<String, dynamic>? ?? {};

        if (actionType == 'quiz_player_round') {
          _partnerSubmission = actionData;
          if (_onlineStep == 2) {
            _finalizeOnlineRound(next, couple, notifier);
          }
        } else if (actionType == 'quiz_next') {
          setState(() {
            _onlineStep = 0;
            _myOwnAnswer = null;
            _myGuess = null;
            _partnerSubmission = null;
          });
          notifier.nextQuestion();
          _startTimer();
        } else if (actionType == 'quiz_seal') {
          final ans = actionData['answer'] as String?;
          _stopTimer();
          notifier.sealOwnAnswer(ans);
        } else if (actionType == 'quiz_guess') {
          final guess = actionData['guess'] as String?;
          _stopTimer();
          notifier.submitGuess(guess);
        } else if (actionType == 'quiz_judge') {
          final isCorrect = actionData['isCorrect'] as bool? ?? false;
          // When remote partner judges, they are Player 2 in our local view
          notifier.judgeGuess(judgingPlayer: PlayerId.player2, isCorrect: isCorrect);
        }
      }
    });


    if (gameState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.player1Badge),
        ),
      );
    }

    if (gameState.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('😿', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 16),
                Text(
                  gameState.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => notifier.loadGame(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (gameState.isGameOver) {
      return _buildGameOverScreen(context, gameState, notifier);
    }

    final currentQuestion = gameState.currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(child: Text('Soru bulunamadı.')),
      );
    }

    final activePlayer = gameState.activePlayer;
    final isPlayer1 = activePlayer == PlayerId.player1;
    final playerAccent = isPlayer1 ? AppColors.player1Badge : AppColors.player2Badge;

    return ScreenShakeWidget(
      shouldShake: gameState.activeReaction.shakeScreen,
      isDoubleSlap: gameState.activeReaction.isDoubleSlap,
      child: ConfettiOverlayWidget(
        active: gameState.activeReaction.showConfetti,
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                centerTitle: true,
                title: Text(
                  'Soru ${gameState.currentQuestionIndex + 1} / ${gameState.totalQuestions}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                actions: [
                  // Streak counter
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.pastelYellow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFE066), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 4),
                        Text(
                          'Seri: ${gameState.streak}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // If paired and answering (not revealed), show online simultaneous flow
                      if (onlineState.isPaired && gameState.phase != GamePhase.revealed) ...[
                        _buildOnlineGameStep(gameState, currentQuestion, notifier, onlineState, couple),
                      ] else ...[
                        // Active Player & Step Indicator Header
                        _buildHeaderSection(gameState, activePlayer, playerAccent, couple),
                        const SizedBox(height: 12),

                        // 10-Second Timer Bar (shown during active answering steps)
                        if (gameState.phase != GamePhase.revealed)
                          _buildTimerBar(playerAccent),

                        // Cat Mascot / Judge View
                        Center(
                          child: CatDisplayWidget(
                            reaction: gameState.activeReaction,
                            size: gameState.phase == GamePhase.revealed ? 180 : 130,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Phase-specific content
                        if (gameState.phase == GamePhase.waitingOwnAnswers)
                          _buildStep1Content(gameState, currentQuestion, playerAccent, notifier),

                        if (gameState.phase == GamePhase.waitingGuesses)
                          _buildStep2Content(gameState, currentQuestion, playerAccent, notifier),

                        if (gameState.phase == GamePhase.revealed)
                          _buildStep3Content(context, gameState, notifier, couple),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bgColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SORU:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineGameStep(
    QuizGameState gameState,
    dynamic currentQuestion,
    QuizGameNotifier notifier,
    OnlineState online,
    CouplePlayers couple,
  ) {
    if (_onlineStep == 0) {
      // Step 1: Kendi Cevabın
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '1. Adım: Senin Tercihin 🐾',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.player1Badge.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    online.user.formattedUsername,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.player1Badge),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTimerBar(AppColors.player1Badge),
          Center(
            child: CatDisplayWidget(
              reaction: gameState.activeReaction,
              size: 130,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(currentQuestion.text, AppColors.pastelLavender),
          const SizedBox(height: 20),
          AnswerInputCard(
            question: currentQuestion,
            buttonLabel: 'Cevabımı Kaydet 🐾',
            accentColor: AppColors.player1Badge,
            onSubmit: (ans) {
              _stopTimer();
              _myOwnAnswer = (ans == null || ans.trim().isEmpty) ? kPartnerNotKnowingAnswer : ans.trim();
              setState(() {
                _onlineStep = 1;
              });
              _startTimer();
            },
            onSkip: () {
              _stopTimer();
              _myOwnAnswer = kPartnerNotKnowingAnswer;
              setState(() {
                _onlineStep = 1;
              });
              _startTimer();
            },
          ),
        ],
      );
    } else if (_onlineStep == 1) {
      // Step 2: Partnerinin Cevabını Tahmin Et
      final partnerName = online.partner?.formattedUsername ?? 'Partnerinin';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '2. Adım: $partnerName Cevabını Tahmin Et 🧠',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.player2Badge.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Tahmin Et',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.player2Badge),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTimerBar(AppColors.player2Badge),
          Center(
            child: CatDisplayWidget(
              reaction: gameState.activeReaction,
              size: 130,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(currentQuestion.text, AppColors.pastelPeach),
          const SizedBox(height: 20),
          AnswerInputCard(
            question: currentQuestion,
            buttonLabel: 'Tahminimi Gönder 🚀',
            accentColor: AppColors.player2Badge,
            onSubmit: (guess) {
              _stopTimer();
              _myGuess = (guess == null || guess.trim().isEmpty) ? '' : guess.trim();
              setState(() {
                _onlineStep = 2;
              });
              ref.read(onlineProvider.notifier).sendGameAction('quiz_player_round', {
                'username': online.user.username,
                'ownAnswer': _myOwnAnswer,
                'guess': _myGuess,
              });
              if (_partnerSubmission != null) {
                _finalizeOnlineRound(online, couple, notifier);
              }
            },
            onSkip: () {
              _stopTimer();
              _myGuess = '';
              setState(() {
                _onlineStep = 2;
              });
              ref.read(onlineProvider.notifier).sendGameAction('quiz_player_round', {
                'username': online.user.username,
                'ownAnswer': _myOwnAnswer,
                'guess': _myGuess,
              });
              if (_partnerSubmission != null) {
                _finalizeOnlineRound(online, couple, notifier);
              }
            },
          ),
        ],
      );
    } else {
      // Step 2: Waiting for partner
      final partnerName = online.partner?.formattedUsername ?? 'Partnerin';
      return Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: CatDisplayWidget(
              reaction: CatReaction.idle,
              size: 140,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderSubtle, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C4A4453),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.player1Badge,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cevapların Kaydedildi! 🐾✨',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$partnerName cevaplarını tamamlaması bekleniyor...\nİkiniz de cevapladığınızda Kedi Yargıç kararı açıklayacak!',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }


  Widget _buildHeaderSection(
    QuizGameState state,
    PlayerId activePlayer,
    Color playerAccent,
    CouplePlayers couple,
  ) {
    String phaseLabel;
    String subLabel;
    final activeName = activePlayer == PlayerId.player1 ? couple.player1.name : couple.player2.name;

    switch (state.phase) {
      case GamePhase.waitingOwnAnswers:
        phaseLabel = AppStrings.step1Header;
        subLabel = 'Sıra $activeName\'nda: Kendi cevabını mühürle!';
        break;
      case GamePhase.waitingGuesses:
        phaseLabel = AppStrings.step2Header;
        subLabel = 'Sıra $activeName\'nda: Sevgilinin cevabını tahmin et!';
        break;
      case GamePhase.revealed:
        phaseLabel = AppStrings.step3Header;
        subLabel = 'Yargıç Kedi kararını verdi!';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                phaseLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (state.phase != GamePhase.revealed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: playerAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activeName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: playerAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subLabel,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Content(
    QuizGameState state,
    dynamic currentQuestion,
    Color playerAccent,
    QuizGameNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.pastelLavender.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.pastelLavender, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SORU:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentQuestion.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Input Options / TextField
        AnswerInputCard(
          question: currentQuestion,
          buttonLabel: AppStrings.sealButton,
          accentColor: playerAccent,
          onSubmit: (answer) {
            _stopTimer();
            ref.read(onlineProvider.notifier).sendGameAction('quiz_seal', {'answer': answer});
            notifier.sealOwnAnswer(answer);
          },
          onSkip: () {
            _stopTimer();
            ref.read(onlineProvider.notifier).sendGameAction('quiz_seal', {'answer': null});
            notifier.sealOwnAnswer(null);
          },
        ),
      ],
    );
  }

  Widget _buildStep2Content(
    QuizGameState state,
    dynamic currentQuestion,
    Color playerAccent,
    QuizGameNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.pastelPeach.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.pastelPeach, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.step2Question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.player1Badge,
                    ),
                  ),
                  // Whispering Bird Joker Button
                  WhisperingBirdButton(
                    availableHints: state.birdWhisperHintsAvailable,
                    revealedHint: state.activeHintRevealed,
                    onUseHint: () => notifier.useBirdWhisperHint(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                currentQuestion.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Input / Guess Selection
        AnswerInputCard(
          question: currentQuestion,
          buttonLabel: AppStrings.submitGuessButton,
          accentColor: playerAccent,
          onSubmit: (guess) {
            _stopTimer();
            ref.read(onlineProvider.notifier).sendGameAction('quiz_guess', {'guess': guess});
            notifier.submitGuess(guess);
          },
          onSkip: () {
            _stopTimer();
            ref.read(onlineProvider.notifier).sendGameAction('quiz_guess', {'guess': null});
            notifier.submitGuess(null);
          },
        ),
      ],
    );
  }

  Widget _buildStep3Content(
    BuildContext context,
    QuizGameState state,
    QuizGameNotifier notifier,
    CouplePlayers couple,
  ) {
    final round = state.currentRound;
    final reaction = state.activeReaction;
    final isP1Correct = round.isP1GuessCorrect;
    final isP2Correct = round.isP2GuessCorrect;
    final currentQ = state.currentQuestion;
    final isOpenEnded = currentQ?.isOpenEnded ?? false;
    final online = ref.watch(onlineProvider);
    final isOnline = online.isLoggedIn && online.isPaired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Reaction Commentary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: reaction.type == CatReactionType.angelWings
                ? AppColors.pastelYellow.withOpacity(0.7)
                : reaction.type == CatReactionType.doublePawAngry
                    ? AppColors.pastelPink.withOpacity(0.8)
                    : AppColors.pastelLavender.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: reaction.type == CatReactionType.angelWings
                  ? AppColors.angelHalo
                  : reaction.type == CatReactionType.doublePawAngry
                      ? AppColors.angryRed
                      : AppColors.player1Badge,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                reaction.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                reaction.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Side-by-Side Answers Breakdown
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player 1 Card (Your Card in online mode)
            Expanded(
              child: _buildPlayerVerdictCard(
                playerName: couple.player1.name,
                accentColor: AppColors.player1Badge,
                bgColor: AppColors.pastelPink.withOpacity(0.35),
                ownAnswer: round.player1OwnAnswer ?? '-',
                partnerGuess: round.player2Guess ?? '-',
                isPartnerGuessCorrect: isP2Correct,
                partnerTitle: '${couple.player2.name}\'nin Tahmini:',
                isOpenEnded: isOpenEnded,
                canJudge: true,
                isJudged: round.isP2Judged,
                onJudge: (bool isCorrect) {
                  HapticUtils.medium();
                  notifier.judgeGuess(judgingPlayer: PlayerId.player1, isCorrect: isCorrect);
                  if (isOnline) {
                    ref.read(onlineProvider.notifier).sendGameAction('quiz_judge', {
                      'judgedAuthor': online.user.username,
                      'isCorrect': isCorrect,
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            // Player 2 Card (Partner's Card in online mode)
            Expanded(
              child: _buildPlayerVerdictCard(
                playerName: couple.player2.name,
                accentColor: AppColors.player2Badge,
                bgColor: AppColors.pastelMint.withOpacity(0.35),
                ownAnswer: round.player2OwnAnswer ?? '-',
                partnerGuess: round.player1Guess ?? '-',
                isPartnerGuessCorrect: isP1Correct,
                partnerTitle: '${couple.player1.name}\'in Tahmini:',
                isOpenEnded: isOpenEnded,
                canJudge: !isOnline,
                isJudged: round.isP1Judged,
                waitingMessage: '${couple.player2.name}\'nin kararı bekleniyor... ⏳',
                onJudge: !isOnline
                    ? (bool isCorrect) {
                        HapticUtils.medium();
                        notifier.judgeGuess(judgingPlayer: PlayerId.player2, isCorrect: isCorrect);
                      }
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Real-time Running Score Bar: Doğru, Yanlış, Boş
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x084A4453),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      couple.player1.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.player1Badge),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildStatBadgeRow(correct: state.player1Score, wrong: state.player1Wrong, blank: state.player1Blank),
                  ],
                ),
              ),
              Container(width: 1.5, height: 45, color: AppColors.borderSubtle),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      couple.player2.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.player2Badge),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildStatBadgeRow(correct: state.player2Score, wrong: state.player2Wrong, blank: state.player2Blank),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Next Question Button
        ElevatedButton(
          onPressed: () {
            HapticUtils.medium();
            _advanceToNextQuestion(notifier);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.player1Badge,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            state.currentQuestionIndex + 1 < state.totalQuestions
                ? AppStrings.nextQuestionButton
                : AppStrings.finishGameButton,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }


  Widget _buildTimerBar(Color playerAccent) {
    final progress = (_remainingSeconds / 10.0).clamp(0.0, 1.0);
    final isUrgent = _remainingSeconds <= 3;
    final timerColor = isUrgent
        ? const Color(0xFFE63946)
        : (_remainingSeconds <= 6 ? const Color(0xFFFB8500) : playerAccent);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFFFEBEE) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: timerColor.withOpacity(isUrgent ? 0.9 : 0.4),
          width: isUrgent ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: timerColor.withOpacity(isUrgent ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isUrgent ? Icons.alarm_on_rounded : Icons.timer_outlined,
                    size: 19,
                    color: timerColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isUrgent ? 'Süre Bitiyor! ⏳' : 'Kalan Süre (10 sn)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: timerColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: timerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_remainingSeconds sn',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.grey.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerVerdictCard({
    required String playerName,
    required Color accentColor,
    required Color bgColor,
    required String ownAnswer,
    required String partnerGuess,
    required bool isPartnerGuessCorrect,
    required String partnerTitle,
    bool isOpenEnded = false,
    bool canJudge = false,
    bool isJudged = false,
    ValueChanged<bool>? onJudge,
    String? waitingMessage,
  }) {
    final isPartnerEmptyOrSilly =
        ownAnswer == kPartnerNotKnowingAnswer || ownAnswer.trim().isEmpty;
    final displayOwnAnswer = isPartnerEmptyOrSilly ? kPartnerNotKnowingAnswer : ownAnswer;
    final isGuessBlank = partnerGuess.trim().isEmpty || partnerGuess == '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  playerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                isPartnerGuessCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isPartnerGuessCorrect ? AppColors.successGreen : AppColors.angryRed,
                size: 20,
              ),
            ],
          ),
          const Divider(height: 16),
          const Text(
            'Kendi Cevabı / Detayı:',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          if (isPartnerEmptyOrSilly)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFD166), width: 1),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🤪 ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      kPartnerNotKnowingAnswer,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF854D0E),
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              displayOwnAnswer,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            partnerTitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            isGuessBlank ? '⚪ Boş (Süre doldu / Cevap verilmedi)' : partnerGuess,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isPartnerGuessCorrect
                  ? AppColors.successGreen
                  : (isGuessBlank ? const Color(0xFF757575) : AppColors.angryRed),
              fontStyle: isGuessBlank ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (isOpenEnded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    canJudge ? '⚖️ Bu tahmini değerlendir:' : '⚖️ Karar:',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  if (canJudge) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticUtils.medium();
                              onJudge?.call(true);
                            },
                            icon: const Icon(Icons.thumb_up_alt_rounded, size: 14),
                            label: const Text('Doğru (+1)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isJudged && isPartnerGuessCorrect ? AppColors.successGreen : Colors.grey.shade100,
                              foregroundColor: isJudged && isPartnerGuessCorrect ? Colors.white : AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              elevation: isJudged && isPartnerGuessCorrect ? 2 : 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticUtils.medium();
                              onJudge?.call(false);
                            },
                            icon: const Icon(Icons.thumb_down_alt_rounded, size: 14),
                            label: const Text('Bilemedi (0)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isJudged && !isPartnerGuessCorrect ? AppColors.angryRed : Colors.grey.shade100,
                              foregroundColor: isJudged && !isPartnerGuessCorrect ? Colors.white : AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              elevation: isJudged && !isPartnerGuessCorrect ? 2 : 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    if (isJudged)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPartnerGuessCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 15,
                            color: isPartnerGuessCorrect ? AppColors.successGreen : AppColors.angryRed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPartnerGuessCorrect ? 'Doğru Kabul Etti! (+1)' : 'Yanlış Saydı (0)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPartnerGuessCorrect ? AppColors.successGreen : AppColors.angryRed,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        waitingMessage ?? 'Partnerinin kararı bekleniyor... ⏳',
                        style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameOverScreen(
    BuildContext context,
    QuizGameState state,
    QuizGameNotifier notifier,
  ) {
    final couple = ref.watch(couplePlayersProvider);
    final mapState = ref.watch(mapGameProvider);

    final p1Earned = state.player1Score;
    final p2Earned = state.player2Score;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text('🏆✨🐱', style: TextStyle(fontSize: 50)),
              ),
              const SizedBox(height: 14),
              const Text(
                'Yarışma Tamamlandı!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Kedi Yargıç aşkınızı ve cevaplarınızı değerlendirdi!',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Final Scores Card with Current Square Positions
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x104A4453),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: AppColors.borderSubtle, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Player 1 Details
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${couple.player1.type.emoji} ${couple.player1.name}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.player1Badge,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              _buildStatBadgeRow(
                                correct: state.player1Score,
                                wrong: state.player1Wrong,
                                blank: state.player1Blank,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '+$p1Earned Adım',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D6A4F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.player1Badge.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Mevcut Kare: ${mapState.player1Position}/${SnakesAndLaddersConfig.totalSquares}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.player1Badge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1.5, height: 110, color: AppColors.borderSubtle),
                        // Player 2 Details
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${couple.player2.type.emoji} ${couple.player2.name}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.player2Badge,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              _buildStatBadgeRow(
                                correct: state.player2Score,
                                wrong: state.player2Wrong,
                                blank: state.player2Blank,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '+$p2Earned Adım',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D6A4F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.player2Badge.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Mevcut Kare: ${mapState.player2Position}/${SnakesAndLaddersConfig.totalSquares}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.player2Badge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔥 En Uzun Seri: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${state.streak}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.player1Badge)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Step Reward Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F3DC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF52B788), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('🗺️', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kazanılan Adımlar: +$p1Earned & +$p2Earned',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4332),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Doğru cevaplarınız kadar adadaki piyonlarınızı ilerletin!',
                            style: TextStyle(fontSize: 12, color: Color(0xFF2D6A4F)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: () {
                  HapticUtils.medium();
                  _awardSteps(p1Earned, p2Earned);
                  Navigator.of(context).pop();
                },
                icon: const Text('🧭', style: TextStyle(fontSize: 18)),
                label: const Text(
                  'Adaya Dön & Adımları İlerlet! 🐾',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF40916C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  HapticUtils.medium();
                  _awardSteps(p1Earned, p2Earned);
                  setState(() {
                    _stepsAwarded = false;
                  });
                  notifier.restartGame();
                },
                child: const Text('Tekrar Quiz Çöz 🐾'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  _awardSteps(p1Earned, p2Earned);
                  Navigator.of(context).pop();
                },
                child: const Text('Kapat & Geri Dön'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadgeRow({
    required int correct,
    required int wrong,
    required int blank,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatPill(
              label: 'Doğru: $correct',
              bgColor: const Color(0xFFE8F5E9),
              textColor: const Color(0xFF2E7D32),
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(width: 4),
            _buildStatPill(
              label: 'Yanlış: $wrong',
              bgColor: const Color(0xFFFFEBEE),
              textColor: const Color(0xFFC62828),
              icon: Icons.cancel_rounded,
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildStatPill(
          label: 'Boş: $blank',
          bgColor: const Color(0xFFF5F5F5),
          textColor: const Color(0xFF616161),
          icon: Icons.hourglass_disabled_rounded,
        ),
      ],
    );
  }

  Widget _buildStatPill({
    required String label,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
