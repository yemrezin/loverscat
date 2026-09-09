import 'package:flutter_test/flutter_test.dart';
import 'package:loverscat/features/quiz/data/datasources/default_questions.dart';
import 'package:loverscat/features/quiz/data/repositories/mock_quiz_repository.dart';
import 'package:loverscat/features/quiz/domain/models/question.dart';

void main() {
  group('MockQuizRepository and Question Model Tests', () {
    test('Default questions pool must have at least 10 couple questions', () {
      expect(defaultQuizQuestions.length, greaterThanOrEqualTo(10));
      // Must have both multiple choice and open ended
      final hasMultipleChoice = defaultQuizQuestions.any((q) => q.isMultipleChoice);
      final hasOpenEnded = defaultQuizQuestions.any((q) => q.isOpenEnded);

      expect(hasMultipleChoice, isTrue);
      expect(hasOpenEnded, isTrue);
    });

    test('QuizQuestion JSON serialization and deserialization', () {
      const original = QuizQuestion(
        id: 'test_123',
        text: 'En sevdiğin tatil neresi?',
        type: QuestionType.multipleChoice,
        options: ['Bodrum', 'Kapadokya', 'Roma', 'Tokyo'],
        isCustom: true,
      );

      final map = original.toMap();
      final restored = QuizQuestion.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.text, original.text);
      expect(restored.type, original.type);
      expect(restored.options, original.options);
      expect(restored.isCustom, isTrue);
    });

    test('LocalMockQuizRepository returns default questions when empty', () async {
      final repo = LocalMockQuizRepository();
      final questions = await repo.getQuestions();

      expect(questions.length, greaterThanOrEqualTo(10));
      expect(questions.first.text, defaultQuizQuestions.first.text);
    });

    test('Saving and deleting custom question in LocalMockQuizRepository', () async {
      final repo = LocalMockQuizRepository();
      const customQ = QuizQuestion(
        id: 'custom_test_1',
        text: 'Biz nerede tanıştık?',
        type: QuestionType.openEnded,
      );

      await repo.saveCustomQuestion(customQ);
      var questions = await repo.getQuestions();
      expect(questions.any((q) => q.id == 'custom_test_1'), isTrue);

      await repo.deleteCustomQuestion('custom_test_1');
      questions = await repo.getQuestions();
      expect(questions.any((q) => q.id == 'custom_test_1'), isFalse);
    });
  });
}
