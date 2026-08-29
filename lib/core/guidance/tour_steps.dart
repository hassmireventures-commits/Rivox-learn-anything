import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// Global keys for coach-mark tour targets (registered on shell / dashboard).
final tourHomeTabKey = GlobalKey();
final tourLearnTabKey = GlobalKey();
final tourHistoryTabKey = GlobalKey();

class TourStepDefinition {
  const TourStepDefinition({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.align,
  });

  final GlobalKey targetKey;
  final String title;
  final String description;
  final ContentAlign align;
}
