import 'package:flutter/material.dart';

/// A positive behaviour that can be praised and earns a badge.
class Behavior {
  const Behavior({
    required this.id,
    required this.titleKey,
    required this.praiseKey,
    required this.badgeKey,
    required this.icon,
    required this.color,
  });

  final String id;
  final String titleKey;
  final String praiseKey;
  final String badgeKey;
  final IconData icon;
  final Color color;
}

/// A non-competitive reward the parent can offer.
class RewardOption {
  const RewardOption({required this.id, required this.titleKey, required this.icon});

  final String id;
  final String titleKey;
  final IconData icon;
}
