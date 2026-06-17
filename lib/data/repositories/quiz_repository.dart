import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/quiz_result_model.dart';

class QuizRepository {
  QuizRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<QuizResult>> getQuizHistory() async {
    final rows = await _databaseHelper.query(
      DatabaseTables.quizResults,
      orderBy: 'createdAt DESC',
    );
    return rows.map(QuizResult.fromMap).toList();
  }

  Future<int> saveQuizResult(QuizResult result) async {
    return _databaseHelper.insert(
      DatabaseTables.quizResults,
      result.toMap()..remove('id'),
    );
  }

  Future<double> getAverageAccuracy() async {
    final rows = await _databaseHelper.rawQuery(
      'SELECT AVG(accuracy) AS avgAccuracy FROM ${DatabaseTables.quizResults}',
    );
    if (rows.isEmpty || rows.first['avgAccuracy'] == null) {
      return 0;
    }
    return (rows.first['avgAccuracy'] as num).toDouble();
  }

  Future<QuizResult?> getLatestQuizResult() async {
    final rows = await _databaseHelper.query(
      DatabaseTables.quizResults,
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return QuizResult.fromMap(rows.first);
  }
}
