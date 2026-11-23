/// Replaces name tokens in Captain Sami's lines.
///
/// Built-in lines use `@name`. Parent-written lines may use `{الاسم}` as a
/// friendlier token. Both resolve to a vocative phrase: "يا سارة" when a
/// name is saved, or the parent's chosen fallback (for example "يا نجم البيت").
class NamePersonalizer {
  const NamePersonalizer({required this.childName, required this.fallbackPhrase});

  static const String token = '@name';
  static const String parentToken = '{الاسم}';

  final String? childName;
  final String fallbackPhrase;

  String get vocative {
    final name = childName?.trim() ?? '';
    if (name.isEmpty) return fallbackPhrase;
    return 'يا $name';
  }

  String apply(String text) => text.replaceAll(token, vocative).replaceAll(parentToken, vocative);
}
