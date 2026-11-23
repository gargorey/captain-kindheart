import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/models/situation.dart';
import '../../data/repositories/content_repository.dart';
import '../../widgets/kind_card.dart';
import '../../widgets/page_shell.dart';

/// Lists situations so parents can personalise Captain Sami's wording.
/// Reached from settings, which is already behind the parent gate.
class ScriptEditorPage extends StatelessWidget {
  const ScriptEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = Get.find<ContentRepository>();
    return PageShell(
      title: TranslationsKeys.scriptsTitle.tr,
      child: Obx(() {
        content.overrides.length;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(TranslationsKeys.messageHint.tr, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            for (final s in content.situations)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: KindCard(
                  title: content.title(s),
                  subtitle: content.isCustomized(s.id) ? TranslationsKeys.customBadge.tr : null,
                  icon: s.icon,
                  color: s.color,
                  trailing: const Icon(Icons.edit_rounded, color: AppColors.inkSoft),
                  onTap: () => Get.to(() => SituationEditorPage(situationId: s.id)),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class SituationEditorPage extends StatefulWidget {
  const SituationEditorPage({super.key, required this.situationId});

  final String situationId;

  @override
  State<SituationEditorPage> createState() => _SituationEditorPageState();
}

class _SituationEditorPageState extends State<SituationEditorPage> {
  final _content = Get.find<ContentRepository>();
  late final Situation _situation = _content.situation(widget.situationId);
  late final _title = TextEditingController(text: _content.title(_situation));
  late final _message = TextEditingController(text: _content.mainMessage(_situation));

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  String? _diff(String value, String original) {
    final v = value.trim();
    return (v.isEmpty || v == original) ? null : v;
  }

  Future<void> _save() async {
    await _content.saveOverride(
      _situation.id,
      SituationOverride(
        title: _diff(_title.text, _situation.titleKey.tr),
        message: _diff(_message.text, _situation.steps.first.textKey.tr),
      ),
    );
    Get.back();
    Get.rawSnackbar(
      message: TranslationsKeys.savedToast.tr,
      backgroundColor: AppColors.tealDeep,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> _restore() async {
    await _content.restoreDefault(_situation.id);
    setState(() {
      _title.text = _situation.titleKey.tr;
      _message.text = _situation.steps.first.textKey.tr;
    });
    Get.rawSnackbar(
      message: TranslationsKeys.restoredToast.tr,
      backgroundColor: AppColors.tealDeep,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PageShell(
      title: TranslationsKeys.editSituation.tr,
      bottom: Row(
        children: [
          Expanded(
            child: OutlinedButton(onPressed: _restore, child: Text(TranslationsKeys.btnRestore.tr)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              key: const Key('saveSituation'),
              onPressed: _save,
              child: Text(TranslationsKeys.btnSave.tr),
            ),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(TranslationsKeys.fieldTitle.tr, style: text.labelLarge),
          const SizedBox(height: 6),
          TextField(key: const Key('situationTitle'), controller: _title, maxLength: 40),
          const SizedBox(height: 8),
          Text(TranslationsKeys.fieldMessage.tr, style: text.labelLarge),
          const SizedBox(height: 6),
          TextField(key: const Key('situationMessage'), controller: _message, maxLines: 5, maxLength: 240),
          Text(TranslationsKeys.messageHint.tr, style: text.bodySmall),
        ],
      ),
    );
  }
}
