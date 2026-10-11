import 'package:flutter/material.dart';

import '../../core/services/built_in_ai_quota.dart';
import '../../core/services/generation_sizing.dart';
import '../../data/local/models/ai_provider_config.dart';
import '../../data/remote/ai/chat_reply_result.dart';

/// Quota-aware confirm before starting quiz/path generation (MoSCoW M4).
Future<bool> showGenerationPreflightSheet(
  BuildContext context, {
  required ChatProposedAction action,
  required AiProviderConfig? activeProvider,
  required bool isBuiltin,
}) async {
  final isQuiz = action.isQuiz || action.isFixQuiz;
  final topic = action.topic;
  final detail = isQuiz
      ? '${GenerationSizing.clampQuizQuestionCount(questionCount: action.questionCount ?? 15, isBuiltin: isBuiltin)} questions'
      : '${GenerationSizing.clampPathModuleCount(moduleCount: action.pathModuleCount ?? 6, isBuiltin: isBuiltin)} modules';

  String quotaLine;
  if (isBuiltin) {
    final snap = await BuiltInAiQuota.instance.load();
    quotaLine = 'Built-in AI: ${snap.remaining} of ${snap.allowance} generations left in this 24h window.';
  } else {
    final name = activeProvider?.name ?? activeProvider?.providerType ?? 'Your provider';
    quotaLine = 'Uses your $name API key (counts toward provider usage).';
  }

  if (!context.mounted) return false;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                action.isFixQuiz ? 'Replace the quiz?' : isQuiz ? 'Generate quiz?' : 'Generate learning path?',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('Topic: $topic'),
              Text(detail),
              const SizedBox(height: 8),
              Text(
                quotaLine,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Generate'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return confirmed == true;
}
