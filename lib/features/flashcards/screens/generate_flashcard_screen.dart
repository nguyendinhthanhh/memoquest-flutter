import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/flashcard_generator.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/models/note_model.dart';
import '../../home/providers/home_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/flashcard_provider.dart';

class GenerateFlashcardScreen extends StatefulWidget {
  const GenerateFlashcardScreen({
    super.key,
    required this.note,
  });

  final Map<String, dynamic> note;

  @override
  State<GenerateFlashcardScreen> createState() => _GenerateFlashcardScreenState();
}

class _GenerateFlashcardScreenState extends State<GenerateFlashcardScreen> {
  late final Note _note;
  List<Flashcard> _generatedCards = [];
  final List<TextEditingController> _questionControllers = [];
  final List<TextEditingController> _answerControllers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _note = Note.fromMap(widget.note);
  }

  @override
  void dispose() {
    for (final controller in _questionControllers) {
      controller.dispose();
    }
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _generateCards() {
    for (final controller in _questionControllers) {
      controller.dispose();
    }
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    _questionControllers.clear();
    _answerControllers.clear();

    final cards = generateFlashcardsFromNote(_note);
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This note is too short or does not contain enough content to generate flashcards.',
          ),
        ),
      );
      return;
    }

    _generatedCards = cards;
    for (final card in cards) {
      _questionControllers.add(TextEditingController(text: card.question));
      _answerControllers.add(TextEditingController(text: card.answer));
    }
    setState(() {});
  }

  Future<void> _saveCards() async {
    if (_generatedCards.isEmpty || _isSaving) {
      return;
    }
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final cards = List.generate(_generatedCards.length, (index) {
      return _generatedCards[index].copyWith(
        question: _questionControllers[index].text.trim(),
        answer: _answerControllers[index].text.trim(),
        createdAt: now,
        updatedAt: now,
      );
    }).where((card) => card.question.isNotEmpty && card.answer.isNotEmpty).toList();

    if (cards.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one valid flashcard is required to save.'),
        ),
      );
      return;
    }

    final flashcardProvider = context.read<FlashcardProvider>();
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();

    await flashcardProvider.addManyFlashcards(cards);
    if (flashcardProvider.errorMessage != null) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
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
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved ${cards.length} flashcards to SQLite.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Flashcards')),
      body: SafeArea(
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
                      _note.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_note.content),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Generate Flashcards',
              icon: Icons.auto_awesome_outlined,
              onPressed: _generateCards,
            ),
            const SizedBox(height: 16),
            if (_generatedCards.isEmpty)
              const EmptyView(
                title: 'No generated flashcards yet',
                subtitle: 'Tap the button above to generate flashcards from this note.',
                icon: Icons.auto_awesome_motion_outlined,
              )
            else
              ...List.generate(_generatedCards.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _questionControllers[index],
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Question',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _answerControllers[index],
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Answer',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            if (_generatedCards.isNotEmpty) ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'Save All',
                icon: Icons.save_outlined,
                isLoading: _isSaving,
                onPressed: _saveCards,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
