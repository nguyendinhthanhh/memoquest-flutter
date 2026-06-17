import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../../flashcards/providers/flashcard_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../notes/providers/note_provider.dart';
import '../../quiz/providers/quiz_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTime(BuildContext context) async {
    final provider = context.read<SettingsProvider>();
    final parts = provider.reminderTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 19,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime == null || !context.mounted) {
      return;
    }
    await provider.updateReminderTime(
      AppDateUtils.formatTimeOfDay(selectedTime.hour, selectedTime.minute),
    );
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Clear all data',
      content: 'All notes, flashcards, and quiz results will be deleted.',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final settingsProvider = context.read<SettingsProvider>();
    final noteProvider = context.read<NoteProvider>();
    final flashcardProvider = context.read<FlashcardProvider>();
    final quizProvider = context.read<QuizProvider>();
    final statsProvider = context.read<StatsProvider>();
    final homeProvider = context.read<HomeProvider>();

    await settingsProvider.clearAllData();
    await Future.wait([
      noteProvider.loadNotes(),
      flashcardProvider.loadFlashcards(),
      flashcardProvider.loadDueFlashcards(),
      quizProvider.loadQuizHistory(),
      statsProvider.loadStats(),
      homeProvider.loadHomeData(),
    ]);

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All study data has been cleared.')),
    );
  }

  Future<void> _restoreSampleData(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Restore sample data',
      content:
          'This will replace current notes, flashcards, and quiz results with sample test data.',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final settingsProvider = context.read<SettingsProvider>();
    final noteProvider = context.read<NoteProvider>();
    final flashcardProvider = context.read<FlashcardProvider>();
    final quizProvider = context.read<QuizProvider>();
    final statsProvider = context.read<StatsProvider>();
    final homeProvider = context.read<HomeProvider>();

    await settingsProvider.restoreSampleData();
    await Future.wait([
      noteProvider.loadNotes(),
      flashcardProvider.loadFlashcards(),
      flashcardProvider.loadDueFlashcards(),
      quizProvider.loadQuizHistory(),
      statsProvider.loadStats(),
      homeProvider.loadHomeData(),
    ]);

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample test data is ready.')),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (!context.mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AuthProvider>(
      builder: (context, settingsProvider, authProvider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Current user'),
                subtitle: Text(
                  authProvider.currentUserEmail ?? 'student@memoquest.com',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              title: const Text('Dark mode'),
              subtitle: const Text('Turn the dark theme on or off'),
              value: settingsProvider.darkMode,
              onChanged: settingsProvider.toggleDarkMode,
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              title: const Text('Notifications'),
              subtitle: const Text('Daily review reminders'),
              value: settingsProvider.notificationEnabled,
              onChanged: settingsProvider.toggleNotification,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: const Text('Reminder time'),
                subtitle: Text(settingsProvider.reminderTime),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickTime(context),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: settingsProvider.testNotification,
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Test Notification'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _clearAllData(context),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear All Data'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _restoreSampleData(context),
              icon: const Icon(Icons.restore_page_outlined),
              label: const Text('Restore Sample Data'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
