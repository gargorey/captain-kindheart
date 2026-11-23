import 'package:captain_kindheart/app/app.dart';
import 'package:captain_kindheart/app/routes/app_routes.dart';
import 'package:captain_kindheart/core/translations/translations_keys.dart';
import 'package:captain_kindheart/data/repositories/progress_repository.dart';
import 'package:captain_kindheart/data/repositories/settings_repository.dart';
import 'package:captain_kindheart/features/parent_gate/parent_gate.dart';
import 'package:captain_kindheart/features/pretend_call/pretend_call_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeSpeechEngine engine;

  Future<void> launch(WidgetTester tester, {String route = AppRoutes.home, Map<String, Object>? prefs}) async {
    engine = await tester.runAsync(() => setUpApp(prefs: prefs ?? onboardedPrefs())) as FakeSpeechEngine;
    await tester.binding.setSurfaceSize(const Size(400, 860));
    await tester.pumpWidget(CaptainKindheartApp(initialRoute: route));
    await pumpFrames(tester);
  }

  Future<void> tapKey(WidgetTester tester, Key key) async {
    final f = find.byKey(key);
    if (f.evaluate().isEmpty) {
      // Lazily built list item: scroll the main list until it exists.
      await tester.scrollUntilVisible(
        f,
        200,
        scrollable: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first,
      );
    }
    await tester.runAsync(() => Scrollable.ensureVisible(tester.element(f), alignment: 0.5));
    await tester.pump();
    await tester.tap(f);
  }

  tearDown(() {
    ParentGateChallenge.debugFixed = null;
  });

  testWidgets('splash sends a new parent to onboarding', (tester) async {
    await launch(tester, route: AppRoutes.splash, prefs: const {});
    await pumpFrames(tester, frames: 20);
    expect(find.text(TranslationsKeys.onbWelcomeTitle.tr), findsOneWidget);
  });

  testWidgets('onboarding saves an optional name and lands on parent home', (tester) async {
    await launch(tester, route: AppRoutes.onboarding, prefs: const {});
    expect(Directionality.of(tester.element(find.byType(PageView))), TextDirection.rtl);

    for (var i = 0; i < 3; i++) {
      await tapKey(tester, const Key('onboardingNext'));
      await pumpFrames(tester);
    }
    expect(find.text(TranslationsKeys.onbNameTitle.tr), findsOneWidget);
    await tester.enterText(find.byKey(const Key('onboardingName')), 'سارة');
    await tapKey(tester, const Key('onboardingNext'));
    await pumpFrames(tester);

    final settings = Get.find<SettingsRepository>().current;
    expect(settings.onboarded, isTrue);
    expect(settings.childName, 'سارة');
    expect(find.byKey(const Key('homeReminder')), findsOneWidget);
    expect(find.byKey(const Key('homeCall')), findsOneWidget);
    expect(find.byKey(const Key('homePraise')), findsOneWidget);
  });

  testWidgets('name step can be skipped', (tester) async {
    await launch(tester, route: AppRoutes.onboarding, prefs: const {});
    for (var i = 0; i < 3; i++) {
      await tapKey(tester, const Key('onboardingNext'));
      await pumpFrames(tester);
    }
    await tester.enterText(find.byKey(const Key('onboardingName')), 'لن يُحفظ');
    await tapKey(tester, const Key('onboardingSkipName'));
    await pumpFrames(tester);
    expect(Get.find<SettingsRepository>().current.childName, isNull);
    expect(find.byKey(const Key('homeReminder')), findsOneWidget);
  });

  testWidgets('gentle reminder plays a personalised message and stop ends it', (tester) async {
    await launch(tester);
    await tapKey(tester, const Key('homeReminder'));
    await pumpFrames(tester);
    await tapKey(tester, const Key('situation_tidy'));
    await pumpFrames(tester);

    expect(engine.spoken, isNotEmpty);
    expect(engine.spoken.first, contains('يا سارة'));
    expect(find.textContaining('يا سارة'), findsWidgets);
    expect(find.byKey(const Key('stopButton')), findsOneWidget);

    final stopsBefore = engine.stopCount;
    await tapKey(tester, const Key('stopButton'));
    await pumpFrames(tester);
    expect(engine.stopCount, greaterThan(stopsBefore));
    expect(find.byKey(const Key('situation_tidy')), findsOneWidget);
  });

  testWidgets('choice buttons advance the reminder', (tester) async {
    await launch(tester);
    Get.toNamed(AppRoutes.interaction, arguments: 'share');
    await pumpFrames(tester);
    await tapKey(tester, const Key('nextButton'));
    await pumpFrames(tester);
    expect(find.byKey(const Key('choice_0')), findsOneWidget);
    await tapKey(tester, const Key('choice_1'));
    await pumpFrames(tester);
    expect(find.text(TranslationsKeys.sitShareEnd.tr), findsOneWidget);
    await tapKey(tester, const Key('stopButton'));
    await pumpFrames(tester);
  });

  testWidgets('first pretend call shows the parent explanation', (tester) async {
    await launch(tester, prefs: onboardedPrefs(callIntroSeen: false));
    await tapKey(tester, const Key('homeCall'));
    await pumpFrames(tester);
    expect(find.byKey(const Key('callIntro')), findsOneWidget);
    expect(find.textContaining('ليس مكالمة حقيقية من الشرطة'), findsOneWidget);
    await tapKey(tester, const Key('callIntroAgree'));
    await pumpFrames(tester);
    expect(Get.find<SettingsRepository>().current.callIntroSeen, isTrue);
    expect(find.byKey(const Key('startCall')), findsOneWidget);
  });

  testWidgets('pretend call: end is always visible and stops everything', (tester) async {
    await launch(tester);
    await tapKey(tester, const Key('homeCall'));
    await pumpFrames(tester);
    expect(find.byKey(const Key('callIntro')), findsNothing);
    await tapKey(tester, const Key('startCall'));
    await pumpFrames(tester);

    // Ringing: clearly labelled pretend call, answer + end controls.
    expect(find.byKey(const Key('pretendBadge')), findsOneWidget);
    expect(find.text(TranslationsKeys.callBadge.tr), findsOneWidget);
    expect(find.byKey(const Key('answerButton')), findsOneWidget);
    expect(find.byKey(const Key('endCallButton')), findsOneWidget);

    engine.holdSpeech = true;
    await tapKey(tester, const Key('answerButton'));
    await pumpFrames(tester);
    expect(find.byKey(const Key('muteButton')), findsOneWidget);
    expect(find.byKey(const Key('endCallButton')), findsOneWidget);
    expect(engine.isHoldingSpeech, isTrue);

    final controller = Get.find<PretendCallController>();
    await tapKey(tester, const Key('endCallButton'));
    await pumpFrames(tester);
    expect(engine.isHoldingSpeech, isFalse);
    expect(controller.phase.value, CallPhase.ended);
    expect(find.byKey(const Key('startCall')), findsOneWidget);
  });

  testWidgets('pretend call mute toggles voice off', (tester) async {
    await launch(tester);
    Get.toNamed(AppRoutes.call, arguments: 'kind');
    await pumpFrames(tester);
    await tapKey(tester, const Key('answerButton'));
    await pumpFrames(tester, frames: 2);
    await tapKey(tester, const Key('muteButton'));
    await pumpFrames(tester, frames: 2);
    expect(find.text(TranslationsKeys.callUnmute.tr), findsOneWidget);
    await tapKey(tester, const Key('endCallButton'));
    await pumpFrames(tester);
  });

  testWidgets('parent gate blocks settings on a wrong answer', (tester) async {
    ParentGateChallenge.debugFixed = ParentGateChallenge(4, 6);
    await launch(tester);
    await tapKey(tester, const Key('homeSettings'));
    await pumpFrames(tester);
    expect(find.byKey(const Key('parentGate')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('parentGateInput')), '10');
    await tapKey(tester, const Key('parentGateConfirm'));
    await pumpFrames(tester);
    expect(find.text(TranslationsKeys.gateWrong.tr), findsOneWidget);
    expect(find.text(TranslationsKeys.settingsTitle.tr), findsNothing);

    await tester.enterText(find.byKey(const Key('parentGateInput')), '24');
    await tapKey(tester, const Key('parentGateConfirm'));
    await pumpFrames(tester);
    expect(find.text(TranslationsKeys.settingsTitle.tr), findsOneWidget);
  });

  testWidgets('parent can edit and clear the child name in settings', (tester) async {
    await launch(tester);
    Get.toNamed(AppRoutes.settings);
    await pumpFrames(tester);
    await tester.enterText(find.byKey(const Key('settingsName')), 'يوسف');
    await tapKey(tester, const Key('saveName'));
    await pumpFrames(tester);
    expect(Get.find<SettingsRepository>().current.childName, 'يوسف');

    await tapKey(tester, const Key('clearName'));
    await pumpFrames(tester, frames: 40); // let the toast finish
    expect(Get.find<SettingsRepository>().current.childName, isNull);
  });

  testWidgets('quiet mode switch silences Captain Sami', (tester) async {
    await launch(tester);
    Get.toNamed(AppRoutes.settings);
    await pumpFrames(tester);
    await tapKey(tester, const Key('quietSwitch'));
    await pumpFrames(tester);
    expect(Get.find<SettingsRepository>().current.quietMode, isTrue);

    final before = engine.spoken.length;
    Get.toNamed(AppRoutes.interaction, arguments: 'gentle');
    await pumpFrames(tester);
    expect(engine.spoken.length, before);
    expect(find.text(TranslationsKeys.voiceOffNote.tr), findsOneWidget);
    await tapKey(tester, const Key('stopButton'));
    await pumpFrames(tester);
  });

  testWidgets('praise flow awards a badge and grows the garden', (tester) async {
    await launch(tester);
    await tapKey(tester, const Key('homePraise'));
    await pumpFrames(tester);
    await tapKey(tester, const Key('behavior_share'));
    await tapKey(tester, const Key('reward_dance'));
    await pumpFrames(tester, frames: 2);
    await tapKey(tester, const Key('celebrateNow'));
    await pumpFrames(tester);

    expect(find.byKey(const Key('newBadge')), findsOneWidget);
    expect(find.text(TranslationsKeys.celebDance.tr), findsOneWidget);
    expect(engine.spoken.last, contains('يا سارة'));
    expect(Get.find<ProgressRepository>().progress.value.flowers, 1);

    await tapKey(tester, const Key('backHome'));
    await pumpFrames(tester, frames: 30);
    expect(find.byKey(const Key('homeReminder')), findsOneWidget);

    await tapKey(tester, const Key('homeProgress'));
    await pumpFrames(tester);
    expect(find.text(TranslationsKeys.progressFlowers.trParams({'count': '1'})), findsOneWidget);
  });

  testWidgets('home adapts to a tablet width without overflow', (tester) async {
    await launch(tester);
    await tester.binding.setSurfaceSize(const Size(1024, 1366));
    await pumpFrames(tester, frames: 3);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('homePraise')), findsOneWidget);
    await tester.binding.setSurfaceSize(const Size(320, 640));
    await pumpFrames(tester, frames: 3);
    expect(tester.takeException(), isNull);
  });
}
