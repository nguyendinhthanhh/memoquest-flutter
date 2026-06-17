import 'package:flutter/foundation.dart';

import '../../../data/models/note_model.dart';
import '../../../data/repositories/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  NoteProvider(this._noteRepository);

  final NoteRepository _noteRepository;

  List<Note> notes = [];
  List<Note> filteredNotes = [];
  List<String> subjects = [];
  bool isLoading = false;
  String? errorMessage;
  String searchKeyword = '';
  String selectedSubject = 'All';

  Future<void> loadNotes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      notes = await _noteRepository.getAllNotes();
      subjects = ['All', ...await _noteRepository.getAllSubjects()];
      if (!subjects.contains(selectedSubject)) {
        selectedSubject = 'All';
      }
      _applyFilters();
    } catch (_) {
      errorMessage = 'Unable to load notes.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _noteRepository.createNote(note);
      await loadNotes();
    } catch (_) {
      errorMessage = 'Unable to create the note.';
      notifyListeners();
    }
  }

  Future<void> editNote(Note note) async {
    try {
      await _noteRepository.updateNote(note);
      await loadNotes();
    } catch (_) {
      errorMessage = 'Unable to update the note.';
      notifyListeners();
    }
  }

  Future<void> removeNote(int id) async {
    try {
      await _noteRepository.deleteNote(id);
      await loadNotes();
    } catch (_) {
      errorMessage = 'Unable to delete the note.';
      notifyListeners();
    }
  }

  Future<void> searchNotes(String keyword) async {
    searchKeyword = keyword.trim();
    _applyFilters();
    notifyListeners();
  }

  Future<void> filterBySubject(String subject) async {
    selectedSubject = subject;
    _applyFilters();
    notifyListeners();
  }

  Future<void> togglePin(Note note) async {
    try {
      await _noteRepository.togglePinNote(note.id!, !note.isPinned);
      await loadNotes();
    } catch (_) {
      errorMessage = 'Unable to update the pin status.';
      notifyListeners();
    }
  }

  Future<Note?> getNoteById(int id) => _noteRepository.getNoteById(id);

  void _applyFilters() {
    Iterable<Note> working = notes;

    if (selectedSubject != 'All') {
      working = working.where((note) => note.subject == selectedSubject);
    }

    if (searchKeyword.isNotEmpty) {
      final lower = searchKeyword.toLowerCase();
      working = working.where(
        (note) =>
            note.title.toLowerCase().contains(lower) ||
            note.content.toLowerCase().contains(lower) ||
            note.subject.toLowerCase().contains(lower) ||
            (note.tags?.toLowerCase().contains(lower) ?? false),
      );
    }

    filteredNotes = working.toList()
      ..sort((a, b) {
        if (a.isPinned == b.isPinned) {
          return b.updatedAt.compareTo(a.updatedAt);
        }
        return a.isPinned ? -1 : 1;
      });
  }
}
