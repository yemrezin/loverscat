/// Supported question formats.
enum QuestionType {
  multipleChoice,
  openEnded,
}

/// Represents a quiz question.
class QuizQuestion {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final bool isCustom;

  const QuizQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    this.isCustom = false,
  });

  bool get isMultipleChoice => type == QuestionType.multipleChoice;
  bool get isOpenEnded => type == QuestionType.openEnded;

  QuizQuestion copyWith({
    String? id,
    String? text,
    QuestionType? type,
    List<String>? options,
    bool? isCustom,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'options': options,
      'isCustom': isCustom,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      text: map['text'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: List<String>.from(map['options'] ?? []),
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
