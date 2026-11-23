import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/mock/mock_content.dart';
import '../../widgets/captain_sami.dart';
import '../../widgets/page_shell.dart';
import 'onboarding_controller.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      showBack: false,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: const [_Welcome(), _MeetSami(), _Safety(), _NameStep()],
            ),
          ),
          Obx(() => _Dots(index: controller.page.value)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Obx(() {
              final last = controller.isLast;
              return Row(
                children: [
                  if (controller.page.value > 0)
                    Expanded(
                      child: OutlinedButton(onPressed: controller.back, child: Text(TranslationsKeys.btnBack.tr)),
                    ),
                  if (controller.page.value > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      key: const Key('onboardingNext'),
                      onPressed: last ? controller.finish : controller.next,
                      child: Text(last ? TranslationsKeys.onbFinish.tr : TranslationsKeys.btnNext.tr),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(OnboardingController.pageCount, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 26 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? AppColors.teal : AppColors.teal.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _StepFrame extends StatelessWidget {
  const _StepFrame({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: children),
  );
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _StepFrame(
      children: [
        const CaptainSami(size: 220, mood: SamiMood.happy),
        const SizedBox(height: 20),
        Text(TranslationsKeys.onbWelcomeTitle.tr, style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(TranslationsKeys.onbWelcomeBody.tr, style: text.bodyLarge, textAlign: TextAlign.center),
      ],
    );
  }
}

class _MeetSami extends StatelessWidget {
  const _MeetSami();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _StepFrame(
      children: [
        const CaptainSami(size: 200, mood: SamiMood.talking),
        const SizedBox(height: 8),
        Chip(
          avatar: const Icon(Icons.auto_awesome_rounded, color: AppColors.tealDeep, size: 18),
          label: Text(TranslationsKeys.pretendLabel.tr),
          backgroundColor: AppColors.yellow.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 12),
        Text(TranslationsKeys.onbMeetTitle.tr, style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(TranslationsKeys.onbMeetBody.tr, style: text.bodyLarge, textAlign: TextAlign.center),
      ],
    );
  }
}

class _Safety extends StatelessWidget {
  const _Safety();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final points = [
      (Icons.phone_disabled_rounded, TranslationsKeys.onbSafety1),
      (Icons.favorite_rounded, TranslationsKeys.onbSafety2),
      (Icons.pan_tool_alt_rounded, TranslationsKeys.onbSafety3),
      (Icons.family_restroom_rounded, TranslationsKeys.onbSafety4),
    ];
    return _StepFrame(
      children: [
        const Icon(Icons.shield_moon_rounded, size: 64, color: AppColors.teal),
        const SizedBox(height: 8),
        Text(TranslationsKeys.onbSafetyTitle.tr, style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        for (final (icon, key) in points)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.coral),
                  const SizedBox(width: 12),
                  Expanded(child: Text(key.tr, style: text.bodyLarge)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(TranslationsKeys.onbLanguageTitle.tr, style: text.titleMedium),
        const SizedBox(height: 6),
        ChoiceChip(
          label: Text(TranslationsKeys.onbLanguageArabic.tr),
          selected: true,
          onSelected: (_) {},
          selectedColor: AppColors.teal.withValues(alpha: 0.2),
        ),
        Text(TranslationsKeys.onbLanguageNote.tr, style: text.bodySmall),
      ],
    );
  }
}

class _NameStep extends GetView<OnboardingController> {
  const _NameStep();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _StepFrame(
      children: [
        const CaptainSami(size: 150, mood: SamiMood.calm),
        const SizedBox(height: 12),
        Text(TranslationsKeys.onbNameTitle.tr, style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(TranslationsKeys.onbNameBody.tr, style: text.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        TextField(
          key: const Key('onboardingName'),
          controller: controller.nameController,
          textAlign: TextAlign.center,
          maxLength: 30,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: TranslationsKeys.onbNameHint.tr, counterText: ''),
        ),
        const SizedBox(height: 16),
        Text(TranslationsKeys.onbFallbackTitle.tr, style: text.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final key in MockContent.fallbackPhraseKeys)
                ChoiceChip(
                  label: Text(key.tr),
                  selected: controller.fallbackKey.value == key,
                  selectedColor: AppColors.teal.withValues(alpha: 0.2),
                  onSelected: (_) => controller.fallbackKey.value = key,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          key: const Key('onboardingSkipName'),
          onPressed: () => controller.finish(skipName: true),
          child: Text(TranslationsKeys.onbNameSkip.tr),
        ),
      ],
    );
  }
}
