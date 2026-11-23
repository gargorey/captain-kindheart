import 'package:get/get.dart';

import 'ar_translations.dart';

/// GetX translations. Release 1 ships Arabic only; add a new map here to
/// introduce another language later.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'ar': arTranslations};
}
