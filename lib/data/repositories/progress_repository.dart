import '../../core/utils/date_utils.dart';
import '../../core/utils/xp_utils.dart';
import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/user_progress_model.dart';

class ProgressRepository {
  ProgressRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<UserProgress> getProgress() async {
    final rows = await _databaseHelper.query(
      DatabaseTables.userProgress,
      orderBy: 'id ASC',
      limit: 1,
    );
    if (rows.isEmpty) {
      final now = DateTime.now();
      final progress = UserProgress(
        xp: 0,
        level: 1,
        streak: 0,
        updatedAt: now,
      );
      final id = await _databaseHelper.insert(
        DatabaseTables.userProgress,
        progress.toMap()..remove('id'),
      );
      return progress.copyWith(id: id);
    }
    return UserProgress.fromMap(rows.first);
  }

  Future<void> updateProgress(UserProgress progress) async {
    await _databaseHelper.update(
      DatabaseTables.userProgress,
      progress.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }

  Future<void> addXP(int xp) async {
    final progress = await getProgress();
    final newXp = progress.xp + xp;
    final updated = progress.copyWith(
      xp: newXp,
      level: XpUtils.calculateLevel(newXp),
      updatedAt: DateTime.now(),
    );
    await updateProgress(updated);
  }

  Future<void> updateStudyStreak() async {
    final progress = await getProgress();
    final today = DateTime.now();

    int newStreak = progress.streak;
    if (progress.lastStudyDate == null) {
      newStreak = 1;
    } else if (AppDateUtils.isSameDay(progress.lastStudyDate!, today)) {
      newStreak = progress.streak;
    } else if (AppDateUtils.isYesterday(progress.lastStudyDate!, today)) {
      newStreak = progress.streak + 1;
    } else {
      newStreak = 1;
    }

    await updateProgress(
      progress.copyWith(
        streak: newStreak,
        lastStudyDate: today,
        updatedAt: today,
      ),
    );
  }
}
