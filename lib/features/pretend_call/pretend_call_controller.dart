import 'dart:async';

import 'package:get/get.dart';

import '../../core/utils/session_timer.dart';
import '../../data/models/call_script.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/audio/audio_service.dart';

enum CallPhase { ringing, connected, ended }

/// In-app pretend call. There is no telephony here at all: no dialer, no SMS,
/// no network. It is an animation plus on-device speech.
class PretendCallController extends GetxController with SessionTimerMixin {
  PretendCallController({
    required this.scriptId,
    required ContentRepository content,
    required SettingsRepository settings,
    required AudioService audio,
  }) : _content = content,
       _settings = settings,
       _audio = audio;

  static const Duration pauseBetweenLines = Duration(milliseconds: 900);

  final String scriptId;
  final ContentRepository _content;
  final SettingsRepository _settings;
  final AudioService _audio;

  late final CallScript script = _content.callScript(scriptId);
  final Rx<CallPhase> phase = CallPhase.ringing.obs;
  final RxInt lineIndex = 0.obs;

  Timer? _lineTimer;
  int _generation = 0;

  RxBool get muted => _audio.muted;
  RxBool get isSpeaking => _audio.isSpeaking;
  bool get reduceMotion => _settings.current.quietMode;
  bool get finishedScript => lineIndex.value >= script.lineKeys.length - 1;

  String get currentLine => _settings.personalizer.apply(script.lineKeys[lineIndex.value].tr);

  @override
  void onInit() {
    super.onInit();
    _audio.muted.value = false;
  }

  void answer() {
    if (phase.value != CallPhase.ringing) return;
    phase.value = CallPhase.connected;
    lineIndex.value = 0;
    startSessionTimer(Duration(minutes: _settings.current.sessionMinutes), end);
    _playLine(++_generation);
  }

  Future<void> _playLine(int gen) async {
    if (gen != _generation || phase.value != CallPhase.connected) return;
    final line = currentLine;
    final started = DateTime.now();
    await _audio.speak(line);
    if (gen != _generation || phase.value != CallPhase.connected) return;
    // When voice is off, give enough reading time before the next line.
    final spoken = DateTime.now().difference(started);
    final readingTime = Duration(milliseconds: 1400 + line.length * 55);
    final wait = spoken < const Duration(milliseconds: 300) && !_audio.canSpeak ? readingTime : pauseBetweenLines;
    if (finishedScript) return;
    _lineTimer?.cancel();
    _lineTimer = Timer(wait, () {
      if (gen != _generation || phase.value != CallPhase.connected) return;
      lineIndex.value++;
      _playLine(gen);
    });
  }

  Future<void> toggleMute() => _audio.setMuted(!_audio.muted.value);

  /// Always available. Immediately stops all audio and animation.
  Future<void> end() async {
    _generation++;
    _lineTimer?.cancel();
    _lineTimer = null;
    cancelSessionTimer();
    phase.value = CallPhase.ended;
    await _audio.stop();
  }

  @override
  void onClose() {
    _generation++;
    _lineTimer?.cancel();
    _audio.stop();
    _audio.muted.value = false;
    super.onClose();
  }
}
