import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:isar_community/isar.dart';

import '../../../core/constants/quiz_kind.dart';
import '../../../core/ai_platform/ai_consent_gate.dart';
import '../../../core/ai_platform/ai_request_pipeline.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/network_service.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_ai_quota.dart';
import '../../../core/services/goal_topic_resolver.dart';
import '../../../core/services/topic_goal_relevance.dart';
import '../../../core/services/llm_manager.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/healing/provider_router.dart';
import '../../../core/locale/locale_utils.dart';
import '../../../core/healing/circuit_breaker.dart';
import '../../../core/healing/health_monitor.dart';
import '../../../core/models/ai_usage_result.dart';
import '../../../core/telemetry/llm_telemetry_recorder.dart';
import '../../../core/healing/resilient_ai_provider.dart';
import '../../../core/telemetry/telemetry_service.dart';
import '../../local/isar_service.dart';
import '../../local/models/prompt_strategy.dart';
import '../../local/repositories/learner_repository.dart';
import '../../local/repositories/profile_repository.dart';
import '../../local/repositories/provider_repository.dart';
import '../../local/repositories/quiz_repository.dart';
import '../../ml/recommendation_engine.dart';
import '../../local/repositories/knowledge_repository.dart';
import '../../vector/knowledge_vector_store.dart';
import 'ai_provider_factory.dart';
import 'models/learning_pattern_context.dart';
import 'models/generated_quiz.dart';
import 'models/quiz_generation_request.dart';
import 'path_json_parser.dart';
import 'resource_link_validator.dart';
import 'path_prompt_builder.dart';
import 'youtube_transcript_fetcher.dart';

enum LearningAction {
  generateQuiz,
  suggestPath,
  summarizeWeaknesses,
  remedialQuiz,
  encourageBreak,
  followUp,
  openPathModule,
}

class OrchestratorDecision {
  const OrchestratorDecision({
    required this.action,
    required this.reason,
    this.topic,
    this.questionCount = 10,
    this.difficulty = 'medium',
    this.pathId,
    this.moduleIndex,
  });

  final LearningAction action;
  final String reason;
  final String? topic;
  final int questionCount;
  final String difficulty;
  final String? pathId;
  final int? moduleIndex;
}

class LearningOrchestrator {
  LearningOrchestrator({
    required this.isarService,
    required this.learnerRepository,
    required this.profileRepository,
    required this.providerRepository,
    required this.quizRepository,
    required this.recommendationEngine,
    required this.vectorStore,
    required this.knowledgeRepository,
    required this.aiPipeline,
    required this.telemetry,
    required this.circuitBreaker,
    required this.healthMonitor,
    required this.llmManager,
    this.llmTelemetry,
  });

  final IsarService isarService;
  final LearnerRepository learnerRepository;
  final ProfileRepository profileRepository;
  final ProviderRepository providerRepository;
  final QuizRepository quizRepository;
  final RecommendationEngine recommendationEngine;
  final KnowledgeVectorStore vectorStore;
  final KnowledgeRepository knowledgeRepository;
  final AiRequestPipeline aiPipeline;
  final TelemetryService telemetry;
  final CircuitBreaker circuitBreaker;
  final HealthMonitor healthMonitor;
  final LlmManager llmManager;
  final LlmTelemetryRecorder? llmTelemetry;

  Isar get _db => isarService.db;

  Future<void> ensureStrategies() async {
    final existing = await _db.promptStrategys.where().findAll();
    if (existing.isNotEmpty) return;
    final defaults = [
      ('standard', 'Standard quiz prompt'),
      ('simplified', 'Simplified JSON-focused prompt'),
      ('remedial', 'Remedial focus on weak areas'),
    ];
    await _db.writeTxn(() async {
      for (final d in defaults) {
        await _db.promptStrategys.put(
          PromptStrategy()
            ..strategyId = d.$1
            ..label = d.$2
            ..weight = 1
            ..attempts = 0
            ..successes = 0
            ..successRate = 0.5
            ..updatedAt = DateTime.now(),
        );
      }
    });
  }

