import 'package:flutter/material.dart';

class SubjectFilterBar extends StatelessWidget {
  const SubjectFilterBar({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSelected,
  });

  final List<String> subjects;
  final String selectedSubject;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: subjects
            .map(
              (subject) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(subject),
                  selected: selectedSubject == subject,
                  onSelected: (_) => onSelected(subject),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
