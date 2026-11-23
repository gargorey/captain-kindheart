import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/repositories/content_repository.dart';
import '../../widgets/page_shell.dart';
import 'praise_setup_controller.dart';

class PraiseSetupPage extends GetView<PraiseSetupController> {
  const PraiseSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Get.find<ContentRepository>();
    final text = Theme.of(context).textTheme;
    return PageShell(
      title: TranslationsKeys.praiseSetupTitle.tr,
      bottom: Obx(
        () => FilledButton.icon(
          key: const Key('celebrateNow'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
          onPressed: controller.canCelebrate ? controller.celebrate : null,
          icon: const Icon(Icons.celebration_rounded),
          label: Text(
            controller.canCelebrate ? TranslationsKeys.praiseCelebrate.tr : TranslationsKeys.praisePickFirst.tr,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final columns = box.maxWidth > 520 ? 3 : 2;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            children: [
              Text(TranslationsKeys.praiseWhat.tr, style: text.titleMedium),
              const SizedBox(height: 10),
              Obx(
                () => GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    for (final b in content.behaviors)
                      _Tile(
                        key: Key('behavior_${b.id}'),
                        label: b.titleKey.tr,
                        icon: b.icon,
                        color: b.color,
                        selected: controller.behaviorId.value == b.id,
                        onTap: () => controller.selectBehavior(b.id),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(TranslationsKeys.praiseReward.tr, style: text.titleMedium),
              const SizedBox(height: 10),
              Obx(
                () => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final r in content.rewards)
                      ChoiceChip(
                        key: Key('reward_${r.id}'),
                        avatar: Icon(r.icon, color: AppColors.tealDeep),
                        label: Text(r.titleKey.tr),
                        selected: controller.rewardId.value == r.id,
                        selectedColor: AppColors.yellow.withValues(alpha: 0.6),
                        backgroundColor: Colors.white,
                        onSelected: (_) => controller.toggleReward(r.id),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? color.withValues(alpha: 0.35) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: selected ? AppColors.teal : Colors.transparent, width: 3),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color == AppColors.yellow ? AppColors.tealDeep : color, size: 30),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
