import 'package:captain_kindheart/core/translations/translations_keys.dart';
import 'package:captain_kindheart/data/models/situation.dart';
import 'package:captain_kindheart/data/repositories/content_repository.dart';
import 'package:captain_kindheart/data/repositories/progress_repository.dart';
import 'package:captain_kindheart/data/repositories/settings_repository.dart';
import 'package:captain_kindheart/features/parent_gate/parent_gate.dart';
import 'package:captain_kindheart/features/praise/celebration_controller.dart';
import 'package:captain_kindheart/features/pretend_call/pretend_call_controller.dart';
import 'package:captain_kindheart/features/reminder/interaction_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeSpeechEngine engine;

  setUp(() async {
    engine = await setUpApp();
    await Get.find<SettingsRepository>().setChildName('سارة');
  });

  InteractionController interaction(String id) =>
      InteractionController(situationId: id, content: Get.find(), settings: Get.find(), audio: Get.find());

  PretendCallController call(String id) =>
      PretendCallController(scriptId: id, content: Get.find(), settings: Get.find(), audio: Get.find());

  group('InteractionController', () {
    test('walks instruction → choice → reassurance, personalised', () async {
      final c = interaction('tidy');
      expect(c.currentText, contains('يا سارة'));
      await c.speakCurrent();
      expect(engine.spoken.single, contains('يا سارة'));

      await c.next();
      expect(c.step.kind, StepKind.choice);
      await c.choose(0);
      expect(engine.spoken, contains(TranslationsKeys.choiceAck.tr));
      expect(c.step.kind, StepKind.reassurance);

      await c.next();
      expect(c.finished.value, isTrue);
      await c.stop();
    });

    test('stop() silences audio and ignores further taps', () async {
      final c = interaction('share');
      await c.stop();
      final before = engine.spoken.length;
      await c.next();
      await c.replay();
      expect(engine.spoken.length, before);
      expect(engine.stopCount, greaterThan(0));
    });

    test('uses the parent-written message on the first step', () async {
      await Get.find<ContentRepository>().saveOverride(
        'tidy',
        const SituationOverride(message: '{الاسم}، يلا نرتّب غرفتنا'),
      );
      final c = interaction('tidy');
      expect(c.currentText, 'يا سارة، يلا نرتّب غرفتنا');
      await c.stop();
    });

    test('ends gently when the session length passes', () {
      fakeAsync((fa) {
        final c = interaction('voice');
        c.onReady();
        fa.elapse(const Duration(minutes: 5, seconds: 1));
        fa.flushMicrotasks();
        expect(c.sessionExpired.value, isTrue);
        expect(c.finished.value, isTrue);
        expect(engine.spoken.last, TranslationsKeys.sessionGoodbye.tr);
        c.stop();
      });
    });
  });

  group('PretendCallController', () {
    test('rings until answered, then plays the script line by line', () {
      fakeAsync((fa) {
        final c = call('kind');
        expect(c.phase.value, CallPhase.ringing);
        expect(engine.spoken, isEmpty);

        c.answer();
        fa.flushMicrotasks();
        expect(c.phase.value, CallPhase.connected);
        expect(engine.spoken.first, contains('يا سارة'));

        fa.elapse(const Duration(seconds: 1));
        expect(c.lineIndex.value, 1);
        expect(engine.spoken, hasLength(2));
        c.end();
        fa.flushMicrotasks();
      });
    });

    test('end() stops audio and no further lines play', () {
      fakeAsync((fa) {
        engine.holdSpeech = true;
        final c = call('tidy');
        c.answer();
        fa.flushMicrotasks();
        expect(engine.isHoldingSpeech, isTrue);

        c.end();
        fa.flushMicrotasks();
        expect(c.phase.value, CallPhase.ended);
        expect(engine.isHoldingSpeech, isFalse);
        final spokenAtEnd = engine.spoken.length;

        fa.elapse(const Duration(minutes: 1));
        expect(engine.spoken.length, spokenAtEnd);
        expect(fa.pendingTimers, isEmpty);
      });
    });

    test('mute stops current speech; script continues silently', () {
      fakeAsync((fa) {
        final c = call('bedtime');
        c.answer();
        fa.flushMicrotasks();
        c.toggleMute();
        fa.flushMicrotasks();
        expect(c.muted.value, isTrue);
        final count = engine.spoken.length;
        fa.elapse(const Duration(seconds: 30));
        expect(engine.spoken.length, count);
        expect(c.lineIndex.value, greaterThan(0));
        c.end();
        fa.flushMicrotasks();
      });
    });
  });

  group('CelebrationController', () {
    test('records a positive moment and reports a new badge once', () async {
      CelebrationController make() => CelebrationController(
        behaviorId: 'teeth',
        rewardId: 'story',
        content: Get.find(),
        settings: Get.find(),
        progress: Get.find(),
        audio: Get.find(),
      )..onInit();

      final first = make();
      await Future<void>.delayed(Duration.zero);
      expect(first.newBadge.value, isTrue);
      expect(first.message, contains('يا سارة'));
      expect(first.rewardLine, contains(TranslationsKeys.rwStory.tr));

      final second = make();
      await Future<void>.delayed(Duration.zero);
      expect(second.newBadge.value, isFalse);
      expect(Get.find<ProgressRepository>().progress.value.flowers, 2);
    });
  });

  group('ParentGateChallenge', () {
    test('accepts the correct product in Western or Arabic-Indic digits', () {
      final g = ParentGateChallenge(6, 7);
      expect(g.check('42'), isTrue);
      expect(g.check('٤٢'), isTrue);
      expect(g.check('41'), isFalse);
      expect(g.check(''), isFalse);
    });

    test('random challenges use factors 3–9', () {
      for (var i = 0; i < 50; i++) {
        final g = ParentGateChallenge.random();
        expect(g.a, inInclusiveRange(3, 9));
        expect(g.b, inInclusiveRange(3, 9));
      }
    });
  });
}
