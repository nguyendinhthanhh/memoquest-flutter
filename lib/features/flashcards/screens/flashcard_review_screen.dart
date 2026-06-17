import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../data/models/flashcard_model.dart';
import '../../home/providers/home_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/flip_card_view.dart';

class FlashcardReviewScreen extends StatefulWidget {
  const FlashcardReviewScreen({
    super.key,
    required this.arguments,
  });

  final Map<String, dynamic> arguments;

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen> {
  late final List<Flashcard> _cards;
  int _currentIndex = 0;
  bool _showBack = false;
  bool _finishing = false;
  bool _markingCard = false;

  @override
  void initState() {
    super.initState();
    _cards = List<Flashcard>.from(widget.arguments['cards'] as List<dynamic>);
  }

  void flipCard() {
    setState(() => _showBack = !_showBack);
  }

  Future<void> markCurrentCard(String difficulty) async {
    if (_markingCard || _finishing) {
      return;
    }

    setState(() => _markingCard = true);
    final card = _cards[_currentIndex];
    final provider = context.read<FlashcardProvider>();
    await provider.markDifficulty(card, difficulty);

    if (!mounted) {
      return;
    }

    setState(() => _markingCard = false);
    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
      return;
    }

    nextCard();
  }

  void nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showBack = false;
      });
    } else {
      finishReview();
    }
  }

  Future<void> finishReview() async {
    if (_finishing) {
      return;
    }
    setState(() => _finishing = true);

    final reviewedCards = _cards.length;
    final flashcardProvider = context.read<FlashcardProvider>();
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();

    await flashcardProvider.finishReviewSession(reviewedCards);
    if (flashcardProvider.errorMessage != null) {
      if (!mounted) {
        return;
      }
      setState(() => _finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flashcardProvider.errorMessage!)),
      );
      return;
    }

    await Future.wait([
      homeProvider.loadHomeData(),
      statsProvider.loadStats(),
    ]);

    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Complete'),
        content: Text(
          'You reviewed $reviewedCards flashcards and earned ${reviewedCards * 5} XP.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return const Scaffold(
        body: EmptyView(
          title: 'No Flashcards To Review',
          subtitle:
              'Create more flashcards and come back to start a review session.',
          icon: Icons.refresh_outlined,
        ),
      );
    }

    final currentCard = _cards[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arguments['title']?.toString() ?? 'Flashcard Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _cards.length,
            ),
            const SizedBox(height: 12),
            Text(
              '${_currentIndex + 1}/${_cards.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: FlipCardView(
                  frontText: currentCard.question,
                  backText: currentCard.answer,
                  showBack: _showBack,
                  onTap: flipCard,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Hard',
                    icon: Icons.sentiment_dissatisfied_outlined,
                    isLoading: _markingCard,
                    onPressed: () => markCurrentCard('Hard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Medium',
                    icon: Icons.sentiment_neutral_outlined,
                    isLoading: _markingCard,
                    onPressed: () => markCurrentCard('Medium'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Easy',
                    icon: Icons.sentiment_satisfied_alt_outlined,
                    isLoading: _markingCard,
                    onPressed: () => markCurrentCard('Easy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
