import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/note_model.dart';

class NoteRepository {
  NoteRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<List<Note>> getAllNotes() async {
    final rows = await _databaseHelper.query(
      DatabaseTables.notes,
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> getNoteById(int id) async {
    final rows = await _databaseHelper.query(
      DatabaseTables.notes,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Note.fromMap(rows.first);
  }

  Future<int> createNote(Note note) async {
    return _databaseHelper.insert(
      DatabaseTables.notes,
      note.toMap()..remove('id'),
    );
  }

  Future<int> updateNote(Note note) async {
    return _databaseHelper.update(
      DatabaseTables.notes,
      note.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    return _databaseHelper.delete(
      DatabaseTables.notes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Note>> searchNotes(String keyword) async {
    final rows = await _databaseHelper.query(
      DatabaseTables.notes,
      where: 'title LIKE ? OR content LIKE ? OR subject LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  Future<List<Note>> getNotesBySubject(String subject) async {
    final rows = await _databaseHelper.query(
      DatabaseTables.notes,
      where: 'subject = ?',
      whereArgs: [subject],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  Future<List<Note>> getPinnedNotes() async {
    final rows = await _databaseHelper.query(
      DatabaseTables.notes,
      where: 'isPinned = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  Future<int> togglePinNote(int noteId, bool isPinned) async {
    return _databaseHelper.update(
      DatabaseTables.notes,
      {
        'isPinned': isPinned ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  Future<List<String>> getAllSubjects() async {
    final rows = await _databaseHelper.rawQuery(
      'SELECT DISTINCT subject FROM ${DatabaseTables.notes} ORDER BY subject ASC',
    );
    return rows
        .map((row) => row['subject'] as String? ?? '')
        .where((subject) => subject.isNotEmpty)
        .toList();
  }
}
