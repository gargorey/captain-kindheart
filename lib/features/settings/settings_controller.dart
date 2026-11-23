import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/translations/translations_keys.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/audio/audio_service.dart';

class SettingsController extends GetxController {
  SettingsController({
    required SettingsRepository settings,
    required ProgressRepository progress,
    required ContentRepository content,
    required AudioService audio,
  }) : _settings = settings,
       _progress = progress,
       _content = content,
       _audio = audio;

  final SettingsRepository _settings;
  final ProgressRepository _progress;
  final ContentRepository _content;
  final AudioService _audio;

  late final TextEditingController nameController = TextEditingController(text: _settings.current.childName ?? '');

  Rx<AppSettings> get settings => _settings.settings;
  AppSettings get s => _settings.current;

  Future<void> saveName() async {
    await _settings.setChildName(nameController.text);
    nameController.text = _settings.current.childName ?? '';
  }

  Future<void> clearName() async {
    nameController.clear();
    await _settings.setChildName(null);
  }

  Future<void> setFallback(String key) => _settings.update((x) => x.copyWith(fallbackPhraseKey: key));
  Future<void> setAge(AgeRange age) => _settings.update((x) => x.copyWith(ageRange: age));
  Future<void> setAvatar(String id) => _settings.update((x) => x.copyWith(avatarId: id));

  Future<void> setVoiceEnabled(bool v) async {
    await _settings.update((x) => x.copyWith(voiceEnabled: v));
    if (!v) await _audio.stop();
  }

  Future<void> setVoiceStyle(VoiceStyle v) async {
    await _settings.update((x) => x.copyWith(voiceStyle: v));
    await _audio.applySettings();
  }

  Future<void> setVolume(double v) async {
    await _settings.update((x) => x.copyWith(volume: v));
    await _audio.setVolume(v);
  }

  Future<void> setQuietMode(bool v) async {
    await _settings.update((x) => x.copyWith(quietMode: v));
    if (v) await _audio.stop();
  }

  Future<void> setSessionMinutes(int m) => _settings.update((x) => x.copyWith(sessionMinutes: m));

  Future<void> testVoice() => _audio.speak(TranslationsKeys.voiceTestLine.tr);

  Future<void> resetProgress() => _progress.reset();

  /// Clears everything, including the child's name, and returns to onboarding.
  Future<void> resetAll() async {
    await _audio.stop();
    await _progress.reset();
    await _content.reset();
    await _settings.reset();
    nameController.clear();
  }

  @override
  void onClose() {
    _audio.stop();
    nameController.dispose();
    super.onClose();
  }
}