  Future<OrchestratorDecision> decideNext() async {
    await recommendationEngine.refreshRecommendations();
    final recs = await learnerRepository.activeRecommendations();
    if (recs.isEmpty) {
      return const OrchestratorDecision(
        action: LearningAction.generateQuiz,
        reason: 'Start a fresh learning session',
        topic: 'General knowledge',
      );
    }

    final top = recs.first;
    await learnerRepository.markRecommendationShown(top.uuid);
    final activePath = await learnerRepository.primaryActivePath();

    return switch (top.kind) {
      'break' => OrchestratorDecision(
          action: LearningAction.encourageBreak,
          reason: top.reason,
        ),
      'remedial' => activePath != null
          ? OrchestratorDecision(
              action: LearningAction.openPathModule,
              reason: top.reason,
              pathId: activePath.uuid,
              moduleIndex: activePath.currentIndex,
            )
          : OrchestratorDecision(
              action: LearningAction.remedialQuiz,
              reason: top.reason,
              topic: top.topic ?? 'Review',
              questionCount: 5,
              difficulty: 'easy',
            ),
      'path' => OrchestratorDecision(
          action: LearningAction.suggestPath,
          reason: top.reason,
          topic: top.topic,
        ),
      'nudge' => activePath != null
          ? OrchestratorDecision(
              action: LearningAction.openPathModule,
              reason: top.reason,
              pathId: activePath.uuid,
              moduleIndex: activePath.currentIndex,
            )
          : OrchestratorDecision(
              action: LearningAction.generateQuiz,
              reason: top.reason,
              topic: top.topic ?? 'Quick practice',
              questionCount: 5,
            ),
      _ => activePath != null
          ? OrchestratorDecision(
              action: LearningAction.openPathModule,
              reason: top.reason,
              pathId: activePath.uuid,
              moduleIndex: activePath.currentIndex,
            )
          : OrchestratorDecision(
              action: LearningAction.generateQuiz,
              reason: top.reason,
              topic: top.topic ?? 'Practice',
            ),
    };
  }

  Future<String> generatePathTopics(String focus) async {
    try {
      return await generateLearningPathWithLlm(focus: focus);
    } catch (_) {
      return _generateVectorPath(focus);
    }
  }

  Future<String> generateLearningPathWithLlm({
    String? focus,
    int moduleCount = 6,
    String? generationMode,
  }) async {
    try {
      await NetworkService.instance.ensureConnected();
    } on NoInternetException {
      rethrow;
    } catch (_) {
      // Unexpected platform error from connectivity check: skip the gate.
    }
    await ensureStrategies();
    await AiConsentGate.instance.load();
    final profile = await learnerRepository.getOrCreateProfile();
    final goals = learnerRepository.goalsOf(profile);
    final weak = await learnerRepository.weakTopics(limit: 5);
    final weakNames = weak.map((e) => e.topic).toList();
    final primaryGoal = goals.firstOrNull ?? 'Foundations';
    final onGoalWeak = weakNames.where((name) {
      final relevance = TopicGoalRelevanceGate.evaluate(
        topic: name,
        goalLabel: primaryGoal,
        goalTopics: goals,
      );
      return relevance.level != TopicGoalRelevance.offGoal;
    }).toList();
    final rawFocus = focus ?? primaryGoal;

    final firewallResult = await aiPipeline.sanitizeTopic(rawFocus);
    if (firewallResult.blocked) {
      throw TopicNotAllowedException(firewallResult.reason ?? 'Topic not allowed.');
    }

    final topicResolution = await _resolveTopicForGeneration(firewallResult.sanitized);
    final effectiveFocus = topicResolution.topic;

    final enabledSources = await knowledgeRepository.enabledSourceUuids(profile.goalMode);
    final sourceTypes = await knowledgeRepository.enabledSourceTypes(profile.goalMode);
    final pathMode = generationMode ??
        (enabledSources.isNotEmpty ? 'grounded' : null);
    final rag = await aiPipeline.buildRag(
      AiRequestContext(
        task: 'path',
        providerKey: 'pending',
        goalMode: profile.goalMode,
        topic: effectiveFocus,
        enabledSourceUuids: enabledSources,
        sourceTypes: sourceTypes,
        generationMode: pathMode,
      ),
    );

    await aiPipeline.ensureTokenBudget();
    final resolved = await llmManager.resolve();

    final settings = await profileRepository.getSettings();
    final languageName = aiLanguageName(settings.language);

    final prompt = PathPromptBuilder.build(
      goals: goals,
      weakTopics: onGoalWeak,
      skillLevel: profile.skillLevel,
      dailyMinutes: profile.dailyMinutesGoal ?? 15,
      focus: effectiveFocus,
      language: languageName,
      moduleCount: moduleCount,
      ragContextBlock: rag.promptBlock,
      topicResolutionBlock: topicResolution.resolutionBlock,
    );

    final sw = Stopwatch()..start();
    try {
      final raw = await llmManager.completeJson(
        userPrompt: prompt,
        recordBuiltinQuota: false,
        validateContent: (content) {
          try {
            PathJsonParser.parse(content);
            return true;
          } catch (_) {
            return false;
          }
        },
      );
      final usage = LastAiUsage.consume();
      final parsed = PathJsonParser.parse(raw);
      final generated = await ResourceLinkValidator.verifyYouTubeEmbeds(
        parsed,
        pathGoal: effectiveFocus,
      );
      final stepsJson = generated.steps
          .map((s) => s.toJson())
          .toList();
      final path = await learnerRepository.savePath(
        title: generated.title,
        topics: generated.steps.map((s) => s.title).toList(),
        source: 'ai',
        steps: stepsJson,
      );
      if (resolved.providerKey == BuiltInAiConfig.uuid) {
        await BuiltInAiQuota.instance.recordGeneration();
      }
      sw.stop();
      await llmTelemetry?.recordCall(
        providerKey: resolved.providerKey,
        task: 'path_generation',
        latencyMs: sw.elapsedMilliseconds,
        success: true,
        promptTokens: usage?.promptTokens ?? 0,
        completionTokens: usage?.completionTokens ?? 0,
      );
      for (final step in generated.steps) {
        await vectorStore.upsertTopic(step.title);
      }
      await telemetry.emit('path_created', {'uuid': path.uuid, 'focus': effectiveFocus, 'source': 'ai'});
      return path.uuid;
    } catch (e) {
      sw.stop();
      await llmTelemetry?.recordCall(
        providerKey: resolved.providerKey,
        task: 'path_generation',
        latencyMs: sw.elapsedMilliseconds,
        success: false,
        errorKind: e.runtimeType.toString(),
      );
      rethrow;
    }
  }

