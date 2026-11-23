import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../core/translations/app_translations.dart';
import '../core/translations/translations_keys.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class CaptainKindheartApp extends StatelessWidget {
  const CaptainKindheartApp({super.key, this.initialRoute = AppRoutes.splash});

  final String initialRoute;

  static const Locale arabic = Locale('ar');

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onGenerateTitle: (_) => TranslationsKeys.appName.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      translations: AppTranslations(),
      locale: arabic,
      fallbackLocale: arabic,
      supportedLocales: const [arabic],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 280),
      builder: (context, child) {
        // Respect the user's text size, within a range our layouts support.
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.6)),
          child: Directionality(textDirection: TextDirection.rtl, child: child!),
        );
      },
    );
  }
}
