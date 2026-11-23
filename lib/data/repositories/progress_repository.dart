import 'package:get/get.dart';

import '../../services/storage_service.dart';
import '../models/progress.dart';

/// Records positive moments only. No negative scores, no streaks to lose.
class ProgressRepository extends GetxService {
  ProgressRepository(this._storage) {
    final json = _storage.readJson(storageKey);
    if (json != null) progress.value = ProgressState.fromJson(json);
  }

  static const String storageKey = 'progress_v1';
  static const int maxStoredMoments = 200;

  final StorageService _storage;
  final Rx<ProgressState> progress = const ProgressState().obs;

  /// Adds a moment and returns `true` if this earned a new badge.
  Future<bool> addMoment(String behaviorId, {String? rewardId, DateTime? at}) async {
    final current = progress.value;
    final moment = PositiveMoment(behaviorId: behaviorId, rewardId: rewardId, at: at ?? DateTime.now());
    final moments = [moment, ...current.moments].take(maxStoredMoments).toList();
    final isNewBadge = !current.badges.contains(behaviorId);
    progress.value = current.copyWith(moments: moments, badges: {...current.badges, behaviorId});
    await _storage.writeJson(storageKey, progress.value.toJson());
    return isNewBadge;
  }

  Future<void> reset() async {
    progress.value = const ProgressState();
    await _storage.remove(storageKey);
  }
}
