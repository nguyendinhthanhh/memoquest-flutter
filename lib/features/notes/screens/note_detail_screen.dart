import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/models/note_model.dart';
import '../../flashcards/providers/flashcard_provider.dart';
import '../../flashcards/screens/deck_screen.dart';
import '../../home/providers/home_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/note_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  final Map<String, dynamic> note;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note _note;

  @override
  void initState() {
    super.initState();
    _note = Note.fromMap(widget.note);
  }

  Future<void> _refresh() async {
    final updated = await context.read<NoteProvider>().getNoteById(_note.id!);
    if (!mounted) {
      return;
    }
    if (updated != null) {
      setState(() => _note = updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This note no longer exists.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Note',
      content: 'Deleting this note will also delete related flashcards.',
    );
    if (!confirmed || !mounted) {
      return;
    }

    final noteProvider = context.read<NoteProvider>();
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();

    await noteProvider.removeNote(_note.id!);
    if (noteProvider.errorMessage != null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(noteProvider.errorMessage!)),
      );
      return;
    }

    await Future.wait([
      homeProvider.loadHomeData(),
      statsProvider.loadStats(),
    ]);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _openEdit() async {
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();
    await Navigator.pushNamed(
      context,
      RouteNames.addEditNote,
      arguments: _note.toMap(),
    );
    await _refresh();
    if (!mounted) {
      return;
    }
    await Future.wait([
      homeProvider.loadHomeData(),
      statsProvider.loadStats(),
    ]);
  }

  Future<void> _togglePin() async {
    final noteProvider = context.read<NoteProvider>();
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();
    await noteProvider.togglePin(_note);
    await _refresh();
    if (!mounted) {
      return;
    }
    await Future.wait([
      homeProvider.loadHomeData(),
      statsProvider.loadStats(),
    ]);
  }

  Future<void> _openGenerate() async {
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();
    await Navigator.pushNamed(
      context,
      RouteNames.generateFlashcard,
      arguments: _note.toMap(),
    );
    if (!mounted) {
      return;
    }
    await Future.wait([
      homeProvider.loadHomeData(),
      statsProvider.loadStats(),
    ]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Detail'),
        actions: [
          IconButton(
            onPressed: _togglePin,
            icon: Icon(
              _note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
          ),
          IconButton(
            onPressed: _openEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _note.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(_note.subject)),
                        if ((_note.tags ?? '').trim().isNotEmpty)
                          Chip(label: Text(_note.tags!)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_note.content),
                    const SizedBox(height: 16),
                    Text('Created: ${AppDateUtils.formatDateTime(_note.createdAt)}'),
                    const SizedBox(height: 4),
                    Text('Updated: ${AppDateUtils.formatDateTime(_note.updatedAt)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _openGenerate,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Generate Flashcards'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeckScreen(
                          standalone: true,
                          noteIdFilter: _note.id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.layers_outlined),
                  label: const Text('View Flashcards'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Related Flashcards',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Flashcard>>(
              future: context
                  .read<FlashcardProvider>()
                  .getFlashcardsByNoteId(_note.id ?? 0),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final cards = snapshot.data ?? [];
                if (cards.isEmpty) {
                  return const EmptyView(
                    title: 'No flashcards yet',
                    subtitle: 'Generate or create flashcards from the deck screen.',
                    icon: Icons.style_outlined,
                  );
                }
                return Column(
                  children: cards
                      .take(3)
                      .map(
                        (card) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(card.question),
                            subtitle: Text(
                              card.answer,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
