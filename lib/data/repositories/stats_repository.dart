import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/user_progress_model.dart';

class StatsRepository {
  StatsRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<int> getTotalNotes() async {
    final rows = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) AS count FROM ${DatabaseTables.notes}',
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> getTotalFlashcards() async {
    final rows = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) AS count FROM ${DatabaseTables.flashcards}',
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> getDueTodayCount() async {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final rows = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) AS count FROM ${DatabaseTables.flashcards} WHERE nextReviewDate <= ?',
      [normalized.toIso8601String()],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> getTotalQuizCount() async {
    final rows = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) AS count FROM ${DatabaseTables.quizResults}',
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<double> getAverageAccuracy() async {
    final rows = await _databaseHelper.rawQuery(
      'SELECT AVG(accuracy) AS value FROM ${DatabaseTables.quizResults}',
    );
    return (rows.first['value'] as num?)?.toDouble() ?? 0;
  }

  Future<Map<String, int>> getNotesBySubject() async {
    final rows = await _databaseHelper.rawQuery(
      'SELECT subject, COUNT(*) AS count FROM ${DatabaseTables.notes} GROUP BY subject ORDER BY count DESC',
    );
    return {
      for (final row in rows) row['subject'] as String: (row['count'] as int?) ?? 0,
    };
  }

  Future<Map<String, int>> getFlashcardsByDifficulty() async {
    final rows = await _databaseHelper.rawQuery(
      'SELECT difficulty, COUNT(*) AS count FROM ${DatabaseTables.flashcards} GROUP BY difficulty ORDER BY count DESC',
    );
    return {
      for (final row in rows)
        row['difficulty'] as String: (row['count'] as int?) ?? 0,
    };
  }

  Future<UserProgress> getUserProgress() async {
    final rows = await _databaseHelper.query(
      DatabaseTables.userProgress,
      orderBy: 'id ASC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return UserProgress(
        xp: 0,
        level: 1,
        streak: 0,
        updatedAt: DateTime.now(),
      );
    }
    return UserProgress.fromMap(rows.first);
  }
}
