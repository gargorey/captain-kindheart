import 'package:flutter/material.dart';

/// A step in a gentle-reminder interaction. Captain Sami says one simple
/// thing at a time.
enum StepKind { instruction, choice, reassurance }

class InteractionStep {
  const InteractionStep({required this.kind, required this.textKey, this.optionKeys = const []});

  final StepKind kind;

  /// Translation key for the line Captain Sami says.
  final String textKey;

  /// For [StepKind.choice]: exactly two translation keys for the options.
  final List<String> optionKeys;
}

/// A behaviour or routine the parent can pick in Gentle Reminder mode.
class Situation {
  const Situation({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.steps,
    required this.relatedBehaviorId,
  });

  final String id;
  final String titleKey;
  final IconData icon;
  final Color color;
  final List<InteractionStep> steps;

  /// The praise behaviour offered when the parent taps "celebrate" at the end.
  final String relatedBehaviorId;
}

/// Parent-written replacement for a situation's title and main message.
class SituationOverride {
  const SituationOverride({this.title, this.message});

  final String? title;
  final String? message;

  bool get isEmpty => (title == null || title!.trim().isEmpty) && (message == null || message!.trim().isEmpty);

  Map<String, dynamic> toJson() => {'title': title, 'message': message};

  factory SituationOverride.fromJson(Map<String, dynamic> json) =>
      SituationOverride(title: json['title'] as String?, message: json['message'] as String?);
}
