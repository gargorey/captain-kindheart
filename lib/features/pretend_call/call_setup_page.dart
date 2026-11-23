import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../widgets/kind_card.dart';
import '../../widgets/page_shell.dart';

/// Parent picks a supportive script, then starts the pretend call.
class CallSetupPage extends StatefulWidget {
  const CallSetupPage({super.key});

  @override
  State<CallSetupPage> createState() => _CallSetupPageState();
}

class _CallSetupPageState extends State<CallSetupPage> {
  final _content = Get.find<ContentRepository>();
  final _settings = Get.find<SettingsRepository>();
  late String _selected = _content.callScripts.first.id;

  @override
  void initState() {
    super.initState();
    if (!_settings.current.callIntroSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showIntro());
    }
  }

  Future<void> _showIntro() async {
    await Get.dialog<void>(const _CallIntroDialog(), barrierDismissible: false);
    await _settings.update((s) => s.copyWith(callIntroSeen: true));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PageShell(
      title: TranslationsKeys.callSetupTitle.tr,
      bottom: FilledButton.icon(
        key: const Key('startCall'),
        onPressed: () => Get.toNamed(AppRoutes.call, arguments: _selected),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(TranslationsKeys.callStart.tr),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_rounded, color: AppColors.tealDeep),
                const SizedBox(width: 10),
                Expanded(child: Text(TranslationsKeys.callParentNote.tr, style: text.bodyMedium)),
                TextButton(onPressed: _showIntro, child: Text(TranslationsKeys.callIntroTitle.tr)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(TranslationsKeys.callChooseScript.tr, style: text.titleMedium),
          const SizedBox(height: 10),
          for (final s in _content.callScripts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: KindCard(
                key: Key('script_${s.id}'),
                title: s.titleKey.tr,
                subtitle: _settings.personalizer.apply(s.lineKeys[1].tr),
                icon: s.icon,
                color: AppColors.teal,
                selected: _selected == s.id,
                onTap: () => setState(() => _selected = s.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _CallIntroDialog extends StatelessWidget {
  const _CallIntroDialog();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      key: const Key('callIntro'),
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(TranslationsKeys.callIntroTitle.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(TranslationsKeys.callIntroBody.tr, style: text.bodyLarge),
            const SizedBox(height: 10),
            Text(TranslationsKeys.callIntroTip.tr, style: text.bodyMedium),
          ],
        ),
      ),
      actions: [
        FilledButton(
          key: const Key('callIntroAgree'),
          onPressed: () => Get.back(),
          child: Text(TranslationsKeys.callIntroAgree.tr),
        ),
      ],
    );
  }
}
