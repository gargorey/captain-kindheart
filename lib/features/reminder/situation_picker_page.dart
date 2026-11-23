import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../../data/repositories/content_repository.dart';
import '../../widgets/page_shell.dart';
import '../parent_gate/parent_gate.dart';
import '../settings/script_editor_page.dart';

class SituationPickerPage extends StatelessWidget {
  const SituationPickerPage({super.key});

  Future<void> _edit(String id) async {
    if (await showParentGate()) await Get.to(() => SituationEditorPage(situationId: id));
  }

  @override
  Widget build(BuildContext context) {
    final content = Get.find<ContentRepository>();
    final text = Theme.of(context).textTheme;
    return PageShell(
      title: TranslationsKeys.pickerTitle.tr,
      child: LayoutBuilder(
        builder: (context, box) {
          final columns = box.maxWidth > 520 ? 3 : 2;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                sliver: SliverToBoxAdapter(child: Text(TranslationsKeys.pickerHint.tr, style: text.bodyMedium)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: Obx(() {
                  content.overrides.length; // react to edits
                  return SliverGrid.count(
                    crossAxisCount: columns,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.95,
                    children: [
                      for (final s in content.situations)
                        _SituationTile(
                          key: Key('situation_${s.id}'),
                          title: content.title(s),
                          icon: s.icon,
                          color: s.color,
                          customized: content.isCustomized(s.id),
                          onTap: () => Get.toNamed(AppRoutes.interaction, arguments: s.id),
                          onEdit: () => _edit(s.id),
                        ),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SituationTile extends StatelessWidget {
  const _SituationTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.customized,
    required this.onTap,
    required this.onEdit,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool customized;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (customized)
                    Text(
                      TranslationsKeys.customBadge.tr,
                      style: const TextStyle(color: AppColors.tealDeep, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 4,
              end: 4,
              child: IconButton(
                tooltip: TranslationsKeys.btnEdit.tr,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 20, color: AppColors.inkSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
