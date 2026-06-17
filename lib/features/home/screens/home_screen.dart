import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/utils/xp_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/stat_card.dart';
import '../../flashcards/providers/flashcard_provider.dart';
import '../../stats/screens/stats_screen.dart';
import '../providers/home_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    await Future.wait([
      context.read<HomeProvider>().loadHomeData(),
      context.read<FlashcardProvider>().loadFlashcards(),
      context.read<FlashcardProvider>().loadDueFlashcards(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, FlashcardProvider>(
      builder: (context, homeProvider, flashcardProvider, _) {
        if (homeProvider.isLoading && homeProvider.progress == null) {
          return const LoadingView();
        }

        if (homeProvider.errorMessage != null && homeProvider.progress == null) {
          return ErrorView(
            message: homeProvider.errorMessage!,
            onRetry: () => _refresh(context),
          );
        }

        final progress = homeProvider.progress;
        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeProvider.dailyQuote?.text ??
                            'Small progress is still progress.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        homeProvider.dailyQuote?.author ?? 'MemoQuest',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    title: 'Current XP',
                    value: '${progress?.xp ?? 0}',
                    subtitle: progress == null
                        ? null
                        : 'Lv.${progress.level} ${XpUtils.getLevelTitle(progress.level)}',
                    icon: Icons.bolt,
                  ),
                  StatCard(
                    title: 'Streak',
                    value: '${progress?.streak ?? 0} days',
                    icon: Icons.local_fire_department_outlined,
                  ),
                  StatCard(
                    title: 'Notes',
                    value: '${homeProvider.notesCount}',
                    icon: Icons.sticky_note_2_outlined,
                  ),
                  StatCard(
                    title: 'Due Today',
                    value: '${homeProvider.dueTodayCount}',
                    icon: Icons.alarm_outlined,
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
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 160,
                            child: AppButton(
                              label: 'Create Note',
                              icon: Icons.note_add_outlined,
                              onPressed: () async {
                                await Navigator.pushNamed(
                                  context,
                                  RouteNames.addEditNote,
                                );
                                if (context.mounted) {
                                  await _refresh(context);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: AppButton(
                              label: 'Review Due Cards',
                              icon: Icons.refresh,
                              onPressed: () async {
                                if (flashcardProvider.dueFlashcards.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'There are no cards due for review right now.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                await Navigator.pushNamed(
                                  context,
                                  RouteNames.review,
                                  arguments: {
                                    'cards': flashcardProvider.dueFlashcards,
                                    'title': 'Review Due Cards',
                                  },
                                );
                                if (context.mounted) {
                                  await _refresh(context);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: AppButton(
                              label: 'Start Quiz',
                              icon: Icons.quiz_outlined,
                              onPressed: () async {
                                if (flashcardProvider.flashcards.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'You need at least one flashcard to start a quiz.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                await Navigator.pushNamed(
                                  context,
                                  RouteNames.quiz,
                                  arguments: {
                                    'cards': flashcardProvider.flashcards,
                                  },
                                );
                                if (context.mounted) {
                                  await _refresh(context);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: AppButton(
                              label: 'View Stats',
                              icon: Icons.bar_chart_outlined,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StatsScreen(
                                      standalone: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (homeProvider.sampleDecks.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sample Decks',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ...homeProvider.sampleDecks.map(
                          (deck) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.layers_outlined),
                            title: Text(deck['title'].toString()),
                            subtitle: Text('${deck['cards']} cards'),
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
}
