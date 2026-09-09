import '../models/question.dart';

/// Abstract repository for question retrieval and persistence.
/// Complies with Dependency Inversion Principle (DIP).
/// Future implementations (e.g. FirebaseQuizRepository, WebSocketQuizRepository)
/// can be swapped in without modifying any domain or presentation layer code.
abstract class IQuizRepository {
  /// Fetches both default and user-saved custom questions.
  Future<List<QuizQuestion>> getQuestions();

  /// Saves a newly created custom question to persistent storage.
  Future<void> saveCustomQuestion(QuizQuestion question);

  /// Deletes a custom question by id.
  Future<void> deleteCustomQuestion(String id);

  /// Resets questions to the default seeded pool.
  Future<void> resetToDefaults();
}
