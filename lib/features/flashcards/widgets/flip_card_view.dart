import 'package:flutter/material.dart';

class FlipCardView extends StatelessWidget {
  const FlipCardView({
    super.key,
    required this.frontText,
    required this.backText,
    required this.showBack,
    required this.onTap,
  });

  final String frontText;
  final String backText;
  final bool showBack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Container(
          key: ValueKey(showBack),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                showBack ? 'Answer' : 'Question',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Text(
                showBack ? backText : frontText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to flip the card',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
