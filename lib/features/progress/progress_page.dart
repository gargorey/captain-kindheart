import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/section_card.dart';

/// Positive-only progress: a growing garden and collected badges.
/// No scores, no streaks to break, no record of difficult moments.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  static const _flowerColors = [AppColors.coral, AppColors.yellow, AppColors.lilac, AppColors.sky, AppColors.greenDeep];

  @override
  Widget build(BuildContext context) {
    final progress = Get.find<ProgressRepository>();
    final content = Get.find<ContentRepository>();
    final text = Theme.of(context).textTheme;
    return PageShell(
      title: TranslationsKeys.progressTitle.tr,
      child: Obx(() {
        final state = progress.progress.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text(TranslationsKeys.progressIntro.tr, style: text.bodyMedium),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE9F9E4), Color(0xFFFFF8EC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Text(
                    TranslationsKeys.progressFlowers.trParams({'count': '${state.flowers}'}),
                    key: const Key('flowerCount'),
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  if (state.flowers == 0)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Icon(Icons.grass_rounded, size: 56, color: AppColors.greenDeep),
                          Text(TranslationsKeys.progressEmpty.tr, textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (var i = 0; i < state.flowers.clamp(0, 60); i++)
                          Icon(Icons.local_florist_rounded, size: 34, color: _flowerColors[i % _flowerColors.length]),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: TranslationsKeys.progressBadges.tr,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final b in content.behaviors)
                      SizedBox(
                        width: 96,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: state.badges.contains(b.id) ? b.color : const Color(0xFFECEFF1),
                              child: Icon(
                                state.badges.contains(b.id) ? b.icon : Icons.lock_outline_rounded,
                                color: state.badges.contains(b.id) ? Colors.white : AppColors.inkSoft,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.badges.contains(b.id) ? b.badgeKey.tr : TranslationsKeys.progressLocked.tr,
                              textAlign: TextAlign.center,
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (state.moments.isNotEmpty)
              SectionCard(
                title: TranslationsKeys.progressMoments.tr,
                children: [
                  for (final m in state.moments.take(15))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(content.behavior(m.behaviorId).icon, color: AppColors.teal),
                      title: Text(content.behavior(m.behaviorId).titleKey.tr),
                      subtitle: Text(_date(m.at)),
                      trailing: m.rewardId == null
                          ? null
                          : Icon(content.reward(m.rewardId)?.icon, color: AppColors.coral),
                    ),
                ],
              ),
          ],
        );
      }),
    );
  }

  static String _date(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}
