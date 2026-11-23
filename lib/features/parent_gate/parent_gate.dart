import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';

/// A simple multiplication question young children are unlikely to solve.
class ParentGateChallenge {
  ParentGateChallenge(this.a, this.b);

  factory ParentGateChallenge.random([Random? random]) {
    final r = random ?? Random();
    return ParentGateChallenge(3 + r.nextInt(7), 3 + r.nextInt(7));
  }

  /// Tests can pin the challenge to keep widget tests deterministic.
  @visibleForTesting
  static ParentGateChallenge? debugFixed;

  final int a;
  final int b;

  int get answer => a * b;

  bool check(String input) {
    final normalized = _westernDigits(input.trim());
    return int.tryParse(normalized) == answer;
  }

  /// Accept Arabic-Indic digits typed on Arabic keyboards.
  static String _westernDigits(String s) {
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final i = eastern.indexOf(ch);
      b.write(i >= 0 ? '$i' : ch);
    }
    return b.toString();
  }
}

/// Shows the adult-only gate. Resolves to `true` only when answered correctly.
Future<bool> showParentGate() async {
  final result = await Get.dialog<bool>(
    _ParentGateDialog(challenge: ParentGateChallenge.debugFixed ?? ParentGateChallenge.random()),
    barrierDismissible: true,
  );
  return result ?? false;
}

class _ParentGateDialog extends StatefulWidget {
  const _ParentGateDialog({required this.challenge});

  final ParentGateChallenge challenge;

  @override
  State<_ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<_ParentGateDialog> {
  final _controller = TextEditingController();
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.challenge.check(_controller.text)) {
      Get.back(result: true);
    } else {
      setState(() => _wrong = true);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    return AlertDialog(
      key: const Key('parentGate'),
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: [
          const Icon(Icons.lock_rounded, color: AppColors.teal),
          const SizedBox(width: 8),
          Text(TranslationsKeys.gateTitle.tr),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TranslationsKeys.gateQuestion.trParams({'a': '${c.a}', 'b': '${c.b}'}),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('parentGateInput'),
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]'))],
            decoration: InputDecoration(hintText: TranslationsKeys.gateHint.tr),
            onSubmitted: (_) => _submit(),
          ),
          if (_wrong)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(TranslationsKeys.gateWrong.tr, style: const TextStyle(color: AppColors.tealDeep)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text(TranslationsKeys.btnCancel.tr)),
        FilledButton(
          key: const Key('parentGateConfirm'),
          onPressed: _submit,
          child: Text(TranslationsKeys.btnConfirm.tr),
        ),
      ],
    );
  }
}
