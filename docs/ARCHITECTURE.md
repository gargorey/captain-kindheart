# Architecture

Feature-first Flutter app using **GetX** for routing, dependency injection, translations, and reactive state.

```
lib/
├── main.dart                     # boots services, runs the app
├── app/
│   ├── app.dart                  # GetMaterialApp: Arabic locale, forced RTL, theme, text-scale clamp
│   ├── bootstrap.dart            # registers storage, repositories, AudioService (injectable for tests)
│   ├── routes/                   # AppRoutes names + AppPages (GetPage + bindings per screen)
│   └── theme/                    # AppColors palette, AppTheme (Cairo font)
├── core/
│   ├── translations/             # TranslationsKeys, ar_translations.dart, AppTranslations
│   └── utils/                    # NamePersonalizer, SessionTimerMixin
├── data/
│   ├── models/                   # Situation, CallScript, Behavior, RewardOption, AppSettings, ProgressState
│   ├── mock/mock_content.dart    # demo content library (keys only, no literal strings)
│   └── repositories/             # Settings, Content (incl. parent overrides), Progress
├── services/
│   ├── storage_service.dart      # local JSON key-value store (shared_preferences)
│   └── audio/                    # SpeechEngine interface, FlutterTtsEngine, AudioService
├── features/
│   ├── splash/ onboarding/ home/
│   ├── reminder/                 # situation picker, InteractionController + page
│   ├── pretend_call/             # setup + intro dialog, PretendCallController + page
│   ├── praise/                   # praise setup, CelebrationController + page
│   ├── progress/                 # achievement garden
│   ├── settings/                 # settings, script editor, privacy
│   └── parent_gate/              # ParentGateChallenge + dialog
└── widgets/                      # CaptainSami (CustomPainter), SpeechBubble, StopButton, KindCard, Confetti, PageShell, SectionCard
```

## Layers

- **UI** (`features/*_page.dart`, `widgets/`): stateless where possible, read state with `Obx`. No content strings or data are hard-coded in widgets; everything comes from `TranslationsKeys` and repositories.
- **State** (`*_controller.dart`): one GetX controller per interactive screen, created by route bindings and disposed with the route. Reactive fields only where the UI must update.
- **Data** (`data/`): plain models with JSON, repositories as `GetxService`s exposing `Rx` state and persisting through `StorageService`.
- **Services**: `AudioService` is the single gate for speech. It checks voice enabled / quiet mode / mute / availability, and `stop()` completes any pending speech future immediately, so callers never hang.

## Safety-critical paths

- `AudioService.stop()` → called by every stop/end button, on route pop (`PopScope`), and in every controller's `onClose`.
- `PretendCallController.end()` bumps a generation counter, cancels line and session timers, sets `ended`, stops audio. Late callbacks from earlier lines check the generation and do nothing.
- `SessionTimerMixin` ends reminders and calls after the parent-set session length.

## Strings

All user-facing text lives in `core/translations/`. `TranslationsKeys.someKey.tr` everywhere; parameters with `trParams` (`@count`, `@reward`). Character dialogue uses the `@name` token, resolved by `NamePersonalizer`. To add a language later, add another map in `AppTranslations` and expose a picker. Release 1 deliberately has none.

## Material and GetX on Flutter 3.50

Flutter 3.47+ moved Material into the `material_ui` package and deprecated `package:flutter/material.dart`. GetX 4.7.x still builds on the old import, so this app uses `package:flutter/material.dart` too, keeping widget types identical. The deprecation lint is silenced in `analysis_options.yaml`. Migrate both together once GetX supports `material_ui`.
