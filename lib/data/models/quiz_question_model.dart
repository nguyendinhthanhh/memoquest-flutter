import 'dart:convert';

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.selectedAnswer,
    this.isCorrect,
  });

  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? selectedAnswer;
  final bool? isCorrect;

  QuizQuestion copyWith({
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? selectedAnswer,
    bool? isCorrect,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
        question: map['question'] as String? ?? '',
        options: (jsonDecode(map['options'] as String) as List<dynamic>)
            .map((item) => item.toString())
            .toList(),
        correctAnswer: map['correctAnswer'] as String? ?? '',
        selectedAnswer: map['selectedAnswer'] as String?,
        isCorrect: map['isCorrect'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'question': question,
        'options': jsonEncode(options),
        'correctAnswer': correctAnswer,
        'selectedAnswer': selectedAnswer,
        'isCorrect': isCorrect,
      };
}
