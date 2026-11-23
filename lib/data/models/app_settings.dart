/// Gentle voice presets mapped to speech rate and pitch in the audio service.
enum VoiceStyle { calm, warm, cheerful }

enum AgeRange { age3to4, age5to6, age7to8 }

/// Parent preferences. Stored locally only. The child's nickname is optional
/// and never leaves the device.
class AppSettings {
  const AppSettings({
    this.onboarded = false,
    this.callIntroSeen = false,
    this.childName,
    this.fallbackPhraseKey = 'fbStar',
    this.ageRange = AgeRange.age5to6,
    this.avatarId = 'star',
    this.voiceEnabled = true,
    this.voiceStyle = VoiceStyle.warm,
    this.volume = 0.7,
    this.quietMode = false,
    this.sessionMinutes = 5,
  });

  static const List<int> sessionOptions = [3, 5, 10];

  final bool onboarded;
  final bool callIntroSeen;
  final String? childName;
  final String fallbackPhraseKey;
  final AgeRange ageRange;
  final String avatarId;
  final bool voiceEnabled;
  final VoiceStyle voiceStyle;
  final double volume;
  final bool quietMode;
  final int sessionMinutes;

  /// Voice plays only if the parent enabled it and quiet mode is off.
  bool get voiceActive => voiceEnabled && !quietMode;

  AppSettings copyWith({
    bool? onboarded,
    bool? callIntroSeen,
    String? childName,
    bool clearChildName = false,
    String? fallbackPhraseKey,
    AgeRange? ageRange,
    String? avatarId,
    bool? voiceEnabled,
    VoiceStyle? voiceStyle,
    double? volume,
    bool? quietMode,
    int? sessionMinutes,
  }) => AppSettings(
    onboarded: onboarded ?? this.onboarded,
    callIntroSeen: callIntroSeen ?? this.callIntroSeen,
    childName: clearChildName ? null : (childName ?? this.childName),
    fallbackPhraseKey: fallbackPhraseKey ?? this.fallbackPhraseKey,
    ageRange: ageRange ?? this.ageRange,
    avatarId: avatarId ?? this.avatarId,
    voiceEnabled: voiceEnabled ?? this.voiceEnabled,
    voiceStyle: voiceStyle ?? this.voiceStyle,
    volume: volume ?? this.volume,
    quietMode: quietMode ?? this.quietMode,
    sessionMinutes: sessionMinutes ?? this.sessionMinutes,
  );

  Map<String, dynamic> toJson() => {
    'onboarded': onboarded,
    'callIntroSeen': callIntroSeen,
    'childName': childName,
    'fallbackPhraseKey': fallbackPhraseKey,
    'ageRange': ageRange.name,
    'avatarId': avatarId,
    'voiceEnabled': voiceEnabled,
    'voiceStyle': voiceStyle.name,
    'volume': volume,
    'quietMode': quietMode,
    'sessionMinutes': sessionMinutes,
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    const d = AppSettings();
    T pick<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.firstWhere((v) => v.name == name, orElse: () => fallback);
    return AppSettings(
      onboarded: j['onboarded'] as bool? ?? d.onboarded,
      callIntroSeen: j['callIntroSeen'] as bool? ?? d.callIntroSeen,
      childName: j['childName'] as String?,
      fallbackPhraseKey: j['fallbackPhraseKey'] as String? ?? d.fallbackPhraseKey,
      ageRange: pick(AgeRange.values, j['ageRange'], d.ageRange),
      avatarId: j['avatarId'] as String? ?? d.avatarId,
      voiceEnabled: j['voiceEnabled'] as bool? ?? d.voiceEnabled,
      voiceStyle: pick(VoiceStyle.values, j['voiceStyle'], d.voiceStyle),
      volume: (j['volume'] as num?)?.toDouble().clamp(0.0, 1.0) ?? d.volume,
      quietMode: j['quietMode'] as bool? ?? d.quietMode,
      sessionMinutes: j['sessionMinutes'] as int? ?? d.sessionMinutes,
    );
  }
}
