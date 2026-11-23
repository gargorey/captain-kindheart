/// Abstraction over a text-to-speech backend so the app (and tests) never
/// depend on a platform plugin directly.
abstract class SpeechEngine {
  Future<void> configure({
    required String language,
    required double volume,
    required double rate,
    required double pitch,
  });

  /// Speaks [text]. Should complete when speech ends or is stopped.
  Future<void> speak(String text);

  Future<void> stop();

  Future<void> pause();

  Future<void> setVolume(double volume);
}
