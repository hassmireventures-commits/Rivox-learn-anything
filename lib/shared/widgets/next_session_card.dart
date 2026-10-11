import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/router/app_navigation.dart';
import '../../core/services/agentic/learner_session_action.dart';
import '../../core/services/agentic/proposed_action_runner.dart';
import '../../core/theme/app_theme.dart';
import 'app_card.dart';
import 'primary_button.dart';

/// Primary Home CTA for the agentic “next session” (MoSCoW M1).
class NextSessionCard extends ConsumerWidget {
  const NextSessionCard({super.key, required this.session});

  final LearnerSessionAction session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return AppCard(
      color: AppTheme.purpleStart.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next session',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.purpleStart,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            session.title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            session.reason,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: _buttonLabel(session),
            icon: _buttonIcon(session),
            onPressed: () => _onTap(context, ref),
          ),
        ],
      ),
    );
  }

  String _buttonLabel(LearnerSessionAction session) {
    return switch (session.kind) {
      LearnerSessionKind.openReadyGeneration => 'Open',
      LearnerSessionKind.flashcardReview => 'Review now',
      LearnerSessionKind.continuePath => 'Continue path',
      LearnerSessionKind.encourageBreak => 'Got it',
      LearnerSessionKind.openStudyPlan => 'Open study plan',
      LearnerSessionKind.dailyContent => "Open today's pick",
      LearnerSessionKind.suggestPath => 'Start path',
      _ => 'Start',
    };
  }

  IconData _buttonIcon(LearnerSessionAction session) {
    return switch (session.kind) {
      LearnerSessionKind.flashcardReview => Icons.style_rounded,
      LearnerSessionKind.continuePath => Icons.route_rounded,
      LearnerSessionKind.openStudyPlan => Icons.calendar_month_rounded,
      LearnerSessionKind.dailyContent => Icons.auto_stories_rounded,
      LearnerSessionKind.encourageBreak => Icons.self_improvement_rounded,
      _ => Icons.play_arrow_rounded,
    };
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    switch (session.kind) {
      case LearnerSessionKind.openReadyGeneration:
        final route = session.readyRoute;
        if (route == null) return;
        ref.read(generationJobServiceProvider).clearTerminalState();
        if (context.mounted) context.push(route);
      case LearnerSessionKind.flashcardReview:
        if (context.mounted) context.push('/flashcards');
      case LearnerSessionKind.continuePath:
        final pathId = session.pathId;
        final module = session.moduleIndex;
        if (pathId != null && context.mounted) {
          context.push('/paths/$pathId?module=${module ?? 0}');
        } else if (context.mounted) {
          context.go('/learn');
        }
      case LearnerSessionKind.encourageBreak:
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rest helps retention — come back when you are ready.')),
          );
        }
      case LearnerSessionKind.openStudyPlan:
      case LearnerSessionKind.dailyContent:
        final route = session.navigateRoute;
        if (route != null && context.mounted) openAppRoute(context, route);
      case LearnerSessionKind.generateQuiz:
      case LearnerSessionKind.remedialQuiz:
      case LearnerSessionKind.suggestPath:
        final proposed = session.toProposedAction();
        if (proposed != null && context.mounted) {
          await ProposedActionRunner.run(context, ref, proposed);
        }
    }
  }
}
