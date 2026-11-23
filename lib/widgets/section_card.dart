import 'package:flutter/material.dart';

/// White rounded container for grouped settings and info.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.children, this.title});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8, bottom: 8),
              child: Text(title!, style: Theme.of(context).textTheme.titleMedium),
            ),
          // Material (not a decorated box) so ListTile ink splashes stay visible.
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ),
        ],
      ),
    );
  }
}
