import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

/// Shared page frame: soft gradient, safe areas, and a readable max width on
/// tablets.
class PageShell extends StatelessWidget {
  const PageShell({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showBack = true,
    this.maxWidth = 640,
    this.bottom,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showBack;
  final double maxWidth;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: title == null && actions == null && !showBack
          ? null
          : AppBar(title: title == null ? null : Text(title!), automaticallyImplyLeading: showBack, actions: actions),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.background),
        child: SafeArea(
          top: title == null && actions == null && !showBack,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: bottom),
                ),
              ),
            ),
      backgroundColor: AppColors.cream,
    );
  }
}
