class UserProgress {
  const UserProgress({
    this.id,
    required this.xp,
    required this.level,
    required this.streak,
    this.lastStudyDate,
    required this.updatedAt,
  });

  final int? id;
  final int xp;
  final int level;
  final int streak;
  final DateTime? lastStudyDate;
  final DateTime updatedAt;

  UserProgress copyWith({
    int? id,
    int? xp,
    int? level,
    int? streak,
    DateTime? lastStudyDate,
    DateTime? updatedAt,
  }) {
    return UserProgress(
      id: id ?? this.id,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) => UserProgress(
        id: map['id'] as int?,
        xp: map['xp'] as int? ?? 0,
        level: map['level'] as int? ?? 1,
        streak: map['streak'] as int? ?? 0,
        lastStudyDate: (map['lastStudyDate'] as String?) == null
            ? null
            : DateTime.parse(map['lastStudyDate'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'xp': xp,
        'level': level,
        'streak': streak,
        'lastStudyDate': lastStudyDate?.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
