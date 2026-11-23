import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

class PraiseSetupController extends GetxController {
  PraiseSetupController({String? initialBehaviorId}) : behaviorId = RxnString(initialBehaviorId);

  final RxnString behaviorId;
  final RxnString rewardId = RxnString();

  bool get canCelebrate => behaviorId.value != null;

  void selectBehavior(String id) => behaviorId.value = id;

  /// Rewards are optional; tapping the selected one clears it.
  void toggleReward(String id) => rewardId.value = rewardId.value == id ? null : id;

  void celebrate() {
    if (!canCelebrate) return;
    Get.offNamed(
      AppRoutes.celebration,
      arguments: <String, String?>{'behaviorId': behaviorId.value, 'rewardId': rewardId.value},
    );
  }
}
