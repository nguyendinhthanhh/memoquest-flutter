import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/note_model.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: onTogglePin,
                    icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(note.subject)),
                  if ((note.tags ?? '').trim().isNotEmpty)
                    Chip(label: Text(note.tags!)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                'Updated: ${AppDateUtils.formatDateTime(note.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
