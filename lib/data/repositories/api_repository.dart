import '../models/study_quote_model.dart';
import '../services/mock_api_service.dart';

class ApiRepository {
  ApiRepository(this._mockApiService);

  final MockApiService _mockApiService;

  Future<StudyQuote> fetchDailyQuote() => _mockApiService.fetchDailyQuote();

  Future<List<Map<String, dynamic>>> fetchSampleDecks() =>
      _mockApiService.fetchSampleDecks();
}
