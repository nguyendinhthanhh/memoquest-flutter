import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    await context.read<AuthProvider>().checkAuthStatus();
    if (!mounted) {
      return;
    }
    final authProvider = context.read<AuthProvider>();
    Navigator.pushReplacementNamed(
      context,
      authProvider.isLoggedIn ? RouteNames.main : RouteNames.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories_rounded, size: 72, color: Colors.white),
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
                'Study smarter, review better.',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
