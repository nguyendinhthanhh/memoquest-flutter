import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/flashcard_model.dart';
import '../../home/providers/home_provider.dart';
import '../../quiz/screens/quiz_history_screen.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/flashcard_card.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({
    super.key,
    this.noteIdFilter,
    this.standalone = false,
  });

  final int? noteIdFilter;
  final bool standalone;

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  String _difficultyFilter = 'All';

  List<Flashcard> _applyFilters(List<Flashcard> source) {
    var cards = source;
    if (widget.noteIdFilter != null) {
      cards = cards.where((card) => card.noteId == widget.noteIdFilter).toList();
    }
    if (_difficultyFilter != 'All') {
      cards = cards
          .where(
            (card) =>
                card.difficulty.toLowerCase() == _difficultyFilter.toLowerCase(),
          )
          .toList();
    }
    return cards;
  }

  Future<void> _refreshOverviewData() async {
    await Future.wait([
      context.read<HomeProvider>().loadHomeData(),
      context.read<StatsProvider>().loadStats(),
    ]);
  }

  Future<void> _deleteCard(Flashcard card) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Flashcard',
      content: 'Are you sure you want to delete this flashcard?',
    );
    if (!confirmed || !mounted) {
      return;
    }

    final provider = context.read<FlashcardProvider>();
    await provider.removeFlashcard(card.id!);
    if (!mounted) {
      return;
    }
    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
      return;
    }

    await _refreshOverviewData();
  }

  Future<void> _startReview(List<Flashcard> cards) async {
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No flashcards match the current review filter.'),
        ),
      );
      return;
    }
    await Navigator.pushNamed(
      context,
      RouteNames.review,
      arguments: {
        'cards': cards,
        'title': 'Review Flashcards',
      },
    );
    if (!mounted) {
      return;
    }
    await _refreshOverviewData();
  }

  Future<void> _startQuiz(List<Flashcard> cards) async {
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No flashcards match the current quiz filter.'),
        ),
      );
      return;
    }
    await Navigator.pushNamed(
      context,
      RouteNames.quiz,
      arguments: {'cards': cards},
    );
    if (!mounted) {
      return;
    }
    await _refreshOverviewData();
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<FlashcardProvider>(
      builder: (context, flashcardProvider, _) {
        if (flashcardProvider.isLoading && flashcardProvider.flashcards.isEmpty) {
          return const LoadingView();
        }
        if (flashcardProvider.errorMessage != null &&
            flashcardProvider.flashcards.isEmpty) {
          return ErrorView(
            message: flashcardProvider.errorMessage!,
            onRetry: () async {
              await flashcardProvider.loadFlashcards();
              await flashcardProvider.loadDueFlashcards();
            },
          );
        }

        final cards = _applyFilters(flashcardProvider.flashcards);
        final dueCards = _applyFilters(flashcardProvider.dueFlashcards);

        return RefreshIndicator(
          onRefresh: () async {
            await flashcardProvider.loadFlashcards();
            await flashcardProvider.loadDueFlashcards();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Today: ${dueCards.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _startReview(
                              dueCards.isNotEmpty ? dueCards : cards,
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Start Review'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _startQuiz(cards),
                            icon: const Icon(Icons.quiz_outlined),
                            label: const Text('Start Quiz'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const QuizHistoryScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('Quiz History'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['All', 'Hard', 'Medium', 'Easy']
                    .map(
                      (filter) => ChoiceChip(
                        label: Text(filter),
                        selected: _difficultyFilter == filter,
                        onSelected: (_) => setState(() => _difficultyFilter = filter),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              if (cards.isEmpty)
                const EmptyView(
                  title: 'No Flashcards Yet',
                  subtitle:
                      'Create one manually or generate flashcards from a note.',
                  icon: Icons.style_outlined,
                )
              else
                ...cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FlashcardCard(
                      flashcard: card,
                      onEdit: () async {
                        await Navigator.pushNamed(
                          context,
                          RouteNames.addEditFlashcard,
                          arguments: {
                            'flashcard': card.toMap(),
                            'noteId': card.noteId,
                          },
                        );
                        if (!mounted) {
                          return;
                        }
                        await _refreshOverviewData();
                      },
                      onDelete: () => _deleteCard(card),
                    ),
                  ),
                ),
              const SizedBox(height: 96),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.standalone) {
      return _buildContent(context);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            RouteNames.addEditFlashcard,
            arguments: {'noteId': widget.noteIdFilter},
          );
          if (!mounted) {
            return;
          }
          await _refreshOverviewData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      body: _buildContent(context),
    );
  }
}
