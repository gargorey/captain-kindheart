import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/repositories/settings_repository.dart';
import '../../widgets/captain_sami.dart';
import '../../widgets/kind_card.dart';
import '../../widgets/page_shell.dart';
import '../parent_gate/parent_gate.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openSettings() async {
    if (await showParentGate()) Get.toNamed(AppRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final settings = Get.find<SettingsRepository>();
    return PageShell(
      showBack: false,
      child: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth > 560;
          final cards = [
            KindCard(
              key: const Key('homeReminder'),
              large: true,
              title: TranslationsKeys.homeReminderTitle.tr,
              subtitle: TranslationsKeys.homeReminderDesc.tr,
              icon: Icons.emoji_nature_rounded,
              color: AppColors.sky,
              onTap: () => Get.toNamed(AppRoutes.situations),
            ),
            KindCard(
              key: const Key('homeCall'),
              large: true,
              title: TranslationsKeys.homeCallTitle.tr,
              subtitle: TranslationsKeys.homeCallDesc.tr,
              icon: Icons.forum_rounded,
              color: AppColors.teal,
              onTap: () => Get.toNamed(AppRoutes.callSetup),
            ),
            KindCard(
              key: const Key('homePraise'),
              large: true,
              title: TranslationsKeys.homePraiseTitle.tr,
              subtitle: TranslationsKeys.homePraiseDesc.tr,
              icon: Icons.celebration_rounded,
              color: AppColors.coral,
              onTap: () => Get.toNamed(AppRoutes.praise),
            ),
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    key: const Key('homeProgress'),
                    tooltip: TranslationsKeys.homeProgress.tr,
                    onPressed: () => Get.toNamed(AppRoutes.progress),
                    icon: const Icon(Icons.local_florist_rounded),
                  ),
                  const Spacer(),
                  Obx(
                    () => settings.settings.value.quietMode
                        ? Chip(
                            avatar: const Icon(Icons.volume_off_rounded, size: 18),
                            label: Text(TranslationsKeys.quietModeOn.tr),
                            backgroundColor: AppColors.yellow.withValues(alpha: 0.4),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    key: const Key('homeSettings'),
                    tooltip: TranslationsKeys.homeSettings.tr,
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Obx(
                    () => CaptainSami(size: 120, mood: SamiMood.happy, reduceMotion: settings.settings.value.quietMode),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(TranslationsKeys.homeGreeting.tr, style: text.headlineSmall),
                        Text(TranslationsKeys.homeSubtitle.tr, style: text.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (wide)
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [for (final c in cards) SizedBox(width: (box.maxWidth - 56) / 2, child: c)],
                )
              else
                ...cards.expand((c) => [c, const SizedBox(height: 16)]),
            ],
          );
        },
      ),
    );
  }
}
