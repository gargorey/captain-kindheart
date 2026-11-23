import 'package:get/get.dart';

import '../../services/storage_service.dart';
import '../mock/mock_content.dart';
import '../models/behavior.dart';
import '../models/call_script.dart';
import '../models/situation.dart';

/// Serves the content library and the parent's custom wording.
class ContentRepository extends GetxService {
  ContentRepository(this._storage) {
    final json = _storage.readJson(storageKey);
    if (json != null) {
      overrides.assignAll(
        json.map((k, v) => MapEntry(k, SituationOverride.fromJson(Map<String, dynamic>.from(v as Map)))),
      );
    }
  }

  static const String storageKey = 'situation_overrides_v1';

  final StorageService _storage;
  final RxMap<String, SituationOverride> overrides = <String, SituationOverride>{}.obs;

  List<Situation> get situations => MockContent.situations;
  List<CallScript> get callScripts => MockContent.callScripts;
  List<Behavior> get behaviors => MockContent.behaviors;
  List<RewardOption> get rewards => MockContent.rewards;

  Situation situation(String id) => situations.firstWhere((s) => s.id == id);
  CallScript callScript(String id) => callScripts.firstWhere((s) => s.id == id);
  Behavior behavior(String id) => behaviors.firstWhere((b) => b.id == id);
  RewardOption? reward(String? id) => id == null ? null : rewards.firstWhereOrNull((r) => r.id == id);

  bool isCustomized(String situationId) => overrides[situationId]?.isEmpty == false;

  String title(Situation s) {
    final custom = overrides[s.id]?.title?.trim();
    return (custom != null && custom.isNotEmpty) ? custom : s.titleKey.tr;
  }

  /// The main instruction line, using the parent's wording when provided.
  String mainMessage(Situation s) {
    final custom = overrides[s.id]?.message?.trim();
    return (custom != null && custom.isNotEmpty) ? custom : s.steps.first.textKey.tr;
  }

  Future<void> saveOverride(String situationId, SituationOverride value) async {
    if (value.isEmpty) {
      overrides.remove(situationId);
    } else {
      overrides[situationId] = value;
    }
    await _persist();
  }

  Future<void> restoreDefault(String situationId) async {
    overrides.remove(situationId);
    await _persist();
  }

  Future<void> reset() async {
    overrides.clear();
    await _storage.remove(storageKey);
  }

  Future<void> _persist() => _storage.writeJson(storageKey, overrides.map((k, v) => MapEntry(k, v.toJson())));
}
