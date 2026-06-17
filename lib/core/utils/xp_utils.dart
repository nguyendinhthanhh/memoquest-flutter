class XpUtils {
  static int calculateLevel(int xp) => xp ~/ 100 + 1;

  static double calculateLevelProgress(int xp) => (xp % 100) / 100;

  static String getLevelTitle(int level) {
    if (level <= 2) {
      return 'New Learner';
    }
    if (level <= 5) {
      return 'Note Explorer';
    }
    if (level <= 10) {
      return 'Flashcard Adventurer';
    }
    if (level <= 20) {
      return 'Quiz Warrior';
    }
    return 'MemoQuest Master';
  }
}
