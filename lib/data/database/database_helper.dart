import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/review_utils.dart';
import '../../core/utils/xp_utils.dart';
import '../models/flashcard_model.dart';
import '../models/note_model.dart';
import '../models/user_progress_model.dart';
import '../services/shared_prefs_service.dart';
import 'database_tables.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await databaseFactory.getDatabasesPath();
    await Directory(dbPath).create(recursive: true);
    final path = p.join(dbPath, AppConstants.databaseName);

    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: AppConstants.databaseVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: onCreate,
        onUpgrade: onUpgrade,
      ),
    );
  }

  Future<void> onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createNotesTable);
    await db.execute(DatabaseTables.createFlashcardsTable);
    await db.execute(DatabaseTables.createQuizResultsTable);
    await db.execute(DatabaseTables.createUserProgressTable);
    await _seedDefaultProgress(db);
  }

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = p.join(dbPath, AppConstants.databaseName);
    await closeDatabase();

    for (final candidate in [
      path,
      '$path-wal',
      '$path-shm',
      '$path-journal',
    ]) {
      final file = File(candidate);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  Future<void> clearUserData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseTables.flashcards);
      await txn.delete(DatabaseTables.notes);
      await txn.delete(DatabaseTables.quizResults);
      await txn.delete(DatabaseTables.userProgress);
      await _seedDefaultProgress(txn);
    });
  }

  Future<void> restoreSampleData(SharedPrefsService prefs) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseTables.flashcards);
      await txn.delete(DatabaseTables.notes);
      await txn.delete(DatabaseTables.quizResults);
      await txn.delete(DatabaseTables.userProgress);
      await _seedDefaultProgress(txn);
      await _seedSampleNotesAndCards(txn);
    });
    await prefs.setFirstLaunch(false);
  }

  Future<void> seedInitialDataIfNeeded(SharedPrefsService prefs) async {
    final db = await database;
    final firstLaunch = await prefs.getFirstLaunch();
    final noteCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseTables.notes}'),
        ) ??
        0;

    if (!firstLaunch && noteCount > 0) {
      await _ensureProgressExists(db);
      return;
    }

    if (noteCount == 0) {
      await _seedSampleNotesAndCards(db);
    }

    await _ensureProgressExists(db);
    await prefs.setFirstLaunch(false);
  }

  Future<void> _seedSampleNotesAndCards(DatabaseExecutor executor) async {
    final now = DateTime.now();
    final sampleNotes = [
      Note(
        title: 'Flutter Widget Tree',
        content:
            'A widget tree is the hierarchical structure of the entire Flutter UI. StatelessWidget renders immutable UI, while StatefulWidget renders UI that can change over time.',
        subject: 'Flutter',
        tags: 'flutter,widget,ui',
        createdAt: now,
        updatedAt: now,
      ),
      Note(
        title: 'FutureBuilder Basics',
        content:
            'FutureBuilder renders UI based on the state of a Future. Common states include loading, data, and error.',
        subject: 'Dart Async',
        tags: 'futurebuilder,async,state',
        createdAt: now,
        updatedAt: now,
      ),
      Note(
        title: 'SQLite Local Storage',
        content:
            'SQLite is a local database used in mobile apps to store structured data. A database helper is responsible for table creation and CRUD operations.',
        subject: 'Database',
        tags: 'sqlite,local-storage,database',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final insertedIds = <int>[];
    for (final note in sampleNotes) {
      insertedIds.add(
        await executor.insert(DatabaseTables.notes, note.toMap()..remove('id')),
      );
    }

    final sampleCards = [
      Flashcard(
        noteId: insertedIds[0],
        question: 'What is a widget tree?',
        answer: 'The hierarchical structure of the entire Flutter UI',
        difficulty: 'Medium',
        nextReviewDate: ReviewUtils.getNextReviewDate('Medium'),
        createdAt: now,
        updatedAt: now,
      ),
      Flashcard(
        noteId: insertedIds[0],
        question: 'When should you use StatefulWidget?',
        answer: 'When the UI needs to change over time based on state',
        difficulty: 'Hard',
        nextReviewDate: ReviewUtils.getNextReviewDate('Hard'),
        createdAt: now,
        updatedAt: now,
      ),
      Flashcard(
        noteId: insertedIds[1],
        question: 'What does FutureBuilder do?',
        answer: 'It renders UI based on the state of a Future',
        difficulty: 'Medium',
        nextReviewDate: ReviewUtils.getNextReviewDate('Medium'),
        createdAt: now,
        updatedAt: now,
      ),
      Flashcard(
        noteId: insertedIds[1],
        question: 'What states are common in FutureBuilder?',
        answer: 'Loading, data, and error',
        difficulty: 'Easy',
        nextReviewDate: ReviewUtils.getNextReviewDate('Easy'),
        createdAt: now,
        updatedAt: now,
      ),
      Flashcard(
        noteId: insertedIds[2],
        question: 'What is SQLite in a mobile app?',
        answer: 'A local database for structured data storage',
        difficulty: 'Medium',
        nextReviewDate: ReviewUtils.getNextReviewDate('Medium'),
        createdAt: now,
        updatedAt: now,
      ),
      Flashcard(
        noteId: insertedIds[2],
        question: 'What is the role of a database helper?',
        answer: 'Creating tables and handling CRUD operations',
        difficulty: 'Hard',
        nextReviewDate: ReviewUtils.getNextReviewDate('Hard'),
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final card in sampleCards) {
      await executor.insert(
        DatabaseTables.flashcards,
        card.toMap()..remove('id'),
      );
    }
  }

  Future<void> _seedDefaultProgress(DatabaseExecutor executor) async {
    final now = DateTime.now();
    final progress = UserProgress(
      xp: 0,
      level: XpUtils.calculateLevel(0),
      streak: 0,
      updatedAt: now,
    );
    await executor.insert(
      DatabaseTables.userProgress,
      progress.toMap()..remove('id'),
    );
  }

  Future<void> _ensureProgressExists(Database db) async {
    final progressCount = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ${DatabaseTables.userProgress}',
          ),
        ) ??
        0;
    if (progressCount == 0) {
      await _seedDefaultProgress(db);
    }
  }
}
