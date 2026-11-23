import 'package:flutter_tts/flutter_tts.dart';

import 'speech_engine.dart';

/// On-device TTS via flutter_tts. Arabic voice quality depends on the voices
/// installed on the phone.
class FlutterTtsEngine implements SpeechEngine {
  FlutterTtsEngine([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> configure({
    required String language,
    required double volume,
    required double rate,
    required double pitch,
  }) async {
    await _tts.awaitSpeakCompletion(true);
    // Ambient respects the iOS silent switch and mixes politely with other audio.
    await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambient, [
      IosTextToSpeechAudioCategoryOptions.mixWithOthers,
    ]);
    final available = await _tts.isLanguageAvailable(language);
    if (available == false) {
      throw StateError('Language $language not available');
    }
    await _tts.setLanguage(language);
    await _tts.setVolume(volume);
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
  }

  @override
  Future<void> speak(String text) async => _tts.speak(text);

  @override
  Future<void> stop() async => _tts.stop();

  @override
  Future<void> pause() async => _tts.pause();

  @override
  Future<void> setVolume(double volume) async => _tts.setVolume(volume);
}
