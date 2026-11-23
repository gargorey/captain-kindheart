import 'dart:async';

import 'package:get/get.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';
import 'speech_engine.dart';

/// All of Captain Sami's voice goes through here, so a single [stop] call
/// silences everything.
class AudioService extends GetxService {
  AudioService(this._engine, this._settings);

  static const String language = 'ar-SA';

  final SpeechEngine _engine;
  final SettingsRepository _settings;

  final RxBool isSpeaking = false.obs;

  /// False when the device has no usable Arabic voice or the engine failed.
  final RxBool available = true.obs;

  /// Temporary mute (for example the mute button during a pretend call).
  final RxBool muted = false.obs;

  Completer<void>? _pending;

  bool get canSpeak => available.value && !muted.value && _settings.current.voiceActive;

  Future<void> init() async {
    try {
      final (rate, pitch) = _voiceParams(_settings.current.voiceStyle);
      await _engine.configure(language: language, volume: _settings.current.volume, rate: rate, pitch: pitch);
      available.value = true;
    } catch (_) {
      available.value = false;
    }
  }

  Future<void> applySettings() => init();

  static (double, double) _voiceParams(VoiceStyle style) => switch (style) {
    VoiceStyle.calm => (0.38, 0.95),
    VoiceStyle.warm => (0.44, 1.05),
    VoiceStyle.cheerful => (0.5, 1.2),
  };

  /// Speaks [text] if voice is enabled. Returns when speech ends or is stopped.
  Future<void> speak(String text) async {
    if (!canSpeak || text.trim().isEmpty) return;
    await stop();
    final pending = Completer<void>();
    _pending = pending;
    isSpeaking.value = true;
    _engine
        .speak(text)
        .catchError((Object _) {
          available.value = false;
        })
        .whenComplete(() {
          if (!pending.isCompleted) pending.complete();
        });
    await pending.future;
    if (identical(_pending, pending)) {
      isSpeaking.value = false;
      _pending = null;
    }
  }

  /// Immediately stops all voice. Safe to call at any time.
  Future<void> stop() async {
    final pending = _pending;
    _pending = null;
    isSpeaking.value = false;
    if (pending != null && !pending.isCompleted) pending.complete();
    try {
      await _engine.stop();
    } catch (_) {
      // Nothing to stop or engine unavailable: already silent.
    }
  }

  Future<void> pause() async {
    try {
      await _engine.pause();
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    try {
      await _engine.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  Future<void> setMuted(bool value) async {
    muted.value = value;
    if (value) await stop();
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}
