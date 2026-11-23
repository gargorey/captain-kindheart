import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

/// Short line of dialogue. Text is announced to screen readers as a live region.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text, this.color = Colors.white});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(a), child: child),
      ),
      child: Container(
        key: ValueKey(text),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: AppColors.ink.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Semantics(
          liveRegion: true,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.7),
          ),
        ),
      ),
    );
  }
}
