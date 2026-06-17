import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/review_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/flashcard_model.dart';
import '../../home/providers/home_provider.dart';
import '../../notes/providers/note_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/flashcard_provider.dart';

class AddEditFlashcardScreen extends StatefulWidget {
  const AddEditFlashcardScreen({
    super.key,
    this.data,
  });

  final Map<String, dynamic>? data;

  @override
  State<AddEditFlashcardScreen> createState() => _AddEditFlashcardScreenState();
}

class _AddEditFlashcardScreenState extends State<AddEditFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  String _difficulty = 'Medium';
  int? _selectedNoteId;
  bool _isSaving = false;

  Flashcard? get _initialCard => widget.data?['flashcard'] == null
      ? null
      : Flashcard.fromMap(
          Map<String, dynamic>.from(widget.data!['flashcard'] as Map),
        );

  int? get _routeNoteId => widget.data?['noteId'] as int?;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: _initialCard?.question ?? '');
    _answerController = TextEditingController(text: _initialCard?.answer ?? '');
    _difficulty = _initialCard?.difficulty ?? 'Medium';
    _selectedNoteId = _initialCard?.noteId ?? _routeNoteId;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final card = Flashcard(
      id: _initialCard?.id,
      noteId: _selectedNoteId,
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      difficulty: _difficulty,
      nextReviewDate: ReviewUtils.getNextReviewDate(_difficulty),
      createdAt: _initialCard?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<FlashcardProvider>();
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();

    if (_initialCard == null) {
      await provider.addFlashcard(card);
    } else {
      await provider.editFlashcard(card);
    }

    if (provider.errorMessage != null) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _initialCard == null ? 'Create Flashcard' : 'Edit Flashcard',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _questionController,
                  label: 'Question',
                  validator: Validators.flashcardQuestion,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _answerController,
                  label: 'Answer',
                  validator: Validators.flashcardAnswer,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Consumer<NoteProvider>(
                  builder: (context, noteProvider, _) {
                    return Column(
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: _selectedNoteId,
                          validator: (value) =>
                              value == null ? 'Please choose a note' : null,
                          items: noteProvider.notes
                              .map(
                                (note) => DropdownMenuItem<int>(
                                  value: note.id,
                                  child: Text(note.title),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedNoteId = value);
                          },
                          decoration: InputDecoration(
                            labelText: 'Linked Note',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        if (noteProvider.notes.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Create a note first before adding a flashcard.',
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _difficulty,
                  validator: Validators.difficulty,
                  items: const ['Hard', 'Medium', 'Easy']
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _difficulty = value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Difficulty',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Save Flashcard',
                  icon: Icons.save_outlined,
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
