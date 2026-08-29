import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/ai/ai_json_client.dart';
import '../models/ai_usage_result.dart';
import '../providers/app_providers.dart';
import '../providers/ai_platform_providers.dart';
import '../ai_platform/ai_request_pipeline.dart';
import '../ai_platform/rag_context_builder.dart';
import '../services/exam_plan_sync.dart';
import '../../data/local/models/goal_agent_seeds.dart';

/// One-shot AI agent that runs the first time a provider is saved.
///
/// GoalAgent v2 branches prompts and persistence by goal mode:
/// - exam_prep → weighted syllabus units + study plan sync
/// - career → skill matrix + interview drill themes
/// - learning → paths, topic seeds, nudges
class GoalAgent {
  const GoalAgent(this._ref);

  final WidgetRef _ref;

  Future<void> seedOnFirstProvider() async {
    try {
      await _run();
    } catch (e) {
      if (kDebugMode) debugPrint('GoalAgent: seed failed - $e');
    }
  }

  Future<void> _run() async {
    final learnerRepo = _ref.read(learnerRepositoryProvider);
    final progressRepo = _ref.read(goalProgressRepositoryProvider);
    final providerRepo = _ref.read(providerRepositoryProvider);
    final telemetry = _ref.read(telemetryServiceProvider);

    final config = await providerRepo.getDefault();
    if (config == null) return;

    final apiKey = await providerRepo.getApiKey(config.uuid);
    if (apiKey == null || apiKey.isEmpty) return;

    final profile = await learnerRepo.getOrCreateProfile();
    final goals = learnerRepo.goalsOf(profile);
    final weakTopics = (await learnerRepo.weakTopics(limit: 5)).map((t) => t.topic).toList();

    var goalMode = 'learning';
    var goalContext = '';
    try {
      goalMode = profile.goalMode;
    } catch (_) {}
    try {
      goalContext = profile.goalContext;
    } catch (_) {}

    final prompt = _buildPrompt(
      goalMode: goalMode,
      goalContext: goalContext,
      goals: goals,
      weakTopics: weakTopics,
      skillLevel: profile.skillLevel,
      examDate: profile.examDate,
      dailyMinutes: profile.dailyMinutesGoal ?? 15,
    );

    final knowledgeRepo = _ref.read(knowledgeRepositoryProvider);
    final aiPipeline = _ref.read(aiRequestPipelineProvider);
    final enabledSources = await knowledgeRepo.enabledSourceUuids(goalMode);
    final sourceTypes = await knowledgeRepo.enabledSourceTypes(goalMode);
    final ragQuery = [
      if (goalContext.isNotEmpty) goalContext,
      ...goals,
    ].join('; ');
    final rag = await aiPipeline.buildRag(
      AiRequestContext(
        task: 'goal_agent',
        providerKey: config.uuid,
        goalMode: goalMode,
        topic: ragQuery.isEmpty ? 'personalised learning plan' : ragQuery,
        enabledSourceUuids: enabledSources,
        sourceTypes: sourceTypes,
      ),
    );
    final userPrompt = RagContextBuilder.prependToPrompt(prompt, rag);

    final sw = Stopwatch()..start();
    try {
      final raw = await AiJsonClient.complete(
        config: config,
        apiKey: apiKey,
        userPrompt: userPrompt,
        systemPrompt:
            'You are an intelligent learning coach. Respond with a single valid JSON object only. No markdown, no explanation.',
      );
      sw.stop();
      final usage = LastAiUsage.consume();
      await _ref.read(llmTelemetryProvider).recordCall(
        providerKey: config.uuid,
        task: 'goal_agent',
        latencyMs: sw.elapsedMilliseconds,
        success: true,
        promptTokens: usage?.promptTokens ?? 0,
        completionTokens: usage?.completionTokens ?? 0,
      );

      await _applyResponse(
        raw: raw,
        goalMode: goalMode,
        profile: profile,
        goals: goals,
        learnerRepo: learnerRepo,
        progressRepo: progressRepo,
        telemetry: telemetry,
      );

      _ref.invalidate(personalizationProvider);
    } catch (e) {
      sw.stop();
      await _ref.read(llmTelemetryProvider).recordCall(
        providerKey: config.uuid,
        task: 'goal_agent',
        latencyMs: sw.elapsedMilliseconds,
        success: false,
        errorKind: e.runtimeType.toString(),
      );
      rethrow;
    }
  }

