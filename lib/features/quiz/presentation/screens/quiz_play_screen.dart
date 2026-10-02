import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/round_answer.dart';
import '../controllers/quiz_game_notifier.dart';
import '../controllers/quiz_providers.dart';
import '../widgets/cat_display_widget.dart';
import '../widgets/confetti_overlay_widget.dart';
import '../widgets/screen_shake_widget.dart';
import '../widgets/quiz_timer_bar.dart';
import '../widgets/quiz_step_header.dart';
import '../widgets/quiz_game_over_view.dart';
import '../widgets/quiz_online_step_flow.dart';
import '../widgets/quiz_revealed_verdict_view.dart';
import '../widgets/quiz_step_cards.dart';
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

  void _submitOnlineOwnAnswer(String? ans) {
    _stopTimer();
    _myOwnAnswer = (ans == null || ans.trim().isEmpty) ? kPartnerNotKnowingAnswer : ans.trim();
    setState(() => _onlineStep = 1);
    _startTimer();
  }

  void _submitOnlineGuess(String? guess, OnlineState onlineState, CouplePlayers couple, QuizGameNotifier notifier) {
    _stopTimer();
    _myGuess = (guess == null || guess.trim().isEmpty) ? '' : guess.trim();
    setState(() => _onlineStep = 2);
    ref.read(onlineProvider.notifier).sendGameAction('quiz_player_round', {
      'username': onlineState.user.username,
      'ownAnswer': _myOwnAnswer,
      'guess': _myGuess,
    });
    if (_partnerSubmission != null) {
      _finalizeOnlineRound(onlineState, couple, notifier);
    }
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

  void _awardSteps(int p1Steps, int p2Steps, int totalQuestionsSolved) {
    if (!_stepsAwarded) {
      if (p1Steps > 0 || p2Steps > 0) {
        ref.read(mapGameProvider.notifier).addPlayerSteps(
          player1Steps: p1Steps,
          player2Steps: p2Steps,
        );
      }
      final currentIsland = ref.read(mapGameProvider).currentIsland;
      ref.read(mapGameProvider.notifier).recordQuestionsSolved(
        currentIsland,
        totalQuestionsSolved,
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
      return QuizGameOverView(
        state: gameState,
        notifier: notifier,
        couple: couple,
        mapState: ref.watch(mapGameProvider),
        onAwardAndPop: () {
          _awardSteps(
            gameState.player1Score,
            gameState.player2Score,
            gameState.questions.length,
          );
          Navigator.of(context).pop();
        },
        onRestart: () {
          _awardSteps(
            gameState.player1Score,
            gameState.player2Score,
            gameState.questions.length,
          );
          setState(() {
            _stepsAwarded = false;
          });
          notifier.restartGame();
        },
      );
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
        child: Scaffold(
          appBar: QuizTopAppBar(
            currentQuestionIndex: gameState.currentQuestionIndex,
            totalQuestions: gameState.totalQuestions,
            streak: gameState.streak,
            onBack: () => Navigator.of(context).pop(),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (onlineState.isPaired && gameState.phase != GamePhase.revealed) ...[
                    QuizOnlineStepFlow(
                      onlineStep: _onlineStep,
                      remainingSeconds: _remainingSeconds,
                      gameState: gameState,
                      currentQuestion: currentQuestion,
                      online: onlineState,
                      onOwnAnswerSubmitted: (ans) => _submitOnlineOwnAnswer(ans),
                      onOwnAnswerSkipped: () => _submitOnlineOwnAnswer(null),
                      onGuessSubmitted: (guess) => _submitOnlineGuess(guess, onlineState, couple, notifier),
                      onGuessSkipped: () => _submitOnlineGuess(null, onlineState, couple, notifier),
                    ),
                  ] else ...[
                    QuizStepHeader(
                      phase: gameState.phase,
                      activePlayer: activePlayer,
                      playerAccent: playerAccent,
                      couple: couple,
                    ),
                    const SizedBox(height: 12),

                    if (gameState.phase != GamePhase.revealed)
                      QuizTimerBar(
                        remainingSeconds: _remainingSeconds,
                        playerAccent: playerAccent,
                      ),

                    Center(
                      child: CatDisplayWidget(
                        reaction: gameState.activeReaction,
                        size: gameState.phase == GamePhase.revealed ? 180 : 130,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (gameState.phase == GamePhase.waitingOwnAnswers)
                      QuizStep1View(
                        currentQuestion: currentQuestion,
                        playerAccent: playerAccent,
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

                    if (gameState.phase == GamePhase.waitingGuesses)
                      QuizStep2View(
                        state: gameState,
                        currentQuestion: currentQuestion,
                        playerAccent: playerAccent,
                        notifier: notifier,
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

                    if (gameState.phase == GamePhase.revealed)
                      QuizRevealedVerdictView(
                        state: gameState,
                        notifier: notifier,
                        couple: couple,
                        isOnline: onlineState.isLoggedIn && onlineState.isPaired,
                        currentUsername: onlineState.user.username,
                        onSendOnlineJudge: (judgedAuthor, isCorrect) {
                          ref.read(onlineProvider.notifier).sendGameAction('quiz_judge', {
                            'judgedAuthor': judgedAuthor,
                            'isCorrect': isCorrect,
                          });
                        },
                        onNextQuestion: () => _advanceToNextQuestion(notifier),
                      ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
