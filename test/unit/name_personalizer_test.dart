import 'package:captain_kindheart/core/utils/name_personalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NamePersonalizer', () {
    test('uses the saved name as a vocative', () {
      const p = NamePersonalizer(childName: 'سارة', fallbackPhrase: 'يا بطل');
      expect(p.apply('أحسنت @name!'), 'أحسنت يا سارة!');
    });

    test('falls back to the parent-chosen phrase when blank or skipped', () {
      const blank = NamePersonalizer(childName: '   ', fallbackPhrase: 'يا نجم البيت');
      const none = NamePersonalizer(childName: null, fallbackPhrase: 'يا شطّورة');
      expect(blank.apply('مرحبًا @name!'), 'مرحبًا يا نجم البيت!');
      expect(none.apply('مرحبًا @name!'), 'مرحبًا يا شطّورة!');
    });

    test('replaces the parent-friendly {الاسم} token in custom wording', () {
      const p = NamePersonalizer(childName: 'عبدالله', fallbackPhrase: 'يا بطل');
      expect(p.apply('{الاسم}، يلا نرتّب'), 'يا عبدالله، يلا نرتّب');
    });

    test('trims surrounding spaces from names', () {
      const p = NamePersonalizer(childName: ' لين ', fallbackPhrase: 'يا بطل');
      expect(p.vocative, 'يا لين');
    });
  });
}
