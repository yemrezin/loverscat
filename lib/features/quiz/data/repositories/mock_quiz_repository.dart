import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/question.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import '../datasources/default_questions.dart';

/// Local Mock implementation of [IQuizRepository].
/// Combines default hardcoded couple questions with user-created custom questions
/// stored in local [SharedPreferences] in JSON format.
class LocalMockQuizRepository implements IQuizRepository {
  static const String _customQuestionsKey = 'paws_custom_quiz_questions_v1';
  final SharedPreferences? _prefs;

  // In-memory cache for fast, synchronous access if needed
  final List<QuizQuestion> _customQuestionsCache = [];
  bool _isCacheInitialized = false;

  LocalMockQuizRepository({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs!;
    return await SharedPreferences.getInstance();
  }

  Future<void> _ensureCacheLoaded() async {
    if (_isCacheInitialized) return;
    try {
      final prefs = await _getPrefs();
      final rawJsonList = prefs.getStringList(_customQuestionsKey) ?? [];
      _customQuestionsCache.clear();
      for (final rawJson in rawJsonList) {
        try {
          final map = jsonDecode(rawJson) as Map<String, dynamic>;
          _customQuestionsCache.add(QuizQuestion.fromMap(map));
        } catch (_) {
          // Skip corrupted item gracefully
        }
      }
    } catch (_) {
      // SharedPreferences might fail in mock unit test environments without mock channels
    }
    _isCacheInitialized = true;
  }

  @override
  Future<List<QuizQuestion>> getQuestions() async {
    await _ensureCacheLoaded();
    // Return default questions followed by custom questions
    return [
      ...defaultQuizQuestions,
      ..._customQuestionsCache,
    ];
  }

  @override
  Future<void> saveCustomQuestion(QuizQuestion question) async {
    await _ensureCacheLoaded();
    // Mark as custom
    final customQ = question.copyWith(isCustom: true);
    final existingIndex =
        _customQuestionsCache.indexWhere((q) => q.id == customQ.id);

    if (existingIndex != -1) {
      _customQuestionsCache[existingIndex] = customQ;
    } else {
      _customQuestionsCache.add(customQ);
    }

    await _persistCustomQuestions();
  }

  @override
  Future<void> deleteCustomQuestion(String id) async {
    await _ensureCacheLoaded();
    _customQuestionsCache.removeWhere((q) => q.id == id);
    await _persistCustomQuestions();
  }

  @override
  Future<void> resetToDefaults() async {
    await _ensureCacheLoaded();
    _customQuestionsCache.clear();
    await _persistCustomQuestions();
  }

  Future<void> _persistCustomQuestions() async {
    try {
      final prefs = await _getPrefs();
      final stringList = _customQuestionsCache
          .map((q) => jsonEncode(q.toMap()))
          .toList();
      await prefs.setStringList(_customQuestionsKey, stringList);
    } catch (_) {
      // Ignored in headless tests
    }
  }
}
