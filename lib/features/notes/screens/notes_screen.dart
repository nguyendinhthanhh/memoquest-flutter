import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/note_model.dart';
import '../../home/providers/home_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/subject_filter_bar.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteNote(BuildContext context, Note note) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Note',
      content: 'Are you sure you want to delete "${note.title}"?',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final noteProvider = context.read<NoteProvider>();
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();

    await noteProvider.removeNote(note.id!);
    if (noteProvider.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(noteProvider.errorMessage!)),
      );
      return;
    }

    await Future.wait([
      homeProvider.loadHomeData(),
      statsProvider.loadStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, _) {
        if (noteProvider.isLoading && noteProvider.notes.isEmpty) {
          return const LoadingView();
        }
        if (noteProvider.errorMessage != null && noteProvider.notes.isEmpty) {
          return ErrorView(
            message: noteProvider.errorMessage!,
            onRetry: noteProvider.loadNotes,
          );
        }

        return RefreshIndicator(
          onRefresh: noteProvider.loadNotes,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  noteProvider.searchNotes(value);
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search title, content, subject, or tags',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            noteProvider.searchNotes('');
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SubjectFilterBar(
                subjects: noteProvider.subjects,
                selectedSubject: noteProvider.selectedSubject,
                onSelected: (subject) => noteProvider.filterBySubject(subject),
              ),
              const SizedBox(height: 16),
              if (noteProvider.filteredNotes.isEmpty)
                const EmptyView(
                  title: 'No Notes Yet',
                  subtitle:
                      'Create your first note to start learning with MemoQuest.',
                  icon: Icons.note_add_outlined,
                )
              else
                ...noteProvider.filteredNotes.map(
                  (note) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NoteCard(
                      note: note,
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          RouteNames.noteDetail,
                          arguments: note.toMap(),
                        );
                        if (context.mounted) {
                          await noteProvider.loadNotes();
                        }
                      },
                      onDelete: () => _deleteNote(context, note),
                      onTogglePin: () async {
                        await noteProvider.togglePin(note);
                        if (noteProvider.errorMessage != null &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(noteProvider.errorMessage!)),
                          );
                          return;
                        }
                        if (context.mounted) {
                          await Future.wait([
                            context.read<HomeProvider>().loadHomeData(),
                            context.read<StatsProvider>().loadStats(),
                          ]);
                        }
                      },
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
}
