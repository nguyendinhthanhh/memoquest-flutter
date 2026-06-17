import '../constants/app_constants.dart';

class ReviewUtils {
  static DateTime getNextReviewDate(String difficulty) {
    final now = DateTime.now();
    switch (difficulty.toLowerCase()) {
      case 'hard':
        return now.add(const Duration(days: 1));
      case 'easy':
        return now.add(const Duration(days: 7));
      case 'medium':
      default:
        return now.add(const Duration(days: 3));
    }
  }

  static int calculateReviewXp(int reviewedCards) =>
      reviewedCards * AppConstants.reviewXpPerCard;

  static int calculateQuizXp(int correctAnswers) =>
      correctAnswers * AppConstants.quizXpPerCorrectAnswer;
}
