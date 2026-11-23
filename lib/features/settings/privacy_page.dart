import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../widgets/page_shell.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const points = [
      (Icons.phone_android_rounded, TranslationsKeys.privacy1),
      (Icons.cloud_off_rounded, TranslationsKeys.privacy2),
      (Icons.block_rounded, TranslationsKeys.privacy3),
      (Icons.record_voice_over_rounded, TranslationsKeys.privacy4),
      (Icons.edit_rounded, TranslationsKeys.privacy5),
    ];
    return PageShell(
      title: TranslationsKeys.privacyTitle.tr,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final (icon, key) in points)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.teal),
                  const SizedBox(width: 12),
                  Expanded(child: Text(key.tr, style: Theme.of(context).textTheme.bodyLarge)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
