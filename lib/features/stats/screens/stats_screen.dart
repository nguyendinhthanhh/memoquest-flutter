import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/xp_utils.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/stat_card.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({
    super.key,
    this.standalone = false,
  });

  final bool standalone;

  Widget _buildContent(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, statsProvider, _) {
        if (statsProvider.isLoading && statsProvider.progress == null) {
          return const LoadingView();
        }
        if (statsProvider.errorMessage != null && statsProvider.progress == null) {
          return ErrorView(
            message: statsProvider.errorMessage!,
            onRetry: statsProvider.loadStats,
          );
        }
        final progress = statsProvider.progress;
        if (progress == null) {
          return const EmptyView(
            title: 'No Statistics Yet',
            subtitle:
                'Create notes, review flashcards, and finish quizzes to build your stats.',
            icon: Icons.bar_chart_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: statsProvider.loadStats,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    title: 'Total Notes',
                    value: '${statsProvider.totalNotes}',
                    icon: Icons.note_alt_outlined,
                  ),
                  StatCard(
                    title: 'Total Flashcards',
                    value: '${statsProvider.totalFlashcards}',
                    icon: Icons.style_outlined,
                  ),
                  StatCard(
                    title: 'Due Today',
                    value: '${statsProvider.dueToday}',
                    icon: Icons.alarm_outlined,
                  ),
                  StatCard(
                    title: 'Total Quizzes',
                    value: '${statsProvider.totalQuizzes}',
                    icon: Icons.quiz_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text('XP: ${progress.xp}'),
                      Text('Level: ${progress.level}'),
                      Text('Level title: ${XpUtils.getLevelTitle(progress.level)}'),
                      Text('Streak: ${progress.streak} days'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: XpUtils.calculateLevelProgress(progress.xp),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Average accuracy: ${statsProvider.averageAccuracy.toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes by Subject',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (statsProvider.notesBySubject.isEmpty)
                        const Text('No data yet.')
                      else
                        ...statsProvider.notesBySubject.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text(entry.key)),
                                Text('${entry.value}'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flashcards by Difficulty',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (statsProvider.cardsByDifficulty.isEmpty)
                        const Text('No data yet.')
                      else
                        ...statsProvider.cardsByDifficulty.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text(entry.key)),
                                Text('${entry.value}'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!standalone) {
      return _buildContent(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: _buildContent(context),
    );
  }
}
