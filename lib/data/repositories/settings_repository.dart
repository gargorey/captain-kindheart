import 'package:get/get.dart';

import '../../core/translations/translations_keys.dart';
import '../../core/utils/name_personalizer.dart';
import '../../services/storage_service.dart';
import '../models/app_settings.dart';

class SettingsRepository extends GetxService {
  SettingsRepository(this._storage) {
    final json = _storage.readJson(storageKey);
    if (json != null) settings.value = AppSettings.fromJson(json);
  }

  static const String storageKey = 'settings_v1';

  final StorageService _storage;
  final Rx<AppSettings> settings = const AppSettings().obs;

  AppSettings get current => settings.value;

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    settings.value = change(settings.value);
    await _storage.writeJson(storageKey, settings.value.toJson());
  }

  Future<void> setChildName(String? name) {
    final trimmed = name?.trim() ?? '';
    return update((s) => trimmed.isEmpty ? s.copyWith(clearChildName: true) : s.copyWith(childName: trimmed));
  }

  NamePersonalizer get personalizer =>
      NamePersonalizer(childName: current.childName, fallbackPhrase: _fallback(current.fallbackPhraseKey));

  String _fallback(String key) {
    final value = key.tr;
    // If translations are not loaded (e.g. in a bare unit test) fall back to
    // a safe built-in phrase rather than showing a raw key.
    return value == key ? (key == TranslationsKeys.fbStar ? 'يا نجم البيت' : value) : value;
  }

  Future<void> reset() async {
    settings.value = const AppSettings();
    await _storage.remove(storageKey);
  }
}
