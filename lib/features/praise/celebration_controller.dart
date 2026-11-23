import 'dart:math';

import 'package:get/get.dart';

import '../../core/translations/translations_keys.dart';
import '../../data/mock/mock_content.dart';
import '../../data/models/behavior.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/audio/audio_service.dart';

class CelebrationController extends GetxController {
  CelebrationController({
    required this.behaviorId,
    required this.rewardId,
    required ContentRepository content,
    required SettingsRepository settings,
    required ProgressRepository progress,
    required AudioService audio,
    Random? random,
  }) : _content = content,
       _settings = settings,
       _progress = progress,
       _audio = audio,
       _random = random ?? Random();

  final String behaviorId;
  final String? rewardId;
  final ContentRepository _content;
  final SettingsRepository _settings;
  final ProgressRepository _progress;
  final AudioService _audio;
  final Random _random;

  late final Behavior behavior = _content.behavior(behaviorId);
  late final RewardOption? reward = _content.reward(rewardId);
  late final String cheer = MockContent.cheers[_random.nextInt(MockContent.cheers.length)].tr;
  final RxBool newBadge = false.obs;
  final RxBool recorded = false.obs;

  bool get reduceMotion => _settings.current.quietMode;
  bool get isDance => reward?.id == 'dance';

  String get message => _settings.personalizer.apply(behavior.praiseKey.tr);
  String get badgeTitle => behavior.badgeKey.tr;
  String? get rewardLine =>
      reward == null ? null : TranslationsKeys.celebReward.trParams({'reward': reward!.titleKey.tr});

  @override
  void onInit() {
    super.onInit();
    _record();
  }

  Future<void> _record() async {
    newBadge.value = await _progress.addMoment(behaviorId, rewardId: rewardId);
    recorded.value = true;
  }

  @override
  void onReady() {
    super.onReady();
    speak();
  }

  Future<void> speak() => _audio.speak('$cheer $message');

  Future<void> stop() => _audio.stop();

  @override
  void onClose() {
    _audio.stop();
    super.onClose();
  }
}
