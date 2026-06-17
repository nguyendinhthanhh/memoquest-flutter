import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/route_names.dart';
import 'core/theme/app_theme.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/api_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/flashcard_repository.dart';
import 'data/repositories/note_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/quiz_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/stats_repository.dart';
import 'data/services/mock_api_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/shared_prefs_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/flashcards/providers/flashcard_provider.dart';
import 'features/flashcards/screens/add_edit_flashcard_screen.dart';
import 'features/flashcards/screens/flashcard_review_screen.dart';
import 'features/flashcards/screens/generate_flashcard_screen.dart';
import 'features/home/providers/home_provider.dart';
import 'features/main/screens/main_navigation_screen.dart';
import 'features/notes/providers/note_provider.dart';
import 'features/notes/screens/add_edit_note_screen.dart';
import 'features/notes/screens/note_detail_screen.dart';
import 'features/quiz/providers/quiz_provider.dart';
import 'features/quiz/screens/quiz_result_screen.dart';
import 'features/quiz/screens/quiz_screen.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/stats/providers/stats_provider.dart';

class MemoQuestApp extends StatelessWidget {
  MemoQuestApp({
    super.key,
    required this.sharedPrefsService,
    required this.notificationService,
  });

  final SharedPrefsService sharedPrefsService;
  final NotificationService notificationService;

  late final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late final AuthRepository _authRepository = AuthRepository(sharedPrefsService);
  late final NoteRepository _noteRepository = NoteRepository(_databaseHelper);
  late final ProgressRepository _progressRepository =
      ProgressRepository(_databaseHelper);
  late final FlashcardRepository _flashcardRepository =
      FlashcardRepository(_databaseHelper);
  late final QuizRepository _quizRepository = QuizRepository(_databaseHelper);
  late final StatsRepository _statsRepository = StatsRepository(_databaseHelper);
  late final SettingsRepository _settingsRepository = SettingsRepository(
    sharedPrefsService: sharedPrefsService,
    databaseHelper: _databaseHelper,
  );
  late final ApiRepository _apiRepository = ApiRepository(MockApiService());

  MaterialPageRoute<void> _invalidArgumentsRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Invalid Route')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Missing or invalid arguments for ${routeName ?? 'unknown route'}.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(_authRepository)),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            settingsRepository: _settingsRepository,
            notificationService: notificationService,
          )..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => NoteProvider(_noteRepository)..loadNotes(),
        ),
        ChangeNotifierProvider(
          create: (_) => FlashcardProvider(
            flashcardRepository: _flashcardRepository,
            progressRepository: _progressRepository,
          )
            ..loadFlashcards()
            ..loadDueFlashcards(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(
            quizRepository: _quizRepository,
            progressRepository: _progressRepository,
          )..loadQuizHistory(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatsProvider(_statsRepository)..loadStats(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            statsRepository: _statsRepository,
            apiRepository: _apiRepository,
          )..loadHomeData(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'MemoQuest',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                settingsProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: RouteNames.splash,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case RouteNames.splash:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case RouteNames.login:
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case RouteNames.main:
                  return MaterialPageRoute(
                    builder: (_) => const MainNavigationScreen(),
                  );
                case RouteNames.addEditNote:
                  return MaterialPageRoute(
                    builder: (_) => AddEditNoteScreen(
                      note: settings.arguments is Map<String, dynamic>
                          ? settings.arguments as Map<String, dynamic>
                          : null,
                    ),
                  );
                case RouteNames.noteDetail:
                  if (settings.arguments is! Map<String, dynamic>) {
                    return _invalidArgumentsRoute(settings.name);
                  }
                  return MaterialPageRoute(
                    builder: (_) => NoteDetailScreen(
                      note: settings.arguments as Map<String, dynamic>,
                    ),
                  );
                case RouteNames.generateFlashcard:
                  if (settings.arguments is! Map<String, dynamic>) {
                    return _invalidArgumentsRoute(settings.name);
                  }
                  return MaterialPageRoute(
                    builder: (_) => GenerateFlashcardScreen(
                      note: settings.arguments as Map<String, dynamic>,
                    ),
                  );
                case RouteNames.addEditFlashcard:
                  return MaterialPageRoute(
                    builder: (_) => AddEditFlashcardScreen(
                      data: settings.arguments is Map<String, dynamic>
                          ? settings.arguments as Map<String, dynamic>
                          : null,
                    ),
                  );
                case RouteNames.review:
                  if (settings.arguments is! Map<String, dynamic>) {
                    return _invalidArgumentsRoute(settings.name);
                  }
                  return MaterialPageRoute(
                    builder: (_) => FlashcardReviewScreen(
                      arguments: settings.arguments as Map<String, dynamic>,
                    ),
                  );
                case RouteNames.quiz:
                  if (settings.arguments is! Map<String, dynamic>) {
                    return _invalidArgumentsRoute(settings.name);
                  }
                  return MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      arguments: settings.arguments as Map<String, dynamic>,
                    ),
                  );
                case RouteNames.quizResult:
                  if (settings.arguments is! Map<String, dynamic>) {
                    return _invalidArgumentsRoute(settings.name);
                  }
                  return MaterialPageRoute(
                    builder: (_) => QuizResultScreen(
                      arguments: settings.arguments as Map<String, dynamic>,
                    ),
                  );
                default:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
              }
            },
          );
        },
      ),
    );
  }
}
