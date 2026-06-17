import 'package:flutter/foundation.dart';

import '../../../data/models/study_quote_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../data/repositories/stats_repository.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    required this.statsRepository,
    required this.apiRepository,
  });

  final StatsRepository statsRepository;
  final ApiRepository apiRepository;

  bool isLoading = false;
  String? errorMessage;
  StudyQuote? dailyQuote;
  UserProgress? progress;
  int notesCount = 0;
  int flashcardsCount = 0;
  int dueTodayCount = 0;
  double averageAccuracy = 0;
  List<Map<String, dynamic>> sampleDecks = [];

  Future<void> loadHomeData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      notesCount = await statsRepository.getTotalNotes();
      flashcardsCount = await statsRepository.getTotalFlashcards();
      dueTodayCount = await statsRepository.getDueTodayCount();
      averageAccuracy = await statsRepository.getAverageAccuracy();
      progress = await statsRepository.getUserProgress();
      sampleDecks = await apiRepository.fetchSampleDecks();
      dailyQuote = await apiRepository.fetchDailyQuote();
    } catch (_) {
      dailyQuote = const StudyQuote(
        text: 'Small progress is still progress.',
        author: 'MemoQuest',
      );
      errorMessage = 'Using fallback quote data.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
