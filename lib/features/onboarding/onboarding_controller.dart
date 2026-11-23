import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/repositories/settings_repository.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._settings);

  static const int pageCount = 4;

  final SettingsRepository _settings;
  final PageController pageController = PageController();
  final TextEditingController nameController = TextEditingController();
  final RxInt page = 0.obs;
  late final RxString fallbackKey = _settings.current.fallbackPhraseKey.obs;

  bool get isLast => page.value == pageCount - 1;

  void onPageChanged(int i) => page.value = i;

  void next() {
    if (isLast) return;
    pageController.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  void back() {
    if (page.value == 0) return;
    pageController.previousPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  /// Saves the (optional) name and finishes setup. [skipName] ignores
  /// anything typed.
  Future<void> finish({bool skipName = false}) async {
    final name = skipName ? null : nameController.text;
    await _settings.setChildName(name);
    await _settings.update((s) => s.copyWith(onboarded: true, fallbackPhraseKey: fallbackKey.value));
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    pageController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
