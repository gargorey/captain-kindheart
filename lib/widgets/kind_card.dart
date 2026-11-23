import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

/// Large rounded, tappable card used on the home screen and pickers.
class KindCard extends StatelessWidget {
  const KindCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.selected = false,
    this.trailing,
    this.large = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool selected;
  final Widget? trailing;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(large ? 20 : 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: selected ? AppColors.teal : color.withValues(alpha: 0.35),
                width: selected ? 3 : 2,
              ),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(
              children: [
                Container(
                  width: large ? 72 : 54,
                  height: large ? 72 : 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(icon, color: Colors.white, size: large ? 40 : 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: large ? text.titleLarge : text.titleMedium),
                      if (subtitle != null) Text(subtitle!, style: text.bodySmall),
                    ],
                  ),
                ),
                ?trailing,
                if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.teal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
