import 'package:flutter/foundation.dart';

import '../../../core/utils/review_utils.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/repositories/flashcard_repository.dart';
import '../../../data/repositories/progress_repository.dart';

class FlashcardProvider extends ChangeNotifier {
  FlashcardProvider({
    required this.flashcardRepository,
    required this.progressRepository,
  });

  final FlashcardRepository flashcardRepository;
  final ProgressRepository progressRepository;

  List<Flashcard> flashcards = [];
  List<Flashcard> dueFlashcards = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadFlashcards() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      flashcards = await flashcardRepository.getAllFlashcards();
    } catch (_) {
      errorMessage = 'Unable to load flashcards.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDueFlashcards() async {
    try {
      dueFlashcards = await flashcardRepository.getDueFlashcards(DateTime.now());
      notifyListeners();
    } catch (_) {
      errorMessage = 'Unable to load cards due for review.';
      notifyListeners();
    }
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    try {
      await flashcardRepository.createFlashcard(flashcard);
      await loadFlashcards();
      await loadDueFlashcards();
    } catch (_) {
      errorMessage = 'Unable to create the flashcard.';
      notifyListeners();
    }
  }

  Future<void> addManyFlashcards(List<Flashcard> cards) async {
    try {
      for (final card in cards) {
        await flashcardRepository.createFlashcard(card);
      }
      await loadFlashcards();
      await loadDueFlashcards();
    } catch (_) {
      errorMessage = 'Unable to save the generated flashcards.';
      notifyListeners();
    }
  }

  Future<void> editFlashcard(Flashcard flashcard) async {
    try {
      await flashcardRepository.updateFlashcard(flashcard);
      await loadFlashcards();
      await loadDueFlashcards();
    } catch (_) {
      errorMessage = 'Unable to update the flashcard.';
      notifyListeners();
    }
  }

  Future<void> removeFlashcard(int id) async {
    try {
      await flashcardRepository.deleteFlashcard(id);
      await loadFlashcards();
      await loadDueFlashcards();
    } catch (_) {
      errorMessage = 'Unable to delete the flashcard.';
      notifyListeners();
    }
  }

  Future<void> markDifficulty(Flashcard card, String difficulty) async {
    try {
      final nextReviewDate = ReviewUtils.getNextReviewDate(difficulty);
      await flashcardRepository.updateDifficultyAndNextReview(
        card.id!,
        difficulty,
        nextReviewDate,
      );
      await loadFlashcards();
      await loadDueFlashcards();
    } catch (_) {
      errorMessage = 'Unable to update the flashcard review schedule.';
      notifyListeners();
    }
  }

  Future<List<Flashcard>> getFlashcardsByNoteId(int noteId) {
    return flashcardRepository.getFlashcardsByNoteId(noteId);
  }

  Future<void> finishReviewSession(int reviewedCards) async {
    errorMessage = null;
    try {
      await progressRepository.addXP(
        ReviewUtils.calculateReviewXp(reviewedCards),
      );
      await progressRepository.updateStudyStreak();
    } catch (_) {
      errorMessage = 'Unable to save review progress.';
      notifyListeners();
    }
  }
}