  String _buildPrompt({
    required String goalMode,
    required String goalContext,
    required List<String> goals,
    required List<String> weakTopics,
    required double skillLevel,
    required DateTime? examDate,
    required int dailyMinutes,
  }) {
    final modeDesc = switch (goalMode) {
      'exam_prep' =>
        'preparing for an exam${examDate != null ? ' on ${examDate.day}/${examDate.month}/${examDate.year}' : ''}${goalContext.isNotEmpty ? ' ($goalContext)' : ''}',
      'career' => 'preparing for a new role${goalContext.isNotEmpty ? ': $goalContext' : ''}',
      _ => 'learning new topics for general knowledge',
    };

    final schema = switch (goalMode) {
      'exam_prep' => '''
{
  "examTitle": "string - exam name",
  "syllabusUnits": [
    { "title": "string", "weight": 0.2, "topics": ["topic1"], "targetMastery": 0.7 }
  ],
  "studyPlanHints": [
    { "weekOffset": 0, "focusUnits": ["unit title"], "mockThisWeek": false }
  ],
  "recommendedDailyMinutes": 45,
  "recommendedMockDurationMinutes": 90,
  "topicStrengthSeeds": { "topic": 0.3 },
  "nudgeMessages": ["..."],
  "suggestedPaths": [{ "title": "...", "topics": ["..."] }]
}''',
      'career' => '''
{
  "roleTitle": "string - target role",
  "skills": [
    {
      "title": "string",
      "category": "technical|behavioral|tool|domain",
      "targetLevel": 0.8,
      "seedLevel": 0,
      "topics": ["practice topic"]
    }
  ],
  "interviewDrillThemes": ["System design", "Behavioral leadership"],
  "recommendedDailyMinutes": 30,
  "topicStrengthSeeds": { "topic": 0.3 },
  "nudgeMessages": ["..."],
  "suggestedPaths": [{ "title": "...", "topics": ["..."] }]
}''',
      _ => '''
{
  "suggestedPaths": [{ "title": "...", "topics": ["..."] }],
  "topicStrengthSeeds": { "topic": 0.3 },
  "nudgeMessages": ["..."],
  "recommendedDailyMinutes": 20
}''',
    };

    return '''
You are an intelligent learning coach personalising a study app for a user.

User profile:
- Goal mode: $goalMode - $modeDesc
- Topics they want to learn: ${goals.isEmpty ? 'not set yet' : goals.join(', ')}
- Weak areas: ${weakTopics.isEmpty ? 'none yet' : weakTopics.join(', ')}
- Skill level: ${(skillLevel * 100).round()}% (0 = beginner, 100 = expert)
- Daily study budget: $dailyMinutes minutes

Respond with JSON following this exact schema:
$schema

Rules:
- Weights for syllabusUnits should sum to ~1.0 across units.
- Include 4 - 10 syllabusUnits for exam_prep OR 5 - 12 skills for career.
- topicStrengthSeeds: estimate prior knowledge (0.0 - 1.0) for topics not yet started.
- nudgeMessages: 3 short, warm, goal-specific nudges (max 80 chars each).
- recommendedDailyMinutes: integer 5 - 120 based on goal urgency.
- interviewDrillThemes: 3 - 6 themes for career mode only; [] for other modes.
- Keep all text in English.
''';
  }

  Future<void> _applyResponse({
    required String raw,
    required String goalMode,
    required dynamic profile,
    required List<String> goals,
    required dynamic learnerRepo,
    required dynamic progressRepo,
    required dynamic telemetry,
  }) async {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      if (kDebugMode) debugPrint('GoalAgent: invalid JSON response');
      return;
    }

