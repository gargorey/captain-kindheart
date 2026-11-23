import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

/// Large, always-visible control that ends the current interaction.
class StopButton extends StatelessWidget {
  const StopButton({super.key, required this.label, required this.onPressed, this.icon = Icons.stop_rounded});

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: FilledButton.icon(
        key: const Key('stopButton'),
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          minimumSize: const Size(140, 60),
        ),
        icon: Icon(icon, size: 28),
        label: Text(label),
      ),
    );
  }
}
