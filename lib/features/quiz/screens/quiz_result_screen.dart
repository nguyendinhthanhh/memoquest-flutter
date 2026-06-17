import 'package:flutter/material.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../data/models/flashcard_model.dart';
import '../../../data/models/quiz_result_model.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.arguments,
  });

  final Map<String, dynamic> arguments;

  @override
  Widget build(BuildContext context) {
    final result = QuizResult.fromMap(arguments['result'] as Map<String, dynamic>);
    final cards = List<Flashcard>.from(arguments['cards'] as List<dynamic>);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              StatCard(
                title: 'Correct',
                value: '${result.correctAnswers}/${result.totalQuestions}',
                icon: Icons.check_circle_outline,
              ),
              StatCard(
                title: 'Accuracy',
                value: '${result.accuracy.toStringAsFixed(1)}%',
                icon: Icons.track_changes_outlined,
              ),
              StatCard(
                title: 'XP Earned',
                value: '${result.xpEarned}',
                icon: Icons.bolt_outlined,
              ),
              StatCard(
                title: 'Status',
                value: result.accuracy >= 70 ? 'Great job!' : 'Keep practicing',
                icon: Icons.emoji_events_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The result has been saved to SQLite and the earned XP has been added to your progress.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          RouteNames.quiz,
                          arguments: {'cards': cards},
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Quiz'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteNames.main,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Back Home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
