import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/utils/review_utils.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../../data/models/quiz_result_model.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/repositories/quiz_repository.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider({
    required this.quizRepository,
    required this.progressRepository,
  });

  final QuizRepository quizRepository;
  final ProgressRepository progressRepository;

  List<QuizQuestion> questions = [];
  List<QuizResult> history = [];
  int currentIndex = 0;
  int correctAnswers = 0;
  bool isLoading = false;
  bool isFinished = false;
  bool isSubmittingResult = false;
  String? errorMessage;
  QuizResult? latestResult;
  List<Flashcard> _sourceCards = [];

  Future<void> startQuiz(List<Flashcard> sourceCards) async {
    isLoading = true;
    errorMessage = null;
    isFinished = false;
    isSubmittingResult = false;
    currentIndex = 0;
    correctAnswers = 0;
    questions = [];
    latestResult = null;
    _sourceCards = List.of(sourceCards);
    notifyListeners();

    try {
      if (sourceCards.isEmpty) {
        errorMessage = 'There are no flashcards available to build a quiz.';
        return;
      }

      final random = Random();
      final shuffledCards = List<Flashcard>.from(sourceCards)..shuffle(random);
      final selectedCards = shuffledCards.take(10).toList();

      questions = selectedCards.map((card) {
        final incorrectAnswers = sourceCards
            .where((item) => item.id != card.id && item.answer != card.answer)
            .map((item) => item.answer)
            .toSet()
            .toList()
          ..shuffle(random);

        final options = <String>[card.answer];
        options.addAll(incorrectAnswers.take(3));
        const fallbacks = [
          'None of the above',
          'Not sure about this answer',
          'No suitable answer',
        ];

        for (final fallback in fallbacks) {
          if (options.length >= 4) {
            break;
          }
          if (!options.contains(fallback)) {
            options.add(fallback);
          }
        }

        options.shuffle(random);
        return QuizQuestion(
          question: card.question,
          options: options,
          correctAnswer: card.answer,
        );
      }).toList();
    } catch (_) {
      errorMessage = 'Unable to create the quiz.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void submitAnswer(String answer) {
    final currentQuestion = questions[currentIndex];
    if (currentQuestion.selectedAnswer != null) {
      return;
    }

    final isCorrect = answer == currentQuestion.correctAnswer;
    if (isCorrect) {
      correctAnswers++;
    }

    questions[currentIndex] = currentQuestion.copyWith(
      selectedAnswer: answer,
      isCorrect: isCorrect,
    );
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      notifyListeners();
    }
  }

  Future<QuizResult> finishQuiz() async {
    if (isSubmittingResult && latestResult != null) {
      return latestResult!;
    }

    isSubmittingResult = true;
    isFinished = true;
    errorMessage = null;

    final totalQuestions = questions.length;
    final accuracy =
        totalQuestions == 0 ? 0.0 : (correctAnswers / totalQuestions) * 100;
    final xpEarned = ReviewUtils.calculateQuizXp(correctAnswers);

    latestResult = QuizResult(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      xpEarned: xpEarned,
      accuracy: accuracy,
      createdAt: DateTime.now(),
    );

    notifyListeners();

    try {
      await quizRepository.saveQuizResult(latestResult!);
      await progressRepository.addXP(xpEarned);
      await progressRepository.updateStudyStreak();
      await loadQuizHistory();
      return latestResult!;
    } catch (_) {
      errorMessage = 'Unable to save the quiz result.';
      rethrow;
    } finally {
      isSubmittingResult = false;
      notifyListeners();
    }
  }

  Future<void> loadQuizHistory() async {
    try {
      history = await quizRepository.getQuizHistory();
      notifyListeners();
    } catch (_) {
      errorMessage = 'Unable to load quiz history.';
      notifyListeners();
    }
  }

  List<Flashcard> get sourceCards => _sourceCards;
}
