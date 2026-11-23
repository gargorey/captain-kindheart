import 'package:captain_kindheart/data/repositories/settings_repository.dart';
import 'package:captain_kindheart/services/audio/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeSpeechEngine engine;
  late AudioService audio;

  setUp(() async {
    engine = await setUpApp();
    audio = Get.find<AudioService>();
  });

  test('speaks when voice is enabled', () async {
    await audio.speak('مرحبًا');
    expect(engine.spoken, ['مرحبًا']);
    expect(audio.isSpeaking.value, isFalse);
  });

  test('stop() ends in-progress speech immediately', () async {
    engine.holdSpeech = true;
    final speaking = audio.speak('جملة طويلة');
    await Future<void>.delayed(Duration.zero);
    expect(audio.isSpeaking.value, isTrue);

    await audio.stop();
    await speaking; // completes instead of hanging
    expect(audio.isSpeaking.value, isFalse);
    expect(engine.stopCount, greaterThan(0));
  });

  test('quiet mode and disabled voice keep the app silent', () async {
    final settings = Get.find<SettingsRepository>();
    await settings.update((s) => s.copyWith(quietMode: true));
    await audio.speak('لا تُقال');
    await settings.update((s) => s.copyWith(quietMode: false, voiceEnabled: false));
    await audio.speak('ولا هذه');
    expect(engine.spoken, isEmpty);
  });

  test('mute stops speech and blocks new speech until unmuted', () async {
    await audio.setMuted(true);
    await audio.speak('مكتوم');
    expect(engine.spoken, isEmpty);
    await audio.setMuted(false);
    await audio.speak('مسموع');
    expect(engine.spoken, ['مسموع']);
  });

  test('missing Arabic voice is handled gracefully', () async {
    engine.failConfigure = true;
    await audio.init();
    expect(audio.available.value, isFalse);
    await audio.speak('نص');
    expect(engine.spoken, isEmpty);
  });

  test('a failing speak call marks audio unavailable without throwing', () async {
    engine.failSpeak = true;
    await audio.speak('نص');
    expect(audio.available.value, isFalse);
    expect(audio.isSpeaking.value, isFalse);
  });

  test('volume is clamped and passed to the engine', () async {
    await audio.setVolume(3);
    expect(engine.volume, 1.0);
  });
}
