import 'package:flutter/material.dart';

class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.answer,
    required this.selectedAnswer,
    required this.onTap,
  });

  final String answer;
  final String? selectedAnswer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedAnswer == answer;
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          leading: Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_off_outlined,
          ),
          title: Text(answer),
        ),
      ),
    );
  }
}
