import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/flashcard_model.dart';
import '../../home/providers/home_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/answer_option_tile.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.arguments,
  });

  final Map<String, dynamic> arguments;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<Flashcard> _cards;

  @override
  void initState() {
    super.initState();
    _cards = List<Flashcard>.from(widget.arguments['cards'] as List<dynamic>);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(_cards);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Mode')),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, _) {
          if (quizProvider.isLoading) {
            return const LoadingView(message: 'Creating quiz questions...');
          }
          if (quizProvider.errorMessage != null &&
              quizProvider.questions.isEmpty) {
            return ErrorView(
              message: quizProvider.errorMessage!,
              onRetry: () => quizProvider.startQuiz(_cards),
            );
          }
          if (quizProvider.questions.isEmpty) {
            return const EmptyView(
              title: 'Unable to create a quiz',
              subtitle: 'Add more flashcards before starting the quiz.',
              icon: Icons.quiz_outlined,
            );
          }

          final question = quizProvider.questions[quizProvider.currentIndex];
          final isLast =
              quizProvider.currentIndex == quizProvider.questions.length - 1;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value:
                      (quizProvider.currentIndex + 1) /
                      quizProvider.questions.length,
                ),
                const SizedBox(height: 12),
                Text(
                  'Question ${quizProvider.currentIndex + 1}/${quizProvider.questions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      question.question,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      return AnswerOptionTile(
                        answer: option,
                        selectedAnswer: question.selectedAnswer,
                        onTap: () => quizProvider.submitAnswer(option),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        question.selectedAnswer == null ||
                            quizProvider.isSubmittingResult
                        ? null
                        : () async {
                            if (!isLast) {
                              quizProvider.nextQuestion();
                              return;
                            }
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final homeProvider = context.read<HomeProvider>();
                            final statsProvider = context.read<StatsProvider>();
                            try {
                              final result = await quizProvider.finishQuiz();
                              await Future.wait([
                                homeProvider.loadHomeData(),
                                statsProvider.loadStats(),
                              ]);
                              if (!mounted) {
                                return;
                              }
                              navigator.pushReplacementNamed(
                                RouteNames.quizResult,
                                arguments: {
                                  'result': result.toMap(),
                                  'cards': _cards,
                                },
                              );
                            } catch (_) {
                              if (!mounted) {
                                return;
                              }
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Unable to finish the quiz. Please try again.',
                                  ),
                                ),
                              );
                            }
                          },
                    icon: Icon(
                      isLast ? Icons.flag_outlined : Icons.arrow_forward,
                    ),
                    label: Text(
                      quizProvider.isSubmittingResult
                          ? 'Saving...'
                          : isLast
                          ? 'Finish'
                          : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
