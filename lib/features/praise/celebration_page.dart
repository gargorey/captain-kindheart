import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../widgets/captain_sami.dart';
import '../../widgets/confetti.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/speech_bubble.dart';
import '../../widgets/stop_button.dart';
import 'celebration_controller.dart';

class CelebrationPage extends GetView<CelebrationController> {
  const CelebrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) controller.stop();
      },
      child: Stack(
        children: [
          PageShell(
            title: TranslationsKeys.celebTitleFallback.tr,
            bottom: Row(
              children: [
                Expanded(
                  child: StopButton(
                    label: TranslationsKeys.btnStop.tr,
                    icon: Icons.volume_off_rounded,
                    onPressed: controller.stop,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('backHome'),
                    onPressed: () async {
                      await controller.stop();
                      Get.until((r) => r.settings.name == AppRoutes.home);
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: Text(TranslationsKeys.btnBackHome.tr),
                  ),
                ),
              ],
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                Text(
                  controller.cheer,
                  style: text.displaySmall?.copyWith(color: AppColors.coral),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Center(
                  child: CaptainSami(
                    size: 200,
                    mood: controller.isDance ? SamiMood.dancing : SamiMood.happy,
                    reduceMotion: controller.reduceMotion,
                  ),
                ),
                if (controller.isDance)
                  Text(TranslationsKeys.celebDance.tr, textAlign: TextAlign.center, style: text.titleMedium),
                const SizedBox(height: 12),
                SpeechBubble(text: controller.message),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.local_florist_rounded,
                  color: AppColors.greenDeep,
                  text: TranslationsKeys.celebStar.tr,
                ),
                Obx(
                  () => controller.newBadge.value
                      ? _InfoRow(
                          key: const Key('newBadge'),
                          icon: Icons.workspace_premium_rounded,
                          color: AppColors.yellow,
                          text: TranslationsKeys.celebBadgeNew.trParams({'badge': controller.badgeTitle}),
                        )
                      : const SizedBox.shrink(),
                ),
                if (controller.rewardLine != null)
                  _InfoRow(icon: controller.reward!.icon, color: AppColors.sky, text: controller.rewardLine!),
              ],
            ),
          ),
          Positioned.fill(child: ConfettiBurst(enabled: !controller.reduceMotion)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({super.key, required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(
      children: [
        Icon(icon, color: color == AppColors.yellow ? const Color(0xFFE0A800) : color, size: 30),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
      ],
    ),
  );
}
