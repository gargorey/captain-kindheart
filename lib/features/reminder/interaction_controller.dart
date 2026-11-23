import 'package:get/get.dart';

import '../../core/translations/translations_keys.dart';
import '../../core/utils/session_timer.dart';
import '../../data/models/situation.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/audio/audio_service.dart';

/// Gentle reminder: Captain Sami says one simple thing at a time.
class InteractionController extends GetxController with SessionTimerMixin {
  InteractionController({
    required this.situationId,
    required ContentRepository content,
    required SettingsRepository settings,
    required AudioService audio,
  }) : _content = content,
       _settings = settings,
       _audio = audio;

  final String situationId;
  final ContentRepository _content;
  final SettingsRepository _settings;
  final AudioService _audio;

  late final Situation situation = _content.situation(situationId);
  final RxInt stepIndex = 0.obs;
  final RxBool finished = false.obs;
  final RxBool stopped = false.obs;
  final RxBool sessionExpired = false.obs;

  /// Shown instead of the step line right after a choice is made.
  final RxnString acknowledgement = RxnString();

  RxBool get isSpeaking => _audio.isSpeaking;
  bool get voiceActive => _settings.current.voiceActive;
  bool get voiceAvailable => _audio.available.value;
  bool get reduceMotion => _settings.current.quietMode;

  int get totalSteps => situation.steps.length;
  InteractionStep get step => situation.steps[stepIndex.value];
  String get title => _content.title(situation);

  /// Personalized text for the current step.
  String get currentText {
    final ack = acknowledgement.value;
    if (ack != null) return ack;
    final raw = stepIndex.value == 0 ? _content.mainMessage(situation) : step.textKey.tr;
    return _settings.personalizer.apply(raw);
  }

  @override
  void onReady() {
    super.onReady();
    startSessionTimer(Duration(minutes: _settings.current.sessionMinutes), _onSessionExpired);
    speakCurrent();
  }

  Future<void> speakCurrent() async {
    if (stopped.value) return;
    await _audio.speak(currentText);
  }

  Future<void> replay() => speakCurrent();

  Future<void> choose(int optionIndex) async {
    if (stopped.value || step.kind != StepKind.choice) return;
    acknowledgement.value = TranslationsKeys.choiceAck.tr;
    await _audio.speak(currentText);
    if (stopped.value) return;
    acknowledgement.value = null;
    await next();
  }

  Future<void> next() async {
    if (stopped.value) return;
    acknowledgement.value = null;
    if (stepIndex.value >= totalSteps - 1) {
      finished.value = true;
      await _audio.stop();
      return;
    }
    stepIndex.value++;
    await speakCurrent();
  }

  /// Stops all voice and animation immediately.
  Future<void> stop() async {
    stopped.value = true;
    cancelSessionTimer();
    await _audio.stop();
  }

  Future<void> _onSessionExpired() async {
    if (stopped.value) return;
    sessionExpired.value = true;
    acknowledgement.value = TranslationsKeys.sessionGoodbye.tr;
    await _audio.speak(currentText);
    finished.value = true;
  }

  @override
  void onClose() {
    _audio.stop();
    super.onClose();
  }
}
