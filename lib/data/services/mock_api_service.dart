import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/study_quote_model.dart';

class MockApiService {
  Future<StudyQuote> fetchDailyQuote() async {
    await Future.delayed(const Duration(milliseconds: 700));

    const quotes = [
      {'text': 'Small progress is still progress.', 'author': 'MemoQuest'},
      {'text': 'Consistency beats intensity.', 'author': 'Study Coach'},
      {'text': 'Review today so you remember tomorrow.', 'author': 'MemoQuest'},
    ];

    final quote = quotes[Random().nextInt(quotes.length)];
    final response = http.Response(jsonEncode(quote), 200);
    return StudyQuote.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> fetchSampleDecks() async {
    await Future.delayed(const Duration(milliseconds: 900));

    final response = http.Response(
      jsonEncode([
        {'title': 'Flutter Basics', 'cards': 8},
        {'title': 'Dart Async', 'cards': 6},
        {'title': 'SQLite Essentials', 'cards': 5},
      ]),
      200,
    );

    return (jsonDecode(response.body) as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
