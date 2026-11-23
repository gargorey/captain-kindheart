import 'package:flutter/material.dart';

/// A prewritten, supportive script for the in-app pretend call.
class CallScript {
  const CallScript({required this.id, required this.titleKey, required this.icon, required this.lineKeys});

  final String id;
  final String titleKey;
  final IconData icon;
  final List<String> lineKeys;
}
