class StudyQuote {
  const StudyQuote({
    required this.text,
    required this.author,
  });

  final String text;
  final String author;

  StudyQuote copyWith({
    String? text,
    String? author,
  }) {
    return StudyQuote(
      text: text ?? this.text,
      author: author ?? this.author,
    );
  }

  factory StudyQuote.fromMap(Map<String, dynamic> map) => StudyQuote(
        text: map['text'] as String? ?? '',
        author: map['author'] as String? ?? '',
      );

  factory StudyQuote.fromJson(Map<String, dynamic> json) => StudyQuote.fromMap(json);

  Map<String, dynamic> toMap() => {
        'text': text,
        'author': author,
      };
}
