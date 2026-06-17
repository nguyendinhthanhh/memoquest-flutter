import 'package:flutter/foundation.dart';

import '../../../data/models/user_progress_model.dart';
import '../../../data/repositories/stats_repository.dart';

class StatsProvider extends ChangeNotifier {
  StatsProvider(this._statsRepository);

  final StatsRepository _statsRepository;

  bool isLoading = false;
  String? errorMessage;
  int totalNotes = 0;
  int totalFlashcards = 0;
  int dueToday = 0;
  int totalQuizzes = 0;
  double averageAccuracy = 0;
  UserProgress? progress;
  Map<String, int> notesBySubject = {};
  Map<String, int> cardsByDifficulty = {};

  Future<void> loadStats() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      totalNotes = await _statsRepository.getTotalNotes();
      totalFlashcards = await _statsRepository.getTotalFlashcards();
      dueToday = await _statsRepository.getDueTodayCount();
      totalQuizzes = await _statsRepository.getTotalQuizCount();
      averageAccuracy = await _statsRepository.getAverageAccuracy();
      progress = await _statsRepository.getUserProgress();
      notesBySubject = await _statsRepository.getNotesBySubject();
      cardsByDifficulty = await _statsRepository.getFlashcardsByDifficulty();
    } catch (_) {
      errorMessage = 'Unable to load statistics.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