  Future<String> _generateVectorPath(String focus) async {
    final related = await vectorStore.similar(focus, limit: 4);
    final topics = [focus, ...related.map((e) => e.topic)];
    final path = await learnerRepository.savePath(
      title: 'Path: $focus',
      topics: topics,
      source: 'ml',
    );
    await telemetry.emit('path_created', {'uuid': path.uuid, 'focus': focus});
    return path.uuid;
  }

  /// Ensures the user-chosen engine (local or cloud) is ready before generation.
  Future<void> validateQuizProviders() async {
    await llmManager.validateReady();
  }

  Future<String> runQuizGeneration({
    required String topic,
    int questionCount = 20,
    String difficulty = 'medium',
    String questionType = 'mcq',
    String? language,
    bool explanations = true,
    bool randomizeQuestions = true,
    bool randomizeOptions = true,
    int? timerSeconds,
    LearningPatternContext? learningPattern,
    String quizKind = QuizKind.quick,
    String? pathId,
    int? moduleIndex,
    int? examDurationSeconds,
    int? passPercent,
    String? syllabusUuid,
    List<String>? unitFilter,
    int? attemptNumber,
    String? generationMode,
    bool countBuiltinQuota = true,
    String? interviewPersona,
    bool voiceInterviewOnly = false,
    List<String>? syllabusUnitTitles,
  }) async {
    try {
      await NetworkService.instance.ensureConnected();
    } on NoInternetException {
      rethrow;
    } catch (_) {
      // Unexpected platform error from connectivity check: skip the gate.
    }
    await ensureStrategies();
    await AiConsentGate.instance.load();
    final settings = await profileRepository.getSettings();
    final profile = await learnerRepository.getOrCreateProfile();
    final effectiveLanguage = language ?? aiLanguageName(settings.language);

    var effectiveQuestionCount = questionCount;

    final firewallResult = await aiPipeline.sanitizeTopic(topic);
    if (firewallResult.blocked) {
      throw TopicNotAllowedException(firewallResult.reason ?? 'Topic not allowed.');
    }
    await aiPipeline.ensureTokenBudget();

    final topicResolution = await _resolveTopicForGeneration(firewallResult.sanitized);
    final effectiveTopic = topicResolution.topic;

    final enabledSources = await knowledgeRepository.enabledSourceUuids(profile.goalMode);
    final sourceTypes = await knowledgeRepository.enabledSourceTypes(profile.goalMode);
    final effectiveMode = generationMode ??
        (enabledSources.isNotEmpty ? 'grounded' : null);
    final rag = await aiPipeline.buildRag(
      AiRequestContext(
        task: 'quiz',
        providerKey: 'pending',
        goalMode: profile.goalMode,
        topic: effectiveTopic,
        enabledSourceUuids: enabledSources,
        sourceTypes: sourceTypes,
        generationMode: effectiveMode,
      ),
    );

    final strategy = await _pickStrategy();
    final resolved = await llmManager.resolve();

    ProviderFactory? fallbackFactory;
    String? fallbackKey;
    {
      final providers = await providerRepository.getAll();
      final router =
          ProviderRouter(circuitBreaker: circuitBreaker, usageTracker: llmTelemetry?.usageTracker);
      final pick = await router.pickProviders(providers: providers, task: 'quiz');
      final fallback = pick.fallbacks.isNotEmpty ? pick.fallbacks.first : null;
      if (fallback != null) {
        final key = await providerRepository.getApiKey(fallback.uuid);
        if (key != null && key.isNotEmpty) {
          fallbackKey = fallback.uuid;
          fallbackFactory = () => AiProviderFactory.create(config: fallback, apiKey: key);
        }
      }
    }

    final resilient = ResilientAiProvider(
      primaryKey: resolved.providerKey,
      primaryFactory: () => resolved.quizProvider,
      fallbackKey: fallbackKey,
      fallbackFactory: fallbackFactory,
      circuitBreaker: circuitBreaker,
      healthMonitor: healthMonitor,
      telemetry: telemetry,
      llmTelemetry: llmTelemetry,
    );

    final useSimplified = strategy.strategyId == 'simplified';
    if (useSimplified) {
      resilient.useSimplifiedStrategy();
    }

    LearningPatternContext? pattern = learningPattern;
    if (pattern == null) {
      final node = await learnerRepository.allTopics();
      final match = node.where((n) => n.topic.toLowerCase() == topic.toLowerCase()).firstOrNull;
      if (match != null) {
        final accuracy = match.attempts > 0 ? match.correctCount / match.attempts : null;
        pattern = LearningPatternContext(
          moduleTitle: topic,
          priorAccuracy: accuracy,
        );
      }
    }

    final request = QuizGenerationRequest(
      topic: effectiveTopic,
      questionCount: effectiveQuestionCount,
      difficulty: difficulty,
      questionType: questionType,
      language: effectiveLanguage,
      randomizeQuestions: randomizeQuestions,
      randomizeOptions: randomizeOptions,
      generateExplanations: explanations && strategy.strategyId != 'simplified',
      timerSeconds: timerSeconds,
      learningPattern: pattern,
      ragContextBlock: rag.promptBlock,
      citationChunkIds: rag.chunkIds,
      learnerGoals: learnerRepository.goalsOf(profile),
      skillLevel: profile.skillLevel,
      interviewPersona: interviewPersona,
      voiceInterviewOnly: voiceInterviewOnly,
      goalMode: profile.goalMode,
      examType: profile.examType,
      examName: profile.goalContext.isNotEmpty ? profile.goalContext : null,
      syllabusUnitTitles: syllabusUnitTitles ?? const [],
      topicResolutionBlock: topicResolution.resolutionBlock,
    );

    await telemetry.emit('quiz_started', {
      'topic': topic,
      'strategy': strategy.strategyId,
      'ragChunks': rag.chunkIds.length,
    });
    AppLogger.debug('Orchestrator', 'Generating quiz - topic: $topic, provider: ${resolved.providerLabel}, strategy: ${strategy.strategyId}');
    try {
      final builtinPrimary = resolved.providerKey == BuiltInAiConfig.uuid;
      if (builtinPrimary && countBuiltinQuota) {
        final snap = await BuiltInAiQuota.instance.load();
        if (!snap.canGenerate) {
          if (fallbackFactory == null || fallbackKey == null) {
            throw const BuiltInQuotaExceededException();
          }
          // Prefer BYOK fallback instead of blocking when Built-in quota is exhausted.
          resilient.skipPrimary = true;
        }
      }
      final generated = await resilient.generateQuiz(request);
      AppLogger.debug('Orchestrator', 'Quiz generated - ${generated.questions.length} questions');
      var quizToSave = generated;
      if (voiceInterviewOnly) {
        final openOnly = generated.questions.where(_isVoiceOpenQuestion).toList();
        if (openOnly.isNotEmpty) {
          quizToSave = GeneratedQuiz(questions: openOnly);
        }
      }
      if (quizKind == QuizKind.interview &&
          await knowledgeRepository.hasIndexedType(profile.goalMode, 'resume')) {
        const selfIntro = GeneratedQuestion(
          text: 'Tell me about yourself.',
          options: ['__open__'],
          correctIndex: 0,
          type: 'behavioral',
          explanation:
              'Structure a 60–90 second pitch using your resume: current role, relevant achievements, '
              'and why this opportunity fits your goals. Reference specific experience from your uploaded resume.',
        );
        quizToSave = GeneratedQuiz(questions: [selfIntro, ...generated.questions]);
      }
      final usage = LastAiUsage.consume();
      final session = await quizRepository.saveGeneratedQuiz(
        request: request,
        generated: quizToSave,
        quizKind: quizKind,
        pathId: pathId,
        moduleIndex: moduleIndex,
        promptTokens: usage?.promptTokens,
        completionTokens: usage?.completionTokens,
        examDurationSeconds: examDurationSeconds,
        passPercent: passPercent,
        syllabusUuid: syllabusUuid,
        unitFilter: unitFilter,
        attemptNumber: attemptNumber,
        citationChunkIds: request.citationChunkIds,
      );
      if (countBuiltinQuota &&
          resilient.lastSucceededProviderKey == BuiltInAiConfig.uuid) {
        await BuiltInAiQuota.instance.recordGeneration();
      }
      await _recordStrategy(strategy.strategyId, success: true);
      await vectorStore.upsertTopic(topic);
      await healthMonitor.persist();
      return session.uuid;
    } catch (e, st) {
      AppLogger.error('Orchestrator', 'Quiz generation failed', e, st);
      await _recordStrategy(strategy.strategyId, success: false);
      await healthMonitor.persist();
      rethrow;
    }
  }

