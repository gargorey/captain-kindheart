import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../widgets/captain_sami.dart';
import '../../widgets/speech_bubble.dart';
import 'pretend_call_controller.dart';

/// A cartoon "call card", deliberately unlike a phone OS call screen:
/// bright playful colours, a "pretend" label, no caller ID or number.
class PretendCallPage extends GetView<PretendCallController> {
  const PretendCallPage({super.key});

  Future<void> _endAndLeave() async {
    await controller.end();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) controller.end();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFBFEFFF), Color(0xFFFFF1C9)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Obx(() {
                  final phase = controller.phase.value;
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        key: const Key('pretendBadge'),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: AppColors.coral),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                TranslationsKeys.callBadge.tr,
                                style: text.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            children: [
                              _Avatar(
                                ringing: phase == CallPhase.ringing,
                                reduceMotion: controller.reduceMotion,
                                speaking: controller.isSpeaking.value,
                                happy: phase == CallPhase.ended,
                              ),
                              const SizedBox(height: 16),
                              if (phase == CallPhase.ringing)
                                Text(
                                  TranslationsKeys.callRinging.tr,
                                  style: text.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                              if (phase == CallPhase.connected) SpeechBubble(text: controller.currentLine),
                              if (phase == CallPhase.ended) ...[
                                Text(
                                  TranslationsKeys.callEndedTitle.tr,
                                  style: text.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  TranslationsKeys.callEndedBody.tr,
                                  style: text.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: phase == CallPhase.ended
                            ? Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Get.back(),
                                      child: Text(TranslationsKeys.btnBack.tr),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
                                      onPressed: () => Get.offNamed(AppRoutes.praise),
                                      child: Text(TranslationsKeys.homePraiseTitle.tr),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (phase == CallPhase.connected)
                                    _RoundAction(
                                      key: const Key('muteButton'),
                                      icon: controller.muted.value ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                      label: controller.muted.value
                                          ? TranslationsKeys.callUnmute.tr
                                          : TranslationsKeys.callMute.tr,
                                      color: AppColors.sky,
                                      onTap: controller.toggleMute,
                                    ),
                                  if (phase == CallPhase.ringing)
                                    _RoundAction(
                                      key: const Key('answerButton'),
                                      icon: Icons.waving_hand_rounded,
                                      label: TranslationsKeys.callAnswer.tr,
                                      color: AppColors.greenDeep,
                                      onTap: controller.answer,
                                    ),
                                  // End is always visible while the call is active.
                                  _RoundAction(
                                    key: const Key('endCallButton'),
                                    icon: Icons.close_rounded,
                                    label: TranslationsKeys.callEnd.tr,
                                    color: AppColors.coral,
                                    onTap: _endAndLeave,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatefulWidget {
  const _Avatar({required this.ringing, required this.reduceMotion, required this.speaking, required this.happy});
  final bool ringing;
  final bool reduceMotion;
  final bool speaking;
  final bool happy;

  @override
  State<_Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<_Avatar> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_Avatar old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final still = widget.reduceMotion || (MediaQuery.maybeOf(context)?.disableAnimations ?? false);
    if (widget.ringing && !still) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Container(
        padding: EdgeInsets.all(14 + _pulse.value * 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.yellow.withValues(alpha: 0.25 + _pulse.value * 0.25),
        ),
        child: child,
      ),
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        padding: const EdgeInsets.all(10),
        child: CaptainSami(
          size: 190,
          mood: widget.happy ? SamiMood.happy : (widget.speaking ? SamiMood.talking : SamiMood.happy),
          reduceMotion: widget.reduceMotion,
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({super.key, required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
