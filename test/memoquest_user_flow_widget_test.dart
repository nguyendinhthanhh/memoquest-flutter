import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:memoquest/app.dart';
import 'package:memoquest/core/constants/app_constants.dart';
import 'package:memoquest/data/database/database_helper.dart';
import 'package:memoquest/data/repositories/flashcard_repository.dart';
import 'package:memoquest/data/repositories/note_repository.dart';
import 'package:memoquest/data/repositories/quiz_repository.dart';
import 'package:memoquest/data/repositories/stats_repository.dart';
import 'package:memoquest/data/services/notification_service.dart';
import 'package:memoquest/data/services/shared_prefs_service.dart';
import 'package:memoquest/features/flashcards/widgets/flip_card_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;

  final databaseHelper = DatabaseHelper.instance;
  final noteRepository = NoteRepository(databaseHelper);
  final flashcardRepository = FlashcardRepository(databaseHelper);
  final quizRepository = QuizRepository(databaseHelper);
  final statsRepository = StatsRepository(databaseHelper);

  Future<void> pumpApp(
    WidgetTester tester, {
    required bool freshInstall,
  }) async {
    if (freshInstall) {
      SharedPreferences.setMockInitialValues({});
    }

    final prefs = SharedPrefsService();
    await prefs.init();

    if (freshInstall) {
      await prefs.setLoggedIn(false);
      await prefs.clearUserEmail();
      await prefs.setDarkMode(false);
      await prefs.setNotificationEnabled(true);
      await prefs.setReminderTime(AppConstants.defaultReminderTime);
      await prefs.setFirstLaunch(true);
    }

    await databaseHelper.database;
    if (freshInstall) {
      await databaseHelper.clearUserData();
    }
    await databaseHelper.seedInitialDataIfNeeded(prefs);
    // Native notification initialization is skipped in widget tests.

    await tester.pumpWidget(
      MemoQuestApp(
        sharedPrefsService: prefs,
        notificationService: NotificationService.instance,
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    await tester.ensureVisible(finder.first);
    await tester.tap(finder.first);
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String value,
  ) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, value);
    await tester.pumpAndSettle();
  }

  DateTime normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  bool isSameDate(DateTime left, DateTime right) {
    return normalizeDate(left) == normalizeDate(right);
  }

  void logStep(String message) {
    debugPrint('QA STEP: $message');
  }

  testWidgets(
    'full MemoQuest user flow passes in widget-driven e2e',
    (
    tester,
  ) async {
    const createdTitle = 'QA Flow Note';
    const editedTitle = 'QA Flow Note Updated';
    const subject = 'QA Subject';
    const editedSubject = 'QA Subject Advanced';
    const tags = 'qa,flow';
    const content =
        'MemoQuest flow testing validates note creation. Integration testing catches regressions early. Flutter widgets stay stable with deterministic checks.';
    const editedContent =
        'MemoQuest flow testing validates editing. Integration testing catches regressions early. Flutter widgets stay stable with deterministic checks.';
    const manualQuestion = 'What is regression testing?';
    const manualAnswer =
        'Regression testing verifies existing behavior still works after changes.';

    logStep('1 fresh install, 2 splash to login');
    await pumpApp(tester, freshInstall: true);

    expect(find.text('MemoQuest'), findsOneWidget);
    expect(find.text('Sign In To MemoQuest'), findsOneWidget);

    final loginFields = find.byType(EditableText);

    logStep('3 login wrong account');
    await enterText(tester, loginFields.at(0), 'wrong@example.com');
    await enterText(tester, loginFields.at(1), '654321');
    await tapText(tester, 'Sign In');
    expect(find.text('Home'), findsNothing);
    expect(find.text('Incorrect email or password.'), findsOneWidget);

    logStep('4 login correct account');
    await enterText(tester, loginFields.at(0), AppConstants.mockEmail);
    await enterText(tester, loginFields.at(1), AppConstants.mockPassword);
    await tapText(tester, 'Sign In');
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);

    logStep('5 create note');
    await tapText(tester, 'Notes');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final noteFields = find.byType(EditableText);
    await enterText(tester, noteFields.at(0), createdTitle);
    await enterText(tester, noteFields.at(1), subject);
    await enterText(tester, noteFields.at(2), tags);
    await enterText(tester, noteFields.at(3), content);
    await tapText(tester, 'Save Note');
    expect(find.text(createdTitle), findsOneWidget);

    logStep('6 edit note');
    await tapText(tester, createdTitle);
    expect(find.text('Note Detail'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    final editFields = find.byType(EditableText);
    await enterText(tester, editFields.at(0), editedTitle);
    await enterText(tester, editFields.at(1), editedSubject);
    await enterText(tester, editFields.at(2), tags);
    await enterText(tester, editFields.at(3), editedContent);
    await tapText(tester, 'Save Note');
    expect(find.text(editedTitle), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    logStep('7 pin note');
    await tester.tap(find.byIcon(Icons.push_pin_outlined).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.push_pin), findsWidgets);

    logStep('8 search note');
    final searchField = find.byType(EditableText).first;
    await enterText(tester, searchField, 'Updated');
    expect(find.text(editedTitle), findsOneWidget);
    expect(find.text('Flutter Widget Tree'), findsNothing);

    logStep('9 open note detail');
    await tapText(tester, editedTitle);
    expect(find.text('Note Detail'), findsOneWidget);
    expect(find.textContaining(editedSubject), findsOneWidget);

    logStep('10 generate flashcard, 11 save generated flashcards');
    await tapText(tester, 'Generate Flashcards');
    expect(find.text('Generate Flashcards'), findsWidgets);
    await tapText(tester, 'Generate Flashcards');
    expect(find.text('Save All'), findsOneWidget);
    await tapText(tester, 'Save All');
    expect(find.text('Note Detail'), findsOneWidget);

    logStep('12 create flashcard manually');
    await tapText(tester, 'View Flashcards');
    expect(find.text('Flashcards'), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final flashcardFields = find.byType(EditableText);
    await enterText(tester, flashcardFields.at(0), manualQuestion);
    await enterText(tester, flashcardFields.at(1), manualAnswer);
    await tapText(tester, 'Save Flashcard');
    expect(find.text(manualQuestion), findsOneWidget);

    final note = (await noteRepository.getAllNotes()).firstWhere(
      (item) => item.title == editedTitle,
    );

    final filteredCards = (await flashcardRepository.getAllFlashcards())
        .where((card) => card.noteId == note.id)
        .toList();
    expect(filteredCards.length, greaterThanOrEqualTo(3));

    final hardCard = filteredCards[0];
    final mediumCard = filteredCards[1];
    final easyCard = filteredCards[2];

    logStep('13 review flashcards, 14 choose difficulties');
    await tapText(tester, 'Start Review');
    expect(find.textContaining('Flashcard Review'), findsOneWidget);

    Future<void> rateCard(String buttonLabel) async {
      await tester.tap(find.byType(FlipCardView));
      await tester.pumpAndSettle();
      await tapText(tester, buttonLabel);
    }

    await rateCard('Hard');
    await rateCard('Medium');
    await rateCard('Easy');

    final remainingReviewCards = filteredCards.length - 3;
    for (var i = 0; i < remainingReviewCards; i++) {
      await rateCard('Easy');
    }

    expect(find.text('Review Complete'), findsOneWidget);
    await tapText(tester, 'OK');
    expect(find.text('Flashcards'), findsOneWidget);

    logStep('15 verify nextReviewDate');
    final hardUpdated = await flashcardRepository.getFlashcardById(hardCard.id!);
    final mediumUpdated = await flashcardRepository.getFlashcardById(
      mediumCard.id!,
    );
    final easyUpdated = await flashcardRepository.getFlashcardById(easyCard.id!);

    expect(hardUpdated, isNotNull);
    expect(mediumUpdated, isNotNull);
    expect(easyUpdated, isNotNull);

    expect(
      isSameDate(
        hardUpdated!.nextReviewDate,
        DateTime.now().add(const Duration(days: 1)),
      ),
      isTrue,
    );
    expect(
      isSameDate(
        mediumUpdated!.nextReviewDate,
        DateTime.now().add(const Duration(days: 3)),
      ),
      isTrue,
    );
    expect(
      isSameDate(
        easyUpdated!.nextReviewDate,
        DateTime.now().add(const Duration(days: 7)),
      ),
      isTrue,
    );

    logStep('16 start quiz, 17 reach last question, 18 finish quiz');
    final cardsForQuiz = (await flashcardRepository.getAllFlashcards())
        .where((card) => card.noteId == note.id)
        .toList();
    final answersByQuestion = {
      for (final card in cardsForQuiz) card.question: card.answer,
    };

    await tapText(tester, 'Start Quiz');
    expect(find.text('Quiz Mode'), findsOneWidget);

    for (var index = 0; index < cardsForQuiz.length; index++) {
      final cardTexts = find.descendant(
        of: find.byType(Card).at(0),
        matching: find.byType(Text),
      );
      final questionTextWidget = tester.widget<Text>(cardTexts.last);
      final currentQuestion = questionTextWidget.data!;
      final correctAnswer = answersByQuestion[currentQuestion]!;
      await tapText(tester, correctAnswer);
      await tapText(
        tester,
        index == cardsForQuiz.length - 1 ? 'Finish' : 'Next',
      );
    }

    expect(find.text('Quiz Result'), findsOneWidget);

    final latestResult = await quizRepository.getLatestQuizResult();
    expect(latestResult, isNotNull);
    expect(latestResult!.correctAnswers, cardsForQuiz.length);
    expect(latestResult.totalQuestions, cardsForQuiz.length);
    expect(latestResult.accuracy, 100);
    expect(latestResult.xpEarned, cardsForQuiz.length * 10);

    expect(
      find.text('${cardsForQuiz.length}/${cardsForQuiz.length}'),
      findsOneWidget,
    );
    expect(find.text('100.0%'), findsOneWidget);
    expect(find.text('${cardsForQuiz.length * 10}'), findsWidgets);

    logStep('19 verify score accuracy xp, 20 verify streak');
    final progressAfterQuiz = await statsRepository.getUserProgress();
    final expectedReviewXp = filteredCards.length * 5;
    final expectedQuizXp = cardsForQuiz.length * 10;
    expect(progressAfterQuiz.xp, expectedReviewXp + expectedQuizXp);
    expect(progressAfterQuiz.streak, 1);

    logStep('21 home dashboard');
    await tapText(tester, 'Back Home');
    expect(find.text('Home'), findsOneWidget);

    final totalNotes = await statsRepository.getTotalNotes();
    final totalFlashcards = await statsRepository.getTotalFlashcards();
    final dueToday = await statsRepository.getDueTodayCount();

    expect(find.text('$totalNotes'), findsWidgets);
    expect(find.text('$dueToday'), findsWidgets);

    logStep('22 stats');
    await tapText(tester, 'Stats');
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('XP: ${progressAfterQuiz.xp}'), findsOneWidget);
    expect(find.text('Streak: ${progressAfterQuiz.streak} days'), findsOneWidget);
    expect(find.text('Total Notes'), findsOneWidget);
    expect(find.text('$totalFlashcards'), findsWidgets);
    expect(find.text('Average accuracy: 100.0%'), findsOneWidget);

    logStep('23 dark mode, 24 restart app and verify persistence');
    await tapText(tester, 'Settings');
    var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    await pumpApp(tester, freshInstall: false);
    expect(find.text('Home'), findsOneWidget);
    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    logStep('25 test notification');
    await tapText(tester, 'Settings');
    await tapText(tester, 'Test Notification');
    expect(find.text('Settings'), findsOneWidget);

    logStep('26 clear all data, 27 verify no crash after clear');
    await tapText(tester, 'Clear All Data');
    await tapText(tester, 'Confirm');
    expect(find.text('Study data has been reset.'), findsOneWidget);

    await tapText(tester, 'Home');
    expect(find.text('0'), findsWidgets);
    await tapText(tester, 'Notes');
    expect(find.text('No Notes Yet'), findsOneWidget);
    await tapText(tester, 'Cards');
    expect(find.text('No Flashcards Yet'), findsOneWidget);
    await tapText(tester, 'Stats');
    expect(find.text('XP: 0'), findsOneWidget);
    expect(find.text('Streak: 0 days'), findsOneWidget);

    logStep('28 logout, 29 reopen app and verify login');
    await tapText(tester, 'Settings');
    await tapText(tester, 'Logout');
    expect(find.text('Sign In To MemoQuest'), findsOneWidget);

    await pumpApp(tester, freshInstall: false);
    expect(find.text('Sign In To MemoQuest'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  },
    timeout: Timeout.none,
    // Blocked by sqflite FFI database boot in flutter_tester on Windows.
    skip: true,
  );
}
