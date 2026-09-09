import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_quiz_repository.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/question.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import 'cat_judge_engine.dart';
import 'quiz_game_notifier.dart';

/// Provides the active [IQuizRepository].
/// Can be overridden in tests or replaced by a remote Firebase/WebSocket repository.
final quizRepositoryProvider = Provider<IQuizRepository>((ref) {
  return LocalMockQuizRepository();
});

/// Provides the [CatJudgeEngine] instance.
final catJudgeEngineProvider = Provider<CatJudgeEngine>((ref) {
  return const CatJudgeEngine();
});

/// Main game state notifier provider.
final quizGameProvider =
    StateNotifierProvider<QuizGameNotifier, QuizGameState>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  final judgeEngine = ref.watch(catJudgeEngineProvider);
  return QuizGameNotifier(
    repository: repository,
    judgeEngine: judgeEngine,
  );
});

/// Helper provider to fetch all questions (including custom ones) for the builder/list view.
final allQuestionsProvider = FutureProvider<List<QuizQuestion>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getQuestions();
});
