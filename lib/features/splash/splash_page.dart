import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/repositories/settings_repository.dart';
import '../../widgets/captain_sami.dart';
import '../../widgets/page_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), () {
      final onboarded = Get.find<SettingsRepository>().current.onboarded;
      Get.offAllNamed(onboarded ? AppRoutes.home : AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PageShell(
      showBack: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CaptainSami(size: 200, mood: SamiMood.happy),
            const SizedBox(height: 16),
            Text(TranslationsKeys.appName.tr, style: text.displaySmall, textAlign: TextAlign.center),
            Text(TranslationsKeys.appTagline.tr, style: text.bodyLarge, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
