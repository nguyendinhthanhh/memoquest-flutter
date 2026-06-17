import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/flashcard_model.dart';

class FlashcardRepository {
  FlashcardRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<Flashcard>> getAllFlashcards() async {
    final rows = await _databaseHelper.query(
      DatabaseTables.flashcards,
      orderBy: 'nextReviewDate ASC, updatedAt DESC',
    );
    return rows.map(Flashcard.fromMap).toList();
  }

  Future<Flashcard?> getFlashcardById(int id) async {
    final rows = await _databaseHelper.query(
      DatabaseTables.flashcards,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Flashcard.fromMap(rows.first);
  }

  Future<List<Flashcard>> getFlashcardsByNoteId(int noteId) async {
    final rows = await _databaseHelper.query(
      DatabaseTables.flashcards,
      where: 'noteId = ?',
      whereArgs: [noteId],
      orderBy: 'updatedAt DESC',
    );
    return rows.map(Flashcard.fromMap).toList();
  }

  Future<List<Flashcard>> getDueFlashcards(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final rows = await _databaseHelper.query(
      DatabaseTables.flashcards,
      where: 'nextReviewDate <= ?',
      whereArgs: [normalized.toIso8601String()],
      orderBy: 'nextReviewDate ASC',
    );
    return rows.map(Flashcard.fromMap).toList();
  }

  Future<List<Flashcard>> getRandomFlashcards(int limit) async {
    final rows = await _databaseHelper.query(
      DatabaseTables.flashcards,
      orderBy: 'RANDOM()',
      limit: limit,
    );
    return rows.map(Flashcard.fromMap).toList();
  }

  Future<int> createFlashcard(Flashcard flashcard) async {
    return _databaseHelper.insert(
      DatabaseTables.flashcards,
      flashcard.toMap()..remove('id'),
    );
  }

  Future<int> updateFlashcard(Flashcard flashcard) async {
    return _databaseHelper.update(
      DatabaseTables.flashcards,
      flashcard.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [flashcard.id],
    );
  }

  Future<int> deleteFlashcard(int id) async {
    return _databaseHelper.delete(
      DatabaseTables.flashcards,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateDifficultyAndNextReview(
    int id,
    String difficulty,
    DateTime nextReviewDate,
  ) async {
    final normalizedDifficulty = switch (difficulty.trim().toLowerCase()) {
      'hard' => 'Hard',
      'easy' => 'Easy',
      _ => 'Medium',
    };
    return _databaseHelper.update(
      DatabaseTables.flashcards,
      {
        'difficulty': normalizedDifficulty,
        'nextReviewDate': nextReviewDate.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
