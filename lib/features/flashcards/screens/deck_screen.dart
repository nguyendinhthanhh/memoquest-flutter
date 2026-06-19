import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/review_utils.dart';
import '../../../core/widgets/app_metric_band.dart';
import '../../../core/widgets/app_section_header.dart';
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
  const DeckScreen({super.key, this.noteIdFilter, this.standalone = false});

  final int? noteIdFilter;
  final bool standalone;

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  String _difficultyFilter = 'Tất cả';

  List<Flashcard> _applyFilters(List<Flashcard> source) {
    var cards = source;
    if (widget.noteIdFilter != null) {
      cards = cards
          .where((card) => card.noteId == widget.noteIdFilter)
          .toList();
    }
    if (_difficultyFilter != 'Tất cả') {
      cards = cards
          .where(
            (card) =>
                ReviewUtils.getDifficultyLabel(card.difficulty) ==
                _difficultyFilter,
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
      title: 'Xóa thẻ ghi nhớ',
      content: 'Bạn có chắc muốn xóa thẻ ghi nhớ này không?',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      return;
    }

    await _refreshOverviewData();
  }

  Future<void> _startReview(List<Flashcard> cards) async {
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có thẻ nào khớp với bộ lọc ôn tập hiện tại.'),
        ),
      );
      return;
    }
    await Navigator.pushNamed(
      context,
      RouteNames.review,
      arguments: {'cards': cards, 'title': 'Ôn thẻ ghi nhớ'},
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
          content: Text('Không có thẻ nào khớp với bộ lọc quiz hiện tại.'),
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
        if (flashcardProvider.isLoading &&
            flashcardProvider.flashcards.isEmpty) {
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontalCompact,
              AppSpacing.lg,
              AppSpacing.screenHorizontalCompact,
              144,
            ),
            children: [
              if (!widget.standalone) ...[
                const AppSectionHeader(
                  title: 'Thẻ ghi nhớ',
                  subtitle:
                      'Ôn tập, lọc theo độ khó và theo dõi các lượt cần xem lại.',
                  isPageHeader: true,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              AppMetricBand(
                items: [
                  AppMetricBandItem(
                    label: 'Đến hạn hôm nay',
                    value: '${dueCards.length}',
                  ),
                  AppMetricBandItem(
                    label: 'Tổng thẻ',
                    value: '${cards.length}',
                  ),
                  AppMetricBandItem(label: 'Bộ lọc', value: _difficultyFilter),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        _startReview(dueCards.isNotEmpty ? dueCards : cards),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Bắt đầu ôn'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _startQuiz(cards),
                    icon: const Icon(Icons.quiz_outlined),
                    label: const Text('Bắt đầu quiz'),
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
                    label: const Text('Lịch sử quiz'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: 8,
                children: ['Tất cả', 'Khó', 'Vừa', 'Dễ']
                    .map(
                      (filter) => ChoiceChip(
                        label: Text(filter),
                        selected: _difficultyFilter == filter,
                        onSelected: (_) =>
                            setState(() => _difficultyFilter = filter),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (cards.isEmpty)
                const EmptyView(
                  title: 'Chưa có thẻ ghi nhớ',
                  subtitle: 'Hãy tự tạo hoặc sinh thẻ ghi nhớ từ một ghi chú.',
                  icon: Icons.style_outlined,
                )
              else
                ...cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
      appBar: AppBar(title: const Text('Thẻ ghi nhớ')),
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
        label: const Text('Thêm thẻ'),
      ),
      body: _buildContent(context),
    );
  }
}
