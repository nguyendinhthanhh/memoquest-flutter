class QuizResult {
  const QuizResult({
    this.id,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpEarned,
    required this.accuracy,
    required this.createdAt,
  });

  final int? id;
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;
  final double accuracy;
  final DateTime createdAt;

  QuizResult copyWith({
    int? id,
    int? totalQuestions,
    int? correctAnswers,
    int? xpEarned,
    double? accuracy,
    DateTime? createdAt,
  }) {
    return QuizResult(
      id: id ?? this.id,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      xpEarned: xpEarned ?? this.xpEarned,
      accuracy: accuracy ?? this.accuracy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) => QuizResult(
        id: map['id'] as int?,
        totalQuestions: map['totalQuestions'] as int? ?? 0,
        correctAnswers: map['correctAnswers'] as int? ?? 0,
        xpEarned: map['xpEarned'] as int? ?? 0,
        accuracy: (map['accuracy'] as num? ?? 0).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'xpEarned': xpEarned,
        'accuracy': accuracy,
        'createdAt': createdAt.toIso8601String(),
      };
}
