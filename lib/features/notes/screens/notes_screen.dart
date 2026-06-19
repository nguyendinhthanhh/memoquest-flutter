import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/app_section_header.dart';
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
      title: 'Xóa ghi chú',
      content: 'Bạn có chắc muốn xóa "${note.title}" không?',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    final noteProvider = context.read<NoteProvider>();
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();

    await noteProvider.removeNote(note.id!);
    if (noteProvider.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(noteProvider.errorMessage!)));
      return;
    }

    await Future.wait([homeProvider.loadHomeData(), statsProvider.loadStats()]);
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontalCompact,
              AppSpacing.lg,
              AppSpacing.screenHorizontalCompact,
              144,
            ),
            children: [
              const AppSectionHeader(
                title: 'Ghi chú',
                subtitle: 'Lưu ý chính, chủ đề học và nội dung cần xem lại.',
                isPageHeader: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSearchField(
                controller: _searchController,
                hintText: 'Tiêu đề, nội dung, môn học hoặc thẻ',
                onChanged: (value) {
                  noteProvider.searchNotes(value);
                  setState(() {});
                },
                onClear: () {
                  _searchController.clear();
                  noteProvider.searchNotes('');
                  setState(() {});
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SubjectFilterBar(
                subjects: noteProvider.subjects,
                selectedSubject: noteProvider.selectedSubject,
                onSelected: (subject) => noteProvider.filterBySubject(subject),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (noteProvider.filteredNotes.isEmpty)
                const EmptyView(
                  title: 'Chưa có ghi chú nào',
                  subtitle:
                      'Tạo ghi chú đầu tiên để bắt đầu học cùng MemoQuest.',
                  icon: Icons.note_add_outlined,
                )
              else
                ...noteProvider.filteredNotes.map(
                  (note) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
            ],
          ),
        );
      },
    );
  }
}
