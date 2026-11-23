import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/mock/mock_content.dart';
import '../../data/models/app_settings.dart';
import '../../widgets/page_shell.dart';
import '../../widgets/section_card.dart';
import 'settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  static const _ageKeys = {
    AgeRange.age3to4: TranslationsKeys.age34,
    AgeRange.age5to6: TranslationsKeys.age56,
    AgeRange.age7to8: TranslationsKeys.age78,
  };
  static const _voiceKeys = {
    VoiceStyle.calm: TranslationsKeys.voiceCalm,
    VoiceStyle.warm: TranslationsKeys.voiceWarm,
    VoiceStyle.cheerful: TranslationsKeys.voiceCheerful,
  };

  void _toast(String key) {
    Get.closeCurrentSnackbar();
    Get.rawSnackbar(
      messageText: Text(
        key.tr,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      backgroundColor: AppColors.tealDeep,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  Future<bool> _confirm() async =>
      await Get.dialog<bool>(
        AlertDialog(
          title: Text(TranslationsKeys.resetConfirmTitle.tr),
          content: Text(TranslationsKeys.resetConfirmBody.tr),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: Text(TranslationsKeys.btnCancel.tr)),
            FilledButton(
              key: const Key('confirmReset'),
              onPressed: () => Get.back(result: true),
              child: Text(TranslationsKeys.btnConfirm.tr),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PageShell(
      title: TranslationsKeys.settingsTitle.tr,
      child: Obx(() {
        final s = controller.settings.value;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            SectionCard(
              title: TranslationsKeys.secProfile.tr,
              children: [
                Text(TranslationsKeys.fieldNickname.tr, style: text.labelLarge),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('settingsName'),
                  controller: controller.nameController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: TranslationsKeys.onbNameHint.tr,
                    counterText: '',
                    fillColor: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        key: const Key('saveName'),
                        onPressed: () async {
                          await controller.saveName();
                          _toast(TranslationsKeys.nicknameSaved);
                        },
                        child: Text(TranslationsKeys.btnSave.tr),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('clearName'),
                        onPressed: () async {
                          await controller.clearName();
                          _toast(TranslationsKeys.nicknameCleared);
                        },
                        child: Text(TranslationsKeys.btnClear.tr),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(TranslationsKeys.fieldFallback.tr, style: text.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final k in MockContent.fallbackPhraseKeys)
                      ChoiceChip(
                        label: Text(k.tr),
                        selected: s.fallbackPhraseKey == k,
                        selectedColor: AppColors.teal.withValues(alpha: 0.2),
                        onSelected: (_) => controller.setFallback(k),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(TranslationsKeys.fieldAge.tr, style: text.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in _ageKeys.entries)
                      ChoiceChip(
                        label: Text(e.value.tr),
                        selected: s.ageRange == e.key,
                        selectedColor: AppColors.teal.withValues(alpha: 0.2),
                        onSelected: (_) => controller.setAge(e.key),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(TranslationsKeys.fieldAvatar.tr, style: text.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final e in MockContent.avatars.entries)
                      GestureDetector(
                        onTap: () => controller.setAvatar(e.key),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: s.avatarId == e.key ? AppColors.teal : AppColors.cream,
                          child: Icon(e.value, color: s.avatarId == e.key ? Colors.white : AppColors.inkSoft),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(TranslationsKeys.fieldLanguage.tr, style: text.labelLarge),
                  trailing: Text(TranslationsKeys.onbLanguageArabic.tr, style: text.bodyLarge),
                ),
              ],
            ),
            SectionCard(
              title: TranslationsKeys.secVoice.tr,
              children: [
                SwitchListTile(
                  key: const Key('voiceSwitch'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(TranslationsKeys.voiceEnabled.tr),
                  value: s.voiceEnabled,
                  onChanged: controller.setVoiceEnabled,
                ),
                Text(TranslationsKeys.voiceStyle.tr, style: text.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in _voiceKeys.entries)
                      ChoiceChip(
                        label: Text(e.value.tr),
                        selected: s.voiceStyle == e.key,
                        selectedColor: AppColors.teal.withValues(alpha: 0.2),
                        onSelected: s.voiceEnabled ? (_) => controller.setVoiceStyle(e.key) : null,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(TranslationsKeys.volume.tr, style: text.labelLarge),
                Slider(
                  value: s.volume,
                  onChanged: s.voiceEnabled ? controller.setVolume : null,
                  divisions: 10,
                  label: '${(s.volume * 100).round()}%',
                ),
                OutlinedButton.icon(
                  onPressed: s.voiceActive ? controller.testVoice : null,
                  icon: const Icon(Icons.record_voice_over_rounded),
                  label: Text(TranslationsKeys.voiceTest.tr),
                ),
              ],
            ),
            SectionCard(
              title: TranslationsKeys.secUsage.tr,
              children: [
                SwitchListTile(
                  key: const Key('quietSwitch'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(TranslationsKeys.quietMode.tr),
                  subtitle: Text(TranslationsKeys.quietModeDesc.tr),
                  value: s.quietMode,
                  onChanged: controller.setQuietMode,
                ),
                const SizedBox(height: 6),
                Text(TranslationsKeys.sessionLength.tr, style: text.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in AppSettings.sessionOptions)
                      ChoiceChip(
                        label: Text(TranslationsKeys.minutesLabel.trParams({'count': '$m'})),
                        selected: s.sessionMinutes == m,
                        selectedColor: AppColors.teal.withValues(alpha: 0.2),
                        onSelected: (_) => controller.setSessionMinutes(m),
                      ),
                  ],
                ),
              ],
            ),
            SectionCard(
              title: TranslationsKeys.secContent.tr,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_note_rounded, color: AppColors.teal),
                  title: Text(TranslationsKeys.editScripts.tr),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => Get.toNamed(AppRoutes.scripts),
                ),
              ],
            ),
            SectionCard(
              title: TranslationsKeys.secPrivacy.tr,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_rounded, color: AppColors.teal),
                  title: Text(TranslationsKeys.privacyOpen.tr),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => Get.toNamed(AppRoutes.privacy),
                ),
              ],
            ),
            SectionCard(
              title: TranslationsKeys.secReset.tr,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    if (await _confirm()) {
                      await controller.resetProgress();
                      _toast(TranslationsKeys.resetDone);
                    }
                  },
                  child: Text(TranslationsKeys.resetProgress.tr),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  key: const Key('resetAll'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.tealDeep),
                  onPressed: () async {
                    if (await _confirm()) {
                      await controller.resetAll();
                      Get.offAllNamed(AppRoutes.onboarding);
                    }
                  },
                  child: Text(TranslationsKeys.resetAll.tr),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
