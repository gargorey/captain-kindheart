import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/translations/translations_keys.dart';
import '../models/behavior.dart';
import '../models/call_script.dart';
import '../models/situation.dart';

typedef K = TranslationsKeys;

/// Local demo content. Widgets never hard-code this; they read it through
/// [ContentRepository].
abstract final class MockContent {
  static List<InteractionStep> _steps(String main, String choice, String a, String b, String end) => [
    InteractionStep(kind: StepKind.instruction, textKey: main),
    InteractionStep(kind: StepKind.choice, textKey: choice, optionKeys: [a, b]),
    InteractionStep(kind: StepKind.reassurance, textKey: end),
  ];

  static final List<Situation> situations = [
    Situation(
      id: 'tidy',
      titleKey: K.sitTidyTitle,
      icon: Icons.toys_rounded,
      color: AppColors.yellow,
      relatedBehaviorId: 'tidy',
      steps: _steps(K.sitTidyMain, K.sitTidyChoice, K.sitTidyOptA, K.sitTidyOptB, K.sitTidyEnd),
    ),
    Situation(
      id: 'gentle',
      titleKey: K.sitGentleTitle,
      icon: Icons.back_hand_rounded,
      color: AppColors.coral,
      relatedBehaviorId: 'gentle',
      steps: _steps(K.sitGentleMain, K.sitGentleChoice, K.sitGentleOptA, K.sitGentleOptB, K.sitGentleEnd),
    ),
    Situation(
      id: 'voice',
      titleKey: K.sitVoiceTitle,
      icon: Icons.record_voice_over_rounded,
      color: AppColors.sky,
      relatedBehaviorId: 'listen',
      steps: _steps(K.sitVoiceMain, K.sitVoiceChoice, K.sitVoiceOptA, K.sitVoiceOptB, K.sitVoiceEnd),
    ),
    Situation(
      id: 'share',
      titleKey: K.sitShareTitle,
      icon: Icons.volunteer_activism_rounded,
      color: AppColors.green,
      relatedBehaviorId: 'share',
      steps: _steps(K.sitShareMain, K.sitShareChoice, K.sitShareOptA, K.sitShareOptB, K.sitShareEnd),
    ),
    Situation(
      id: 'listen',
      titleKey: K.sitListenTitle,
      icon: Icons.hearing_rounded,
      color: AppColors.lilac,
      relatedBehaviorId: 'listen',
      steps: _steps(K.sitListenMain, K.sitListenChoice, K.sitListenOptA, K.sitListenOptB, K.sitListenEnd),
    ),
    Situation(
      id: 'bedtime',
      titleKey: K.sitBedtimeTitle,
      icon: Icons.bedtime_rounded,
      color: AppColors.skyDeep,
      relatedBehaviorId: 'routine',
      steps: _steps(K.sitBedtimeMain, K.sitBedtimeChoice, K.sitBedtimeOptA, K.sitBedtimeOptB, K.sitBedtimeEnd),
    ),
  ];

  static const List<CallScript> callScripts = [
    CallScript(
      id: 'kind',
      titleKey: K.csKindTitle,
      icon: Icons.favorite_rounded,
      lineKeys: [K.csKind1, K.csKind2, K.csKind3, K.csKind4],
    ),
    CallScript(
      id: 'tidy',
      titleKey: K.csTidyTitle,
      icon: Icons.toys_rounded,
      lineKeys: [K.csTidy1, K.csTidy2, K.csTidy3, K.csTidy4],
    ),
    CallScript(
      id: 'bedtime',
      titleKey: K.csBedTitle,
      icon: Icons.nightlight_round,
      lineKeys: [K.csBed1, K.csBed2, K.csBed3, K.csBed4],
    ),
    CallScript(
      id: 'share',
      titleKey: K.csShareTitle,
      icon: Icons.volunteer_activism_rounded,
      lineKeys: [K.csShare1, K.csShare2, K.csShare3, K.csShare4],
    ),
  ];

  static const List<Behavior> behaviors = [
    Behavior(
      id: 'tidy',
      titleKey: K.bhTidy,
      praiseKey: K.prTidy,
      badgeKey: K.badgeTidy,
      icon: Icons.toys_rounded,
      color: AppColors.yellow,
    ),
    Behavior(
      id: 'share',
      titleKey: K.bhShare,
      praiseKey: K.prShare,
      badgeKey: K.badgeShare,
      icon: Icons.volunteer_activism_rounded,
      color: AppColors.green,
    ),
    Behavior(
      id: 'gentle',
      titleKey: K.bhGentle,
      praiseKey: K.prGentle,
      badgeKey: K.badgeGentle,
      icon: Icons.back_hand_rounded,
      color: AppColors.coral,
    ),
    Behavior(
      id: 'teeth',
      titleKey: K.bhTeeth,
      praiseKey: K.prTeeth,
      badgeKey: K.badgeTeeth,
      icon: Icons.clean_hands_rounded,
      color: AppColors.sky,
    ),
    Behavior(
      id: 'polite',
      titleKey: K.bhPolite,
      praiseKey: K.prPolite,
      badgeKey: K.badgePolite,
      icon: Icons.auto_awesome_rounded,
      color: AppColors.lilac,
    ),
    Behavior(
      id: 'routine',
      titleKey: K.bhRoutine,
      praiseKey: K.prRoutine,
      badgeKey: K.badgeRoutine,
      icon: Icons.checklist_rounded,
      color: AppColors.teal,
    ),
    Behavior(
      id: 'listen',
      titleKey: K.bhListen,
      praiseKey: K.prListen,
      badgeKey: K.badgeListen,
      icon: Icons.hearing_rounded,
      color: AppColors.skyDeep,
    ),
    Behavior(
      id: 'help',
      titleKey: K.bhHelp,
      praiseKey: K.prHelp,
      badgeKey: K.badgeHelp,
      icon: Icons.home_rounded,
      color: AppColors.greenDeep,
    ),
    Behavior(
      id: 'tryAgain',
      titleKey: K.bhTryAgain,
      praiseKey: K.prTryAgain,
      badgeKey: K.badgeTryAgain,
      icon: Icons.replay_rounded,
      color: AppColors.coral,
    ),
  ];

  static const List<RewardOption> rewards = [
    RewardOption(id: 'sticker', titleKey: K.rwSticker, icon: Icons.star_rounded),
    RewardOption(id: 'dance', titleKey: K.rwDance, icon: Icons.music_note_rounded),
    RewardOption(id: 'story', titleKey: K.rwStory, icon: Icons.menu_book_rounded),
    RewardOption(id: 'choose', titleKey: K.rwChoose, icon: Icons.extension_rounded),
  ];

  static const List<String> cheers = [K.cheer1, K.cheer2, K.cheer3, K.cheer4];

  static const List<String> fallbackPhraseKeys = [K.fbStar, K.fbHero, K.fbHeroine, K.fbClever, K.fbCleverF, K.fbSweet];

  static const Map<String, IconData> avatars = {
    'star': Icons.star_rounded,
    'rocket': Icons.rocket_launch_rounded,
    'flower': Icons.local_florist_rounded,
    'pet': Icons.pets_rounded,
    'sun': Icons.wb_sunny_rounded,
  };
}
