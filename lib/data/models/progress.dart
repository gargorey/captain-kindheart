/// One positive moment the parent celebrated. There is deliberately no
/// "negative" counterpart: the app never records misbehaviour.
class PositiveMoment {
  const PositiveMoment({required this.behaviorId, required this.at, this.rewardId});

  final String behaviorId;
  final String? rewardId;
  final DateTime at;

  Map<String, dynamic> toJson() => {'behaviorId': behaviorId, 'rewardId': rewardId, 'at': at.toIso8601String()};

  factory PositiveMoment.fromJson(Map<String, dynamic> json) => PositiveMoment(
    behaviorId: json['behaviorId'] as String,
    rewardId: json['rewardId'] as String?,
    at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
  );
}

class ProgressState {
  const ProgressState({this.moments = const [], this.badges = const {}});

  final List<PositiveMoment> moments;

  /// Behaviour ids whose badge has been collected.
  final Set<String> badges;

  int get flowers => moments.length;

  ProgressState copyWith({List<PositiveMoment>? moments, Set<String>? badges}) =>
      ProgressState(moments: moments ?? this.moments, badges: badges ?? this.badges);

  Map<String, dynamic> toJson() => {'moments': moments.map((m) => m.toJson()).toList(), 'badges': badges.toList()};

  factory ProgressState.fromJson(Map<String, dynamic> json) => ProgressState(
    moments: (json['moments'] as List? ?? [])
        .whereType<Map>()
        .map((m) => PositiveMoment.fromJson(Map<String, dynamic>.from(m)))
        .toList(),
    badges: (json['badges'] as List? ?? []).whereType<String>().toSet(),
  );
}
