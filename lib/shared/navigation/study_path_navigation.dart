import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/app_localizations_ext.dart';
import '../../core/providers/app_providers.dart';
import '../../data/local/models/learning_path.dart';
import '../../data/local/models/quiz_session.dart';

Future<void> openQuickQuizForTopic(BuildContext context, {required String topic}) {
  final encoded = Uri.encodeComponent(topic.trim());
  return context.push('/quiz/create?topic=$encoded');
}

Future<void> openQuizInsightForTopic(
  BuildContext context,
  WidgetRef ref, {
  required String topic,
}) async {
  final session = await ref.read(quizRepositoryProvider).getLatestCompletedForTopic(topic);
  if (!context.mounted) return;
  if (session != null) {
    context.push('/quiz/results/${session.uuid}');
    return;
  }
  await openQuickQuizForTopic(context, topic: topic);
}

Future<void> openQuizResult(BuildContext context, QuizSession session) {
  return context.push('/quiz/results/${session.uuid}');
}

Future<void> openStudyPathForTopic(
  BuildContext context,
  WidgetRef ref, {
  String? topic,
}) async {
  final repo = ref.read(learnerRepositoryProvider);
  LearningPath? path;
  int? moduleIndex;

  if (topic != null && topic.trim().isNotEmpty) {
    final match = await repo.pathContainingTopic(topic);
    path = match?.path;
    moduleIndex = match?.moduleIndex;
  }
  path ??= await repo.primaryActivePath();

  if (!context.mounted) return;
  if (path == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.studyPathGenerateFirst)),
    );
    return;
  }

  final uri = moduleIndex == null
      ? '/paths/${path.uuid}'
      : '/paths/${path.uuid}?module=$moduleIndex';
  context.push(uri);
}
