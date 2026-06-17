import 'package:flutter/material.dart';

import 'app.dart';
import 'data/database/database_helper.dart';
import 'data/services/notification_service.dart';
import 'data/services/shared_prefs_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPrefsService = SharedPrefsService();
  await sharedPrefsService.init();

  runApp(
    _BootstrapApp(
      sharedPrefsService: sharedPrefsService,
      notificationService: NotificationService.instance,
    ),
  );
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp({
    required this.sharedPrefsService,
    required this.notificationService,
  });

  final SharedPrefsService sharedPrefsService;
  final NotificationService notificationService;

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    await DatabaseHelper.instance.database.timeout(const Duration(seconds: 10));
    await DatabaseHelper.instance
        .seedInitialDataIfNeeded(widget.sharedPrefsService)
        .timeout(const Duration(seconds: 10));
    await widget.notificationService
        .initialize()
        .timeout(const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.error == null) {
          return MemoQuestApp(
            sharedPrefsService: widget.sharedPrefsService,
            notificationService: widget.notificationService,
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 56),
                      const SizedBox(height: 16),
                      const Text(
                        'App startup failed.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _bootstrapFuture = _bootstrap();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF99F6E4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 72,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'MemoQuest',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Preparing your study workspace...',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
