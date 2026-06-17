class Flashcard {
  const Flashcard({
    this.id,
    this.noteId,
    required this.question,
    required this.answer,
    required this.difficulty,
    required this.nextReviewDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int? noteId;
  final String question;
  final String answer;
  final String difficulty;
  final DateTime nextReviewDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard copyWith({
    int? id,
    int? noteId,
    String? question,
    String? answer,
    String? difficulty,
    DateTime? nextReviewDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      difficulty: difficulty ?? this.difficulty,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
        id: map['id'] as int?,
        noteId: map['noteId'] as int?,
        question: map['question'] as String? ?? '',
        answer: map['answer'] as String? ?? '',
        difficulty: map['difficulty'] as String? ?? 'Medium',
        nextReviewDate: DateTime.parse(map['nextReviewDate'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'noteId': noteId,
        'question': question,
        'answer': answer,
        'difficulty': difficulty,
        'nextReviewDate': nextReviewDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
