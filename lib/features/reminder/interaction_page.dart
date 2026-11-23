import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/models/situation.dart';
import '../../widgets/captain_sami.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/speech_bubble.dart';
import '../../widgets/stop_button.dart';
import 'interaction_controller.dart';

class InteractionPage extends GetView<InteractionController> {
  const InteractionPage({super.key});

  Future<void> _stopAndLeave() async {
    await controller.stop();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) controller.stop();
      },
      child: PageShell(
        title: controller.title,
        bottom: Row(
          children: [
            Expanded(
              child: StopButton(label: TranslationsKeys.btnStop.tr, onPressed: _stopAndLeave),
            ),
          ],
        ),
        child: Obx(() {
          final finished = controller.finished.value;
          final step = controller.step;
          final speaking = controller.isSpeaking.value;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            children: [
              Center(
                child: Text(
                  TranslationsKeys.interactionStep.trParams({
                    'current': '${controller.stepIndex.value + 1}',
                    'total': '${controller.totalSteps}',
                  }),
                  style: text.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: CaptainSami(
                  size: 200,
                  mood: finished ? SamiMood.happy : (speaking ? SamiMood.talking : SamiMood.calm),
                  reduceMotion: controller.reduceMotion,
                ),
              ),
              const SizedBox(height: 12),
              SpeechBubble(text: controller.currentText),
              if (!controller.voiceActive || !controller.voiceAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    controller.voiceActive ? TranslationsKeys.voiceUnavailable.tr : TranslationsKeys.voiceOffNote.tr,
                    textAlign: TextAlign.center,
                    style: text.bodySmall,
                  ),
                ),
              const SizedBox(height: 20),
              if (finished)
                _FinishedActions(controller: controller)
              else if (step.kind == StepKind.choice && controller.acknowledgement.value == null)
                Row(
                  children: [
                    for (var i = 0; i < step.optionKeys.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          key: Key('choice_$i'),
                          style: FilledButton.styleFrom(
                            backgroundColor: i == 0 ? AppColors.sky : AppColors.yellow,
                            foregroundColor: AppColors.ink,
                            minimumSize: const Size(64, 72),
                          ),
                          onPressed: () => controller.choose(i),
                          child: Text(step.optionKeys[i].tr, textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('replayButton'),
                        onPressed: controller.replay,
                        icon: const Icon(Icons.replay_rounded),
                        label: Text(TranslationsKeys.btnReplay.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('nextButton'),
                        onPressed: controller.next,
                        icon: const Icon(Icons.arrow_forward_rounded), // auto-mirrored: points left in RTL
                        label: Text(TranslationsKeys.btnNext.tr),
                      ),
                    ),
                  ],
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _FinishedActions extends StatelessWidget {
  const _FinishedActions({required this.controller});
  final InteractionController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.sessionExpired.value)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(TranslationsKeys.sessionEnded.tr, textAlign: TextAlign.center),
          ),
        Text(
          TranslationsKeys.interactionDoneTitle.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          key: const Key('celebrateButton'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
          onPressed: () async {
            await controller.stop();
            Get.offNamed(AppRoutes.praise, arguments: controller.situation.relatedBehaviorId);
          },
          icon: const Icon(Icons.celebration_rounded),
          label: Text(TranslationsKeys.interactionCelebrate.tr),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () async {
            await controller.stop();
            Get.back();
          },
          child: Text(TranslationsKeys.interactionLater.tr),
        ),
      ],
    );
  }
}
