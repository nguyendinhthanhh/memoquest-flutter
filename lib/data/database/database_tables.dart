class DatabaseTables {
  static const notes = 'notes';
  static const flashcards = 'flashcards';
  static const quizResults = 'quiz_results';
  static const userProgress = 'user_progress';

  static const createNotesTable = '''
  CREATE TABLE $notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    subject TEXT NOT NULL,
    tags TEXT,
    isPinned INTEGER NOT NULL DEFAULT 0,
    createdAt TEXT NOT NULL,
    updatedAt TEXT NOT NULL
  );
  ''';

  static const createFlashcardsTable = '''
  CREATE TABLE $flashcards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    noteId INTEGER,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    difficulty TEXT NOT NULL DEFAULT 'Medium',
    nextReviewDate TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    updatedAt TEXT NOT NULL,
    FOREIGN KEY (noteId) REFERENCES $notes(id) ON DELETE CASCADE
  );
  ''';

  static const createQuizResultsTable = '''
  CREATE TABLE $quizResults (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    totalQuestions INTEGER NOT NULL,
    correctAnswers INTEGER NOT NULL,
    xpEarned INTEGER NOT NULL,
    accuracy REAL NOT NULL,
    createdAt TEXT NOT NULL
  );
  ''';

  static const createUserProgressTable = '''
  CREATE TABLE $userProgress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    xp INTEGER NOT NULL DEFAULT 0,
    level INTEGER NOT NULL DEFAULT 1,
    streak INTEGER NOT NULL DEFAULT 0,
    lastStudyDate TEXT,
    updatedAt TEXT NOT NULL
  );
  ''';
}
