import 'dart:convert';

import 'package:flutter/services.dart';

class AiPolicy {
  const AiPolicy({
    required this.version,
    required this.maxQuestionsPerQuiz,
    required this.maxPathModules,
    required this.dailyTokenSoftCap,
    required this.dailyTokenHardCap,
    required this.maxTopicLength,
    required this.maxUploadBytes,
    required this.defaultGenerationMode,
    required this.goalDefaults,
    required this.allowedUploadExtensions,
    required this.blockedPromptPatterns,
    required this.blockedProfanityPatterns,
  });

  final String version;
  final int maxQuestionsPerQuiz;
  final int maxPathModules;
  final int dailyTokenSoftCap;
  final int dailyTokenHardCap;
  final int maxTopicLength;
  final int maxUploadBytes;
  final String defaultGenerationMode;
  final Map<String, GoalAiDefaults> goalDefaults;
  final List<String> allowedUploadExtensions;
  final List<String> blockedPromptPatterns;
  final List<String> blockedProfanityPatterns;

  GoalAiDefaults defaultsForGoal(String goalMode) {
    return goalDefaults[goalMode] ?? goalDefaults['learning']!;
  }

  factory AiPolicy.fromJson(Map<String, dynamic> json) {
    final goalsRaw = json['goalDefaults'] as Map<String, dynamic>? ?? {};
    final goals = <String, GoalAiDefaults>{};
    for (final entry in goalsRaw.entries) {
      goals[entry.key] = GoalAiDefaults.fromJson(entry.value as Map<String, dynamic>);
    }
    return AiPolicy(
      version: json['version'] as String? ?? '1.0.0',
      maxQuestionsPerQuiz: (json['maxQuestionsPerQuiz'] as num?)?.toInt() ?? 30,
      maxPathModules: (json['maxPathModules'] as num?)?.toInt() ?? 12,
      dailyTokenSoftCap: (json['dailyTokenSoftCap'] as num?)?.toInt() ?? 200000,
      dailyTokenHardCap: (json['dailyTokenHardCap'] as num?)?.toInt() ?? 500000,
      maxTopicLength: (json['maxTopicLength'] as num?)?.toInt() ?? 500,
      maxUploadBytes: (json['maxUploadBytes'] as num?)?.toInt() ?? 15728640,
      defaultGenerationMode: json['defaultGenerationMode'] as String? ?? 'blended',
      goalDefaults: goals.isEmpty
          ? {
              'learning': const GoalAiDefaults(generationMode: 'blended', ragMaxTokens: 3000),
            }
          : goals,
      allowedUploadExtensions: (json['allowedUploadExtensions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['txt', 'md', 'pdf'],
      blockedPromptPatterns: (json['blockedPromptPatterns'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      blockedProfanityPatterns: (json['blockedProfanityPatterns'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class GoalAiDefaults {
  const GoalAiDefaults({
    required this.generationMode,
    required this.ragMaxTokens,
  });

  final String generationMode;
  final int ragMaxTokens;

  factory GoalAiDefaults.fromJson(Map<String, dynamic> json) {
    return GoalAiDefaults(
      generationMode: json['generationMode'] as String? ?? 'blended',
      ragMaxTokens: (json['ragMaxTokens'] as num?)?.toInt() ?? 3000,
    );
  }
}

class AiPolicyRegistry {
  AiPolicyRegistry._();

  static AiPolicy? _cached;

  static Future<AiPolicy> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/ai/ai_policy_v1.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cached = AiPolicy.fromJson(json);
    return _cached!;
  }

  static AiPolicy get current {
    final p = _cached;
    if (p == null) {
      return AiPolicy.fromJson({
        'version': '1.0.0',
        'goalDefaults': {
          'learning': {'generationMode': 'blended', 'ragMaxTokens': 3000},
          'exam_prep': {'generationMode': 'grounded', 'ragMaxTokens': 4000},
          'career': {'generationMode': 'blended', 'ragMaxTokens': 3500},
        },
      });
    }
    return p;
  }
}