    // Mode-specific persistence
    if (goalMode == 'exam_prep') {
      final examTitle = json['examTitle']?.toString().trim();
      if (examTitle != null && examTitle.isNotEmpty && profile.goalContext.isEmpty) {
        await learnerRepo.updateProfile(goalContext: examTitle);
      }

      final units = parseSyllabusUnits(json['syllabusUnits']);
      var unitCount = 0;
      if (units.isNotEmpty) {
        unitCount = await progressRepo.seedSyllabusFromAgent(
          title: examTitle?.isNotEmpty == true ? examTitle! : profile.goalContext,
          units: units,
          examDate: profile.examDate,
        );
      } else if (goals.isNotEmpty) {
        await progressRepo.bootstrapSyllabus(
          title: profile.goalContext.isNotEmpty ? profile.goalContext : 'Exam syllabus',
          topics: goals,
          examDate: profile.examDate,
          source: 'agent_fallback',
        );
        unitCount = goals.length;
      }

      if (unitCount > 0) {
        await telemetry.emit('syllabus_seeded', {
          'unitCount': unitCount,
          'source': units.isNotEmpty ? 'agent' : 'fallback',
        });
      }

      if (profile.examDate != null) {
        final refreshed = await learnerRepo.getOrCreateProfile();
        await syncExamPlanAndReminders(progress: progressRepo, profile: refreshed);
      }
    } else if (goalMode == 'career') {
      final roleTitle = json['roleTitle']?.toString().trim();
      if (roleTitle != null && roleTitle.isNotEmpty && profile.goalContext.isEmpty) {
        await learnerRepo.updateProfile(goalContext: roleTitle);
      }

      final skills = parseCareerSkills(json['skills']);
      var skillCount = 0;
      if (skills.isNotEmpty) {
        skillCount = await progressRepo.seedCareerSkillsFromAgent(
          roleTitle: roleTitle?.isNotEmpty == true ? roleTitle! : profile.goalContext,
          skills: skills,
        );
      } else if (goals.isNotEmpty) {
        await progressRepo.bootstrapCareerSkills(
          roleTitle: profile.goalContext.isNotEmpty ? profile.goalContext : 'Target role',
          skills: goals,
        );
        skillCount = goals.length;
      }

      if (skillCount > 0) {
        await telemetry.emit('career_matrix_seeded', {
          'skillCount': skillCount,
          'source': skills.isNotEmpty ? 'agent' : 'fallback',
        });
      }
    }

    // Shared: topic strength seeds
    final seeds = json['topicStrengthSeeds'];
    if (seeds is Map) {
      for (final entry in seeds.entries) {
        final topic = entry.key.toString().trim();
        if (topic.isEmpty) continue;
        final strength = 0.0;
        await learnerRepo.upsertTopic(topic, strength: strength);
      }
    }

    // Shared: nudges
    final nudges = json['nudgeMessages'];
    if (nudges is List) {
      for (final msg in nudges.take(3)) {
        if (msg is String && msg.isNotEmpty) {
          await learnerRepo.addRecommendation(
            kind: 'nudge',
            title: msg,
            reason: 'Personalised by your AI tutor',
            score: 0.85,
          );
        }
      }
    }

    // Shared: daily minutes
    final suggestedMinutes = json['recommendedDailyMinutes'];
    if (suggestedMinutes is int && profile.dailyMinutesGoal == null) {
      await learnerRepo.updateProfile(
        dailyMinutesGoal: suggestedMinutes.clamp(5, 120),
      );
    }

    // Shared: first suggested path
    final paths = json['suggestedPaths'];
    if (paths is List && paths.isNotEmpty) {
      final first = paths.first;
      if (first is Map) {
        final topics = (first['topics'] as List?)?.cast<String>() ?? [];
        final title = first['title']?.toString() ?? 'Your personalised path';
        if (topics.isNotEmpty) {
          await learnerRepo.addRecommendation(
            kind: 'path',
            title: title,
            reason: 'AI-suggested based on your goal',
            score: 0.95,
            topic: topics.first,
            actionPayload: {'topics': topics},
          );
        }
      }
    }

    // Career: interview drill themes
    if (goalMode == 'career') {
      final themes = json['interviewDrillThemes'];
      if (themes is List) {
        for (final theme in themes.take(4)) {
          if (theme is String && theme.trim().isNotEmpty) {
            await learnerRepo.addRecommendation(
              kind: 'interview',
              title: 'Interview drill: ${theme.trim()}',
              reason: 'AI-suggested practice for your target role',
              score: 0.88,
              topic: theme.trim(),
              actionPayload: {
                'route': '/career/drill/create',
                'theme': theme.trim(),
              },
            );
          }
        }
      }
    }

    await telemetry.emit('goal_agent_seeded', {
      'goalMode': goalMode,
      'hasSyllabusUnits': goalMode == 'exam_prep' && json['syllabusUnits'] is List,
      'hasSkills': goalMode == 'career' && json['skills'] is List,
    });

    if (kDebugMode) debugPrint('GoalAgent v2: seeding complete ($goalMode)');
  }
}
