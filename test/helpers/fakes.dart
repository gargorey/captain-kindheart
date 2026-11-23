import 'dart:async';

import 'package:captain_kindheart/app/bootstrap.dart';
import 'package:captain_kindheart/core/translations/ar_translations.dart';
import 'package:captain_kindheart/services/audio/speech_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records everything the app asks the speech engine to do.
class FakeSpeechEngine implements SpeechEngine {
  final List<String> spoken = [];
  int stopCount = 0;
  int pauseCount = 0;
  double? volume;
  bool failConfigure = false;
  bool failSpeak = false;

  /// When true, [speak] waits until [finishSpeaking] or [stop] is called.
  bool holdSpeech = false;
  Completer<void>? _current;

  bool get isHoldingSpeech => _current != null && !_current!.isCompleted;

  @override
  Future<void> configure({
    required String language,
    required double volume,
    required double rate,
    required double pitch,
  }) async {
    if (failConfigure) throw StateError('no Arabic voice');
    this.volume = volume;
  }

  @override
  Future<void> speak(String text) async {
    if (failSpeak) throw StateError('speak failed');
    spoken.add(text);
    if (holdSpeech) {
      _current = Completer<void>();
      await _current!.future;
    }
  }

  void finishSpeaking() => _current?.complete();

  @override
  Future<void> stop() async {
    stopCount++;
    if (_current != null && !_current!.isCompleted) _current!.complete();
  }

  @override
  Future<void> pause() async => pauseCount++;

  @override
  Future<void> setVolume(double volume) async => this.volume = volume;
}

/// Fresh GetX + storage + Arabic translations for each test.
Future<FakeSpeechEngine> setUpApp({Map<String, Object> prefs = const {}, FakeSpeechEngine? engine}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.reset();
  Get.testMode = true;
  SharedPreferences.setMockInitialValues(prefs);
  Get.clearTranslations();
  Get.addTranslations({'ar': arTranslations});
  Get.locale = const Locale('ar');
  final fake = engine ?? FakeSpeechEngine();
  await initDependencies(engine: fake);
  return fake;
}

/// Pumps frames without waiting for repeating animations to settle.
Future<void> pumpFrames(
  WidgetTester tester, {
  int frames = 8,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(step);
  }
}

/// Settings JSON for an already-onboarded parent.
Map<String, Object> onboardedPrefs({String? name = 'سارة', bool callIntroSeen = true, bool quiet = false}) => {
  'flutter.settings_v1':
      '{"onboarded":true,"callIntroSeen":$callIntroSeen,"childName":${name == null ? 'null' : '"$name"'},"quietMode":$quiet}',
};
