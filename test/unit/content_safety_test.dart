import 'dart:io';

import 'package:captain_kindheart/core/translations/ar_translations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the product's safety promises in code review and CI.
void main() {
  // Everything Captain Sami says to the child.
  bool isChildFacing(String key) =>
      RegExp(r'^(sit|cs|pr|cheer|choiceAck|sessionGoodbye|voiceTestLine)').hasMatch(key) && !key.endsWith('Title');

  const forbidden = [
    'شرطة',
    'شرطي',
    'بوليس',
    'اعتقال',
    'يعتقل',
    'سجن',
    'عقاب',
    'يعاقب',
    'عقوبة',
    'يأخذك',
    'ياخذك',
    'نأخذك',
    'بعيدًا عن',
    'طوارئ',
    'سيأتي',
    'جاي ياخذ',
    'ولد سيئ',
    'بنت سيئة',
    'سيئ',
    'شقي',
    'عيب عليك',
    'غبي',
  ];

  test('child-facing dialogue never threatens, shames, or mentions police', () {
    final childLines = arTranslations.entries.where((e) => isChildFacing(e.key)).toList();
    expect(childLines.length, greaterThan(40));
    for (final e in childLines) {
      for (final word in forbidden) {
        expect(e.value.contains(word), isFalse, reason: '${e.key} contains "$word"');
      }
    }
  });

  test('the pretend-call intro tells parents it is not a real police call', () {
    expect(arTranslations['callIntroBody'], contains('ليس مكالمة حقيقية من الشرطة'));
    expect(arTranslations['callBadge'], contains('تخيّلية'));
  });

  test('no telephony, SMS, or URL-launching code or packages', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final pkg in [
      'url_launcher',
      'telephony',
      'flutter_phone_direct_caller',
      'sms',
      'android_intent',
      'flutter_sms',
    ]) {
      expect(pubspec.contains(pkg), isFalse, reason: 'pubspec depends on $pkg');
    }
    final sources = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (final f in sources) {
      final code = f.readAsStringSync();
      for (final pattern in ['tel:', 'sms:', 'launchUrl', 'mailto:']) {
        expect(code.contains(pattern), isFalse, reason: '${f.path} contains "$pattern"');
      }
      // No emergency numbers as string literals (911, 999, 112, 997, 998).
      expect(RegExp(r'''['"](911|999|112|997|998)['"]''').hasMatch(code), isFalse, reason: f.path);
    }
  });

  test('Android manifest requests no phone or SMS permissions', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    for (final p in ['CALL_PHONE', 'SEND_SMS', 'READ_PHONE_STATE', 'READ_CONTACTS']) {
      expect(manifest.contains(p), isFalse);
    }
  });

  test('every TranslationsKeys constant has an Arabic string', () {
    final src = File('lib/core/translations/translations_keys.dart').readAsStringSync();
    final keys = RegExp(r"static const String (\w+) = '(\w+)';").allMatches(src).map((m) => m.group(2)!).toSet();
    expect(keys, isNotEmpty);
    expect(keys.difference(arTranslations.keys.toSet()), isEmpty);
    expect(arTranslations.values.where((v) => v.trim().isEmpty), isEmpty);
  });
}
