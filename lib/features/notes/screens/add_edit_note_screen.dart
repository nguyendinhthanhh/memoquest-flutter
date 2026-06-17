import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/note_model.dart';
import '../../home/providers/home_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/note_provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  const AddEditNoteScreen({
    super.key,
    this.note,
  });

  final Map<String, dynamic>? note;

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _tagsController;
  late final TextEditingController _contentController;
  bool _isSaving = false;

  Note? get _initialNote =>
      widget.note == null ? null : Note.fromMap(widget.note!);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _initialNote?.title ?? '');
    _subjectController =
        TextEditingController(text: _initialNote?.subject ?? '');
    _tagsController = TextEditingController(text: _initialNote?.tags ?? '');
    _contentController =
        TextEditingController(text: _initialNote?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _tagsController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final note = Note(
      id: _initialNote?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      subject: _subjectController.text.trim(),
      tags: _tagsController.text.trim().isEmpty ? null : _tagsController.text.trim(),
      isPinned: _initialNote?.isPinned ?? false,
      createdAt: _initialNote?.createdAt ?? now,
      updatedAt: now,
    );

    final noteProvider = context.read<NoteProvider>();
    final homeProvider = context.read<HomeProvider>();
    final statsProvider = context.read<StatsProvider>();

    if (_initialNote == null) {
      await noteProvider.addNote(note);
    } else {
      await noteProvider.editNote(note);
    }

    if (noteProvider.errorMessage != null) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(noteProvider.errorMessage!)),
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
        title: Text(_initialNote == null ? 'Create Note' : 'Edit Note'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _titleController,
                  label: 'Title',
                  validator: Validators.noteTitle,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _subjectController,
                  label: 'Subject',
                  validator: Validators.subject,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _tagsController,
                  label: 'Tags',
                  hintText: 'Example: flutter, async',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _contentController,
                  label: 'Content',
                  maxLines: 8,
                  validator: Validators.noteContent,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Save Note',
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
