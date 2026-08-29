import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/local/models/recommendation.dart';
import 'study_path_navigation.dart';

/// Navigate from a recommendation row using existing routes and repo methods.
Future<void> openRecommendation(
  BuildContext context,
  WidgetRef ref, {
  required RecommendationItem item,
}) async {
  final repo = ref.read(learnerRepositoryProvider);

  Map<String, dynamic>? payload;
  if (item.actionPayloadJson != null && item.actionPayloadJson!.isNotEmpty) {
    try {
      final decoded = jsonDecode(item.actionPayloadJson!);
      if (decoded is Map) {
        payload = decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}
  }

  final route = payload?['route'] as String?;
  if (route != null && route.isNotEmpty) {
    if (!context.mounted) return;
    context.push(route);
    await repo.actOnRecommendation(item.uuid);
    return;
  }

  switch (item.kind) {
    case 'mock':
      if (!context.mounted) return;
      context.push('/exam/mock/create');
    case 'interview':
      if (!context.mounted) return;
      context.push('/career/drill/create');
    case 'break':
    case 'nudge':
      if (item.topic != null && item.topic!.isNotEmpty) {
        await openQuickQuizForTopic(context, topic: item.topic!);
      } else if (context.mounted) {
        context.push('/quiz/create');
      }
    case 'next_topic':
    case 'remedial':
      if (item.topic != null && item.topic!.isNotEmpty) {
        await openQuizInsightForTopic(context, ref, topic: item.topic!);
      }
    case 'path':
      await openStudyPathForTopic(context, ref, topic: item.topic);
    case 'layout':
      if (context.mounted) context.push('/settings');
    default:
      if (item.topic != null && item.topic!.isNotEmpty) {
        await openQuickQuizForTopic(context, topic: item.topic!);
      }
  }

  await repo.actOnRecommendation(item.uuid);
}
