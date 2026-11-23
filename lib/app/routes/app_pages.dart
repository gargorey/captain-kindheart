import 'package:get/get.dart';

import '../../features/home/home_page.dart';
import '../../features/onboarding/onboarding_controller.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/praise/celebration_controller.dart';
import '../../features/praise/celebration_page.dart';
import '../../features/praise/praise_setup_controller.dart';
import '../../features/praise/praise_setup_page.dart';
import '../../features/pretend_call/call_setup_page.dart';
import '../../features/pretend_call/pretend_call_controller.dart';
import '../../features/pretend_call/pretend_call_page.dart';
import '../../features/progress/progress_page.dart';
import '../../features/reminder/interaction_controller.dart';
import '../../features/reminder/interaction_page.dart';
import '../../features/reminder/situation_picker_page.dart';
import '../../features/settings/privacy_page.dart';
import '../../features/settings/script_editor_page.dart';
import '../../features/settings/settings_controller.dart';
import '../../features/settings/settings_page.dart';
import '../../features/splash/splash_page.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => OnboardingController(Get.find()))),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(name: AppRoutes.situations, page: () => const SituationPickerPage()),
    GetPage(
      name: AppRoutes.interaction,
      page: () => const InteractionPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => InteractionController(
            situationId: Get.arguments as String,
            content: Get.find(),
            settings: Get.find(),
            audio: Get.find(),
          ),
        ),
      ),
    ),
    GetPage(name: AppRoutes.callSetup, page: () => const CallSetupPage()),
    GetPage(
      name: AppRoutes.call,
      page: () => const PretendCallPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => PretendCallController(
            scriptId: Get.arguments as String,
            content: Get.find(),
            settings: Get.find(),
            audio: Get.find(),
          ),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.praise,
      page: () => const PraiseSetupPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => PraiseSetupController(initialBehaviorId: Get.arguments as String?)),
      ),
    ),
    GetPage(
      name: AppRoutes.celebration,
      page: () => const CelebrationPage(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, String?>;
        Get.lazyPut(
          () => CelebrationController(
            behaviorId: args['behaviorId']!,
            rewardId: args['rewardId'],
            content: Get.find(),
            settings: Get.find(),
            progress: Get.find(),
            audio: Get.find(),
          ),
        );
      }),
    ),
    GetPage(name: AppRoutes.progress, page: () => const ProgressPage()),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => SettingsController(settings: Get.find(), progress: Get.find(), content: Get.find(), audio: Get.find()),
        ),
      ),
    ),
    GetPage(name: AppRoutes.scripts, page: () => const ScriptEditorPage()),
    GetPage(name: AppRoutes.privacy, page: () => const PrivacyPage()),
  ];
}
