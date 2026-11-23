import 'package:captain_kindheart/data/models/app_settings.dart';
import 'package:captain_kindheart/data/models/situation.dart';
import 'package:captain_kindheart/data/repositories/content_repository.dart';
import 'package:captain_kindheart/data/repositories/progress_repository.dart';
import 'package:captain_kindheart/data/repositories/settings_repository.dart';
import 'package:captain_kindheart/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fakes.dart';

void main() {
  setUp(() async => setUpApp());

  group('SettingsRepository', () {
    test('defaults are safe: voice on, quiet off, no name', () {
      final s = Get.find<SettingsRepository>().current;
      expect(s.childName, isNull);
      expect(s.onboarded, isFalse);
      expect(s.voiceActive, isTrue);
    });

    test('persists the name locally, trimmed, and can clear it', () async {
      final repo = Get.find<SettingsRepository>();
      await repo.setChildName('  نور  ');
      expect(repo.current.childName, 'نور');

      final reloaded = SettingsRepository(StorageService(await SharedPreferences.getInstance()));
      expect(reloaded.current.childName, 'نور');

      await repo.setChildName('');
      expect(repo.current.childName, isNull);
    });

    test('quiet mode disables voice', () async {
      final repo = Get.find<SettingsRepository>();
      await repo.update((s) => s.copyWith(quietMode: true));
      expect(repo.current.voiceActive, isFalse);
    });

    test('survives corrupt stored data', () async {
      SharedPreferences.setMockInitialValues({'settings_v1': 'not json'});
      final repo = SettingsRepository(StorageService(await SharedPreferences.getInstance()));
      expect(repo.current.onboarded, isFalse);
    });

    test('round-trips all fields through JSON', () {
      const s = AppSettings(
        childName: 'ريم',
        quietMode: true,
        voiceStyle: VoiceStyle.calm,
        ageRange: AgeRange.age3to4,
        sessionMinutes: 10,
        volume: 0.4,
      );
      final back = AppSettings.fromJson(s.toJson());
      expect(back.childName, 'ريم');
      expect(back.quietMode, isTrue);
      expect(back.voiceStyle, VoiceStyle.calm);
      expect(back.ageRange, AgeRange.age3to4);
      expect(back.sessionMinutes, 10);
      expect(back.volume, 0.4);
    });
  });

  group('ProgressRepository', () {
    test('awards a badge only the first time a behaviour is celebrated', () async {
      final repo = Get.find<ProgressRepository>();
      expect(await repo.addMoment('tidy', rewardId: 'sticker'), isTrue);
      expect(await repo.addMoment('tidy'), isFalse);
      expect(repo.progress.value.flowers, 2);
      expect(repo.progress.value.badges, {'tidy'});
    });

    test('persists moments and can be reset', () async {
      final repo = Get.find<ProgressRepository>();
      await repo.addMoment('share');
      final reloaded = ProgressRepository(StorageService(await SharedPreferences.getInstance()));
      expect(reloaded.progress.value.flowers, 1);
      await repo.reset();
      expect(repo.progress.value.flowers, 0);
    });
  });

  group('ContentRepository', () {
    test('uses parent wording when saved and restores the default', () async {
      final repo = Get.find<ContentRepository>();
      final tidy = repo.situation('tidy');
      final original = repo.mainMessage(tidy);
      await repo.saveOverride('tidy', const SituationOverride(title: 'ترتيب الغرفة', message: '{الاسم}، نرتّب معًا؟'));
      expect(repo.title(tidy), 'ترتيب الغرفة');
      expect(repo.mainMessage(tidy), '{الاسم}، نرتّب معًا؟');
      expect(repo.isCustomized('tidy'), isTrue);

      await repo.restoreDefault('tidy');
      expect(repo.mainMessage(tidy), original);
      expect(repo.isCustomized('tidy'), isFalse);
    });

    test('ships all six reminder situations from the brief', () {
      final ids = Get.find<ContentRepository>().situations.map((s) => s.id);
      expect(ids, containsAll(['tidy', 'gentle', 'voice', 'share', 'listen', 'bedtime']));
    });

    test('every situation has instruction, a two-option choice, and reassurance', () {
      for (final s in Get.find<ContentRepository>().situations) {
        expect(s.steps.first.kind, StepKind.instruction);
        final choice = s.steps.firstWhere((x) => x.kind == StepKind.choice);
        expect(choice.optionKeys, hasLength(2));
        expect(s.steps.last.kind, StepKind.reassurance);
      }
    });
  });
}
