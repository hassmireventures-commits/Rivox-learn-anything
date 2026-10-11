import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/quiz_kind.dart';
import '../../error/app_exception.dart';
import '../generation_job_service.dart';
import '../../router/app_navigation.dart';
import '../../router/route_path_observer.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../network/network_service.dart';
import '../../providers/ai_platform_providers.dart';
import '../../providers/app_providers.dart';
import '../../services/agentic/agent_autonomy_policy.dart';
import '../../services/agentic/goal_content_validation_agent.dart';
import '../../services/built_in_ai_quota.dart';
import '../../services/generation_sizing.dart';
import '../../services/learner_goal_guard.dart';
import '../../services/topic_goal_relevance.dart';
import '../../../data/remote/ai/chat_reply_result.dart';
import '../../../shared/widgets/built_in_quota_dialog.dart';
import '../../../shared/widgets/generation_preflight_sheet.dart';
import '../../../shared/widgets/goal_required_dialog.dart';

/// Shared execution path for chat chips and Home next-session (MoSCoW M2/M4/M5).
class ProposedActionRunner {
  ProposedActionRunner._();

  static Future<void> run(
    BuildContext context,
    WidgetRef ref,
    ChatProposedAction action, {
    bool skipGenerationPreflight = false,
  }) async {
    if (action.isVideo) {
      // In-app player first (VideoSearchScreen); it only offers the YouTube
      // app itself when no embeddable, on-topic video is found.
      if (!context.mounted) return;
      await context.push('/video?q=${Uri.encodeQueryComponent(action.topic)}');
      return;
    }

    if (action.isNavigate) {
      final route = action.route;
      if (route == null || !context.mounted) return;
      // Captured before navigating: a tab route is opened with `go`, which
      // tears down the calling screen (chat) and its context along with it.
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      final origin = currentRoutePath.value;
      final isTab = isShellTabRoute(route);
      openAppRoute(context, route);
      if (!AgentAutonomyPolicy.mayAutoExecute(action)) return;
      // Undo for a push is a pop. For a tab switch the origin screen is gone,
      // so undo re-opens it (only possible when it was a named, pushed route).
      final VoidCallback? undo = !isTab
          ? () {
              if (router.canPop()) router.pop();
            }
          : (origin != null && !isShellTabRoute(origin))
              ? () => router.push(origin)
              : null;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Opened ${action.topic}'),
          duration: const Duration(seconds: 5),
          action: undo == null ? null : SnackBarAction(label: 'Undo', onPressed: undo),
        ),
      );
      return;
    }

    final job = ref.read(generationJobServiceProvider);
    if (job.isBusy) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A generation is already running — try again once it finishes.'),
        ),
      );
      return;
    }
    final pendingRoute = job.pendingReadyRoute;
    if (pendingRoute != null) {
      job.clearTerminalState();
      context.push(pendingRoute);
      return;
    }

    try {
      await NetworkService.instance.ensureConnected();
    } catch (e) {
      if (!context.mounted) return;
      await showAppErrorDialog(context, e);
      return;
    }

    final learnerRepository = ref.read(learnerRepositoryProvider);
    final profile = await learnerRepository.getOrCreateProfile();
    if (!context.mounted) return;
    if (!LearnerGoalGuard.hasUsableGoal(profile, learnerRepository: learnerRepository)) {
      await showGoalRequiredDialog(context);
      return;
    }

    final firewallResult = await ref.read(aiRequestPipelineProvider).sanitizeTopic(action.topic);
    if (firewallResult.blocked) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(firewallResult.reason ?? "That topic isn't allowed.")),
      );
      return;
    }
    final sanitizedTopic = firewallResult.sanitized;

    final goals = learnerRepository.goalsOf(profile);
    final goalLabel = profile.goalContext.trim().isNotEmpty
        ? profile.goalContext.trim()
        : (goals.isNotEmpty ? goals.first : sanitizedTopic);
    final validation = GoalContentValidationAgent().validateGenerationTopic(
      goal: goalLabel,
      topic: sanitizedTopic,
      goalTopics: goals,
    );
    if (!validation.approved) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "That topic doesn't match your current goal, so Rivox won't generate it.",
          ),
        ),
      );
      return;
    }

    final personalization = await ref.read(personalizationProvider.future);
    final relevance = TopicGoalRelevanceGate.evaluate(
      topic: sanitizedTopic,
      goalLabel: personalization.goalContextLabel,
      goalTopics: personalization.primaryTopics,
    );
    if (relevance.level == TopicGoalRelevance.offGoal) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "That looks off-goal for your current focus, so I won't start it — "
            'you can still create it manually from the Create tab.',
          ),
        ),
      );
      return;
    }

    final providers = await ref.read(aiProvidersProvider.future);
    final activeProvider = GenerationSizing.pickActiveCloudProvider(providers);
    final isBuiltin = GenerationSizing.isBuiltinProvider(activeProvider);

    if (isBuiltin) {
      try {
        await BuiltInAiQuota.instance.ensureCanGenerate();
      } on BuiltInQuotaExceededException {
        if (!context.mounted) return;
        final unlocked = await showBuiltInQuotaDialog(context);
        if (unlocked && context.mounted) {
          await run(context, ref, action, skipGenerationPreflight: skipGenerationPreflight);
        }
        return;
      }
    }

    if (!skipGenerationPreflight &&
        AgentAutonomyPolicy.requiresGenerationPreflight(action) &&
        context.mounted) {
      final ok = await showGenerationPreflightSheet(
        context,
        action: action,
        activeProvider: activeProvider,
        isBuiltin: isBuiltin,
      );
      if (!ok || !context.mounted) return;
    }

    try {
      if (action.isFixQuiz) {
        await _replaceQuiz(ref, job, action, sanitizedTopic, isBuiltin: isBuiltin);
        if (!context.mounted) return;
        if (job.successRoute != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Replaced the quiz with one on $sanitizedTopic')),
          );
        }
      } else if (action.isQuiz) {
        final count = GenerationSizing.clampQuizQuestionCount(
          questionCount: action.questionCount ?? 15,
          isBuiltin: isBuiltin,
        );
        final explanations = GenerationSizing.explanationsForBuiltin(
          requested: true,
          isBuiltin: isBuiltin,
          questionCount: count,
        );
        await job.startQuiz(
          topic: sanitizedTopic,
          questionCount: count,
          difficulty: action.difficulty ?? 'medium',
          explanations: explanations,
        );
      } else {
        final modules = GenerationSizing.clampPathModuleCount(
          moduleCount: action.pathModuleCount ?? 6,
          isBuiltin: isBuiltin,
        );
        await job.startPath(focus: sanitizedTopic, moduleCount: modules);
      }
    } catch (e) {
      if (!context.mounted) return;
      await showAppErrorDialog(context, e);
    }
  }

  /// Self-healing quiz repair: regenerate on the corrected topic, keeping
  /// the broken quiz's size, difficulty, and module link, and only delete the
  /// broken quiz once the replacement exists (a failed regeneration must not
  /// leave the learner with nothing).
  static Future<void> _replaceQuiz(
    WidgetRef ref,
    GenerationJobService job,
    ChatProposedAction action,
    String topic, {
    required bool isBuiltin,
  }) async {
    final quizRepository = ref.read(quizRepositoryProvider);
    final old = await quizRepository.getSession(action.quizId!);
    final count = GenerationSizing.clampQuizQuestionCount(
      questionCount: old?.questionCount ?? 10,
      isBuiltin: isBuiltin,
    );
    await job.startQuiz(
      topic: topic,
      questionCount: count,
      difficulty: old?.difficulty ?? 'medium',
      explanations: GenerationSizing.explanationsForBuiltin(
        requested: true,
        isBuiltin: isBuiltin,
        questionCount: count,
      ),
      quizKind: old?.quizKind ?? QuizKind.quick,
      pathId: old?.pathId,
      moduleIndex: old?.moduleIndex,
    );
    if (old != null && job.successRoute != null) {
      await quizRepository.deleteQuiz(old.uuid);
    }
  }
}