  Future<PromptStrategy> _pickStrategy() async {
    final all = await _db.promptStrategys.where().findAll();
    all.sort((a, b) => (b.weight * b.successRate).compareTo(a.weight * a.successRate));
    return all.first;
  }

  Future<void> _recordStrategy(String id, {required bool success}) async {
    final row = await _db.promptStrategys.filter().strategyIdEqualTo(id).findFirst();
    if (row == null) return;
    row
      ..attempts += 1
      ..successes += success ? 1 : 0
      ..successRate = row.successes / row.attempts
      ..weight = (row.weight + (success ? 0.05 : -0.05)).clamp(0.2, 2.0)
      ..updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.promptStrategys.put(row);
    });
  }

  Future<String> summarizeWeaknesses() async {
    final weak = await learnerRepository.weakTopics(limit: 5);
    if (weak.isEmpty) return 'No weak topics yet. Take a quiz to build your profile.';
    final lines = weak
        .map((t) => '• ${t.topic} (mastery ${(t.strength * 100).round()}%)')
        .join('\n');
    return 'Focus areas:\n$lines';
  }

  /// Structured notes for a path module. Prefers YouTube transcript; falls back to titles/links.
  Future<ModuleNotesResult> summarizeModule({
    required String moduleTitle,
    required String moduleSummary,
    String? youtubeVideoId,
    List<PathResourceData> resources = const [],
  }) async {
    await NetworkService.instance.ensureConnected();
    await aiPipeline.ensureTokenBudget();

    var transcript = '';
    final videoId = youtubeVideoId?.trim();
    if (videoId != null && videoId.isNotEmpty) {
      transcript = await YoutubeTranscriptFetcher.fetchTranscript(videoId);
    }
    final usedTranscript = transcript.isNotEmpty;

    var articleText = '';
    if (!usedTranscript) {
      for (final r in resources) {
        if (r.type == 'video' || r.url.trim().isEmpty) continue;
        articleText = await ResourceLinkValidator.fetchArticleText(r.url);
        if (articleText.isNotEmpty) break;
      }
    }

    final resourceBlock = resources.isEmpty
        ? '(none)'
        : resources
            .map((r) => '- ${r.title} [${r.domain}] ${r.url}')
            .join('\n');

    final String sourceBlock;
    final String groundingRules;
    if (usedTranscript) {
      groundingRules =
          'PRIMARY SOURCE: the video transcript below. Ground EVERY fact, definition, '
          'and example ONLY in that transcript. You may use the module title to name '
          'sections. Do NOT invent content from resource links. Do NOT mention whether '
          'a transcript was used inside the notes body.';
      sourceBlock = '\nVideo transcript:\n$transcript';
    } else if (articleText.isNotEmpty) {
      groundingRules =
          'PRIMARY SOURCE: the article excerpt below. Ground notes in that text plus the module title. '
          'Do NOT invent facts. Do NOT mention source metadata inside the notes body.';
      sourceBlock = '\nArticle excerpt:\n$articleText';
    } else {
      groundingRules =
          'No video captions or reachable article text. Use the module summary and resource titles only. '
          'If those are empty, write a short beginner outline of the module title itself. '
          'Do NOT claim a transcript was used. Do NOT mention source metadata inside the notes body.';
      sourceBlock = '';
    }

    final userPrompt = '''
Write structured study notes for this learning module as Markdown.
$groundingRules

Use this Markdown structure:
# Module overview
## Key takeaways
- bullet points
## Concepts
### Subtopic (as needed)
- bullets; include fenced code blocks with language tags when helpful
## What to practice next
- short actionable bullets

Return a single JSON object only:
{"notes":"# Module overview\\n..."}

Module title: $moduleTitle
Existing summary: ${moduleSummary.isEmpty ? '(empty)' : moduleSummary}
${usedTranscript ? '' : 'Resources:\n$resourceBlock'}
$sourceBlock
''';

    final raw = await llmManager.completeJson(
      userPrompt: userPrompt,
      systemPrompt:
          'You are a study coach. Respond with a single valid JSON object only. No markdown fences around the JSON.',
      recordBuiltinQuota: true,
      validateContent: (content) => _parseModuleNotesResult(content) != null,
    );
    final parsed = _parseModuleNotesResult(raw);
    final notes = parsed?.notes ?? _stripLeakage(raw.trim());
    return ModuleNotesResult(
      notes: notes,
      usedTranscript: usedTranscript,
    );
  }

  static ModuleNotesResult? _parseModuleNotesResult(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final map = jsonDecode(raw.substring(start, end + 1));
      if (map is! Map || map['notes'] == null) return null;
      final notes = _stripLeakage(map['notes'].toString().trim());
      if (notes.isEmpty) return null;
      // usedTranscript is decided by the caller from the fetch result, not the LLM.
      return ModuleNotesResult(notes: notes, usedTranscript: false);
    } catch (_) {
      return null;
    }
  }

  static String _stripLeakage(String notes) {
    return notes
        .replaceAll(RegExp(r'usedTranscript\s*[:=]\s*(true|false)', caseSensitive: false), '')
        .replaceAll(RegExp(r'"usedTranscript"\s*:\s*(true|false),?'), '')
        .replaceAll(RegExp(r'"source"\s*:\s*"(transcript|titles)",?'), '')
        .replaceAll(RegExp(r'source\s*[:=]\s*(transcript|titles)', caseSensitive: false), '')
        .trim();
  }

  static bool _isVoiceOpenQuestion(GeneratedQuestion q) {
    final t = q.type.toLowerCase();
    if (t == 'short_answer' || t == 'behavioral' || t == 'open') return true;
    return q.options.length == 1 && q.options.first == '__open__';
  }

  Future<({String topic, String resolutionBlock})> _resolveTopicForGeneration(
    String topic,
  ) async {
    final resolver = GoalTopicResolver(llmManager: llmManager);
    final resolved = await resolver.resolve(topic);
    if (resolved == null) {
      return (topic: topic, resolutionBlock: '');
    }
    return (
      topic: resolved.effectiveTopic,
      resolutionBlock: resolved.promptBlock,
    );
  }
}

class ModuleNotesResult {
  const ModuleNotesResult({
    required this.notes,
    required this.usedTranscript,
  });

  final String notes;
  final bool usedTranscript;
}
