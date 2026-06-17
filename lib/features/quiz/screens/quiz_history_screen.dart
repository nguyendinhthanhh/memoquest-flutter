import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_view.dart';
import '../providers/quiz_provider.dart';

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz History')),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, _) {
          if (quizProvider.history.isEmpty) {
            return const EmptyView(
              title: 'No Quiz History Yet',
              subtitle: 'Finish at least one quiz to see your results here.',
              icon: Icons.history,
            );
          }
          return RefreshIndicator(
            onRefresh: quizProvider.loadQuizHistory,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: quizProvider.history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = quizProvider.history[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.quiz_outlined),
                    title: Text(
                      '${item.correctAnswers}/${item.totalQuestions} correct answers',
                    ),
                    subtitle: Text(
                      'Accuracy: ${item.accuracy.toStringAsFixed(1)}% | XP: ${item.xpEarned}\n${AppDateUtils.formatDateTime(item.createdAt)}',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
