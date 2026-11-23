# Original asset checklist

Everything visual in release 1 is generated in code so the demo runs with no external artwork. Items marked **Placeholder** should be replaced by commissioned, original art before store release.

| Asset | Status | Where | Notes for the artist |
| --- | --- | --- | --- |
| Captain Sami character (idle, talking, happy, dancing) | **Placeholder** (CustomPainter) | `lib/widgets/captain_sami.dart` | Original warm helper. Teal shirt, sky-blue cap with a heart, yellow heart emblem. No badge, shield, star-badge, handcuffs, police hat, or official insignia. Calm expressive face; slow blinks; mouth movement for talking. Rive or Lottie recommended; keep the `CaptainSami(mood:)` API. |
| App icon | **Placeholder** (Flutter default) | `android/app/src/main/res/mipmap-*`, `ios/Runner/Assets.xcassets` | Sami's face with heart cap on a sky-blue background. |
| Splash artwork | **Placeholder** (Sami + app name) | `features/splash` | Optional illustrated background. |
| Situation illustrations (6) | **Placeholder** (Material icons in coloured circles) | `data/mock/mock_content.dart` | Toys going home, gentle hands, soft voice, sharing, listening ears, moon/bedtime. |
| Behaviour and badge art (9) | **Placeholder** (Material icons) | `mock_content.dart`, `progress_page.dart` | Collectible, round, friendly. No medals implying ranking. |
| Garden flowers | **Placeholder** (Material icon) | `progress_page.dart` | Several flower types that grow over time. |
| Confetti and stars | Final (code) | `widgets/confetti.dart` | Respects reduced motion. |
| Call card frame | Final (code) | `pretend_call_page.dart` | Must stay obviously cartoon, never phone-OS-like. |
| Soft sound effects (chime, sparkle) | **Not included** | — | Gentle, quiet, short. No sirens or alarms. Add via `AudioService`. |
| Recorded Captain Sami voice lines | **Not included** (device TTS used) | — | Warm adult voice, Gulf/Levantine-neutral Arabic. Record every `sit*`, `cs*`, `pr*`, `cheer*` key, plus name-free variants. |
| Font | Final | `assets/fonts/Cairo-Variable.ttf` (SIL OFL, licence alongside) | — |
