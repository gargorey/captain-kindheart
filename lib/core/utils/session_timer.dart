import 'dart:async';

import 'package:get/get.dart';

/// Ends an interaction gently once the parent-chosen session length passes.
mixin SessionTimerMixin on GetxController {
  Timer? _sessionTimer;

  void startSessionTimer(Duration length, void Function() onExpired) {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(length, onExpired);
  }

  void cancelSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  @override
  void onClose() {
    cancelSessionTimer();
    super.onClose();
  }
}
