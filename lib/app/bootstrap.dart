import 'package:get/get.dart';

import '../data/repositories/content_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../services/audio/audio_service.dart';
import '../services/audio/flutter_tts_engine.dart';
import '../services/audio/speech_engine.dart';
import '../services/storage_service.dart';

/// Registers app-wide services. Tests pass a fake [SpeechEngine].
Future<void> initDependencies({SpeechEngine? engine}) async {
  final storage = await StorageService.create();
  Get.put<StorageService>(storage, permanent: true);
  final settings = Get.put(SettingsRepository(storage), permanent: true);
  Get.put(ContentRepository(storage), permanent: true);
  Get.put(ProgressRepository(storage), permanent: true);
  final audio = Get.put(AudioService(engine ?? FlutterTtsEngine(), settings), permanent: true);
  await audio.init();
}
