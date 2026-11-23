// Renders marketing/review screenshots with the real Cairo font.
// Run: flutter test screenshots_test --update-goldens
// Output: docs/screenshots/*.png
import 'dart:io';

import 'package:captain_kindheart/app/app.dart';
import 'package:captain_kindheart/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../test/helpers/fakes.dart';

Future<void> _loadFonts() async {
  final cairo = FontLoader('Cairo')..addFont(rootBundle.load('assets/fonts/Cairo-Variable.ttf'));
  await cairo.load();
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  final icons = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf').readAsBytesSync();
  final iconLoader = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.view(icons.buffer)));
  await iconLoader.load();
}

void main() {
  const size = Size(390, 844);

  Future<void> shot(
    WidgetTester tester,
    String name,
    String route, {
    Object? args,
    Map<String, Object>? prefs,
    Future<void> Function()? before,
  }) async {
    await tester.runAsync(() async {
      await setUpApp(prefs: prefs ?? onboardedPrefs());
      await _loadFonts();
    });
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    await tester.pumpWidget(const CaptainKindheartApp(initialRoute: AppRoutes.home));
    await pumpFrames(tester);
    if (route != AppRoutes.home) {
      Get.toNamed(route, arguments: args);
      await pumpFrames(tester, frames: 10);
    }
    if (before != null) await before();
    await pumpFrames(tester, frames: 6);
    await expectLater(find.byType(GetMaterialApp), matchesGoldenFile('../docs/screenshots/$name.png'));
  }

  testWidgets('home', (t) => shot(t, '01_home', AppRoutes.home));
  testWidgets('situations', (t) => shot(t, '02_situations', AppRoutes.situations));
  testWidgets('reminder', (t) => shot(t, '03_reminder', AppRoutes.interaction, args: 'tidy'));
  testWidgets('call ringing', (t) => shot(t, '04_call_ringing', AppRoutes.call, args: 'kind'));
  testWidgets(
    'call connected',
    (t) => shot(
      t,
      '05_call_connected',
      AppRoutes.call,
      args: 'kind',
      before: () async {
        await t.tap(find.byKey(const Key('answerButton')));
        await pumpFrames(t, frames: 3);
      },
    ),
  );
  testWidgets(
    'celebration',
    (t) => shot(
      t,
      '06_celebration',
      AppRoutes.celebration,
      args: <String, String?>{'behaviorId': 'share', 'rewardId': 'dance'},
    ),
  );
  testWidgets(
    'garden',
    (t) => shot(
      t,
      '07_garden',
      AppRoutes.progress,
      prefs: {
        ...onboardedPrefs(),
        'flutter.progress_v1':
            '{"moments":[{"behaviorId":"share","rewardId":"dance","at":"2026-11-23T10:00:00"},'
            '{"behaviorId":"tidy","rewardId":null,"at":"2026-11-22T18:00:00"},'
            '{"behaviorId":"teeth","rewardId":"story","at":"2026-11-22T20:00:00"},'
            '{"behaviorId":"tidy","rewardId":"sticker","at":"2026-11-21T17:00:00"}],"badges":["share","tidy","teeth"]}',
      },
    ),
  );
  testWidgets('onboarding', (t) async {
    await t.runAsync(() async {
      await setUpApp(prefs: const {});
      await _loadFonts();
    });
    t.view.physicalSize = size * 3;
    t.view.devicePixelRatio = 3;
    await t.pumpWidget(const CaptainKindheartApp(initialRoute: AppRoutes.onboarding));
    await pumpFrames(t, frames: 10);
    await expectLater(find.byType(GetMaterialApp), matchesGoldenFile('../docs/screenshots/00_onboarding.png'));
  });
}
