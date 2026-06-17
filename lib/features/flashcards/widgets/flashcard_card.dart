import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/flashcard_model.dart';

class FlashcardCard extends StatelessWidget {
  const FlashcardCard({
    super.key,
    required this.flashcard,
    required this.onEdit,
    required this.onDelete,
  });

  final Flashcard flashcard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    flashcard.question,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(flashcard.answer),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(flashcard.difficulty)),
                Chip(
                  label: Text(
                    'Review on: ${AppDateUtils.formatDate(flashcard.nextReviewDate)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
