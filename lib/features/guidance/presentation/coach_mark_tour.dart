import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../core/guidance/tour_steps.dart';
import '../../../core/theme/app_theme.dart';

void startCoachMarkTour(
  BuildContext context, {
  required List<TourStepDefinition> steps,
  required VoidCallback onComplete,
  VoidCallback? onSkip,
}) {
  if (steps.isEmpty) return;

  final targets = steps
      .map(
        (s) => TargetFocus(
          identify: s.title,
          keyTarget: s.targetKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: s.align,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(s.description, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      )
      .toList();

  TutorialCoachMark(
    targets: targets,
    colorShadow: Colors.black,
    opacityShadow: 0.78,
    textSkip: MaterialLocalizations.of(context).okButtonLabel,
    onFinish: () {
      onComplete();
      return true;
    },
    onSkip: () {
      onSkip?.call();
      onComplete();
      return true;
    },
  ).show(context: context);
}
