class Note {
  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.subject,
    this.tags,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String content;
  final String subject;
  final String? tags;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? subject,
    String? tags,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as int?,
        title: map['title'] as String? ?? '',
        content: map['content'] as String? ?? '',
        subject: map['subject'] as String? ?? '',
        tags: map['tags'] as String?,
        isPinned: (map['isPinned'] as int? ?? 0) == 1,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'subject': subject,
        'tags': tags,
        'isPinned': isPinned ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
