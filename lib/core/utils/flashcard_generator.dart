import '../../data/models/flashcard_model.dart';
import '../../data/models/note_model.dart';
import 'review_utils.dart';

List<Flashcard> generateFlashcardsFromNote(Note note) {
  final sentences = splitIntoSentences(note.content);
  return sentences
      .map((sentence) => generateCardFromSentence(sentence, note.id))
      .where((card) => card.question.trim().isNotEmpty)
      .toList();
}

List<String> splitIntoSentences(String content) {
  return content
      .split(RegExp(r'[.!?\n]+'))
      .map(cleanSentence)
      .where((sentence) => sentence.isNotEmpty)
      .toList();
}

Flashcard generateCardFromSentence(String sentence, int? noteId) {
  final now = DateTime.now();
  final lowerSentence = sentence.toLowerCase();
  late final String question;
  late final String answer;

  if (lowerSentence.contains(' là ')) {
    final parts = sentence.split(RegExp(r'\slà\s', caseSensitive: false));
    question = '${parts.first.trim()} là gì?';
    answer = parts.skip(1).join(' là ').trim();
  } else if (lowerSentence.contains(' dùng để ')) {
    final parts =
        sentence.split(RegExp(r'\sdùng để\s', caseSensitive: false));
    question = '${parts.first.trim()} dùng để làm gì?';
    answer = parts.skip(1).join(' dùng để ').trim();
  } else if (lowerSentence.contains(' gồm ')) {
    final parts = sentence.split(RegExp(r'\sgồm\s', caseSensitive: false));
    question = '${parts.first.trim()} gồm những gì?';
    answer = parts.skip(1).join(' gồm ').trim();
  } else {
    final words = sentence.split(RegExp(r'\s+'));
    final preview = words.take(words.length > 8 ? 8 : words.length).join(' ');
    question = 'Giải thích: $preview?';
    answer = sentence;
  }

  return Flashcard(
    noteId: noteId,
    question: question,
    answer: answer,
    difficulty: 'Medium',
    nextReviewDate: ReviewUtils.getNextReviewDate('Medium'),
    createdAt: now,
    updatedAt: now,
  );
}

String cleanSentence(String sentence) {
  return sentence.replaceAll(RegExp(r'\s+'), ' ').trim();
}
