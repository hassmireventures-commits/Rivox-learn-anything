import 'dart:convert';

import 'package:ai_quiz_app/core/ai_platform/output_validator.dart';
import 'package:ai_quiz_app/core/services/ai_study_pulse_service.dart';
import 'package:ai_quiz_app/core/services/built_in_ai_config.dart';
import 'package:ai_quiz_app/core/services/built_in_ai_router.dart';
import 'package:ai_quiz_app/data/remote/ai/ai_output_gate.dart';
import 'package:ai_quiz_app/data/remote/ai/path_json_parser.dart';
import 'package:ai_quiz_app/data/remote/ai/path_prompt_builder.dart';
import 'package:ai_quiz_app/data/remote/ai/quiz_json_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Live probe: exact generation prompts × each Built-in NIM model, scored 0–10.
void main() {
  final apiKey = BuiltInAiConfig.apiKey;

  if (apiKey.isEmpty) {
    test('skipped — set BUILT_IN_AI_API_KEY via --dart-define-from-file', () {},
        skip: 'No API key');
    return;
  }

  group('Model generation live probe', () {
    test('router chain (app behavior) scores 10/10 on all tasks', () async {
      final probe = _ModelProbe(apiKey: apiKey);
      final results = await probe.runAllViaRouter();
      _printReport('BuiltInAiRouter chain', results);
      for (final r in results) {
        expect(
          r.score,
          10,
          reason: '${r.task} via router scored ${r.score}/10: ${r.issues.join('; ')}',
        );
      }
    }, timeout: const Timeout(Duration(minutes: 15)));

    test('primary model alone scores 10/10 on all tasks', () async {
      final probe = _ModelProbe(apiKey: apiKey, model: BuiltInAiRouter.primaryModel);
      final results = await probe.runAll();
      _printReport(BuiltInAiRouter.primaryModel, results);
      for (final r in results) {
        expect(r.score, 10, reason: '${r.task}: ${r.issues.join('; ')}');
      }
    }, timeout: const Timeout(Duration(minutes: 12)));

    test('fallback model scores 10/10 on all tasks', () async {
      final fallback = BuiltInAiConfig.fallbackModel;
      final probe = _ModelProbe(apiKey: apiKey, model: fallback);
      final results = await probe.runAll();
      _printReport('$fallback (fallback)', results);
      for (final r in results) {
        expect(r.score, 10, reason: '${r.task}: ${r.issues.join('; ')}');
      }
    }, timeout: const Timeout(Duration(minutes: 15)));
  });
}

class _ProbeResult {
  _ProbeResult({
    required this.task,
    required this.score,
    required this.issues,
    required this.latencyMs,
  });

  final String task;
  final int score;
  final List<String> issues;
  final int latencyMs;
}

class _ModelProbe {
  _ModelProbe({required this.apiKey, this.model = BuiltInAiRouter.primaryModel});

  final String apiKey;
  final String model;
  final _dio = Dio(
    BaseOptions(
      baseUrl: BuiltInAiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Authorization': 'Bearer '},
    ),
  );

  Future<List<_ProbeResult>> runAllViaRouter() async {
    _dio.options.headers!['Authorization'] = 'Bearer $apiKey';
    return [
      await _runViaRouter('pulse', _pulsePrompts(), _scorePulse, maxTokens: 256),
      await _runViaRouter('quiz', _quizPrompts(), _scoreQuiz, maxTokens: 1800),
      await _runViaRouter('path', _pathPrompts(), _scorePath, maxTokens: 3072),
      await _runViaRouter('daily_article', _dailyArticlePrompts(), _scoreDailyArticle),
      await _runViaRouter('daily_video', _dailyVideoPrompts(), _scoreDailyVideo),
      await _runViaRouter('goal_topic', _goalTopicPrompts(), _scoreGoalTopic),
      await _runViaRouter('guardrail', _guardrailPrompts(), _scoreGuardrail),
      await _runViaRouter('module_notes', _moduleNotesPrompts(), _scoreModuleNotes, maxTokens: 2048),
      await _runViaRouter('interview_score', _interviewPrompts(), _scoreInterview),
    ];
  }

  Future<_ProbeResult> _runViaRouter(
    String task,
    ({String system, String user}) prompts,
    int Function(String raw) scorer, {
    int maxTokens = 512,
  }) async {
    final sw = Stopwatch()..start();
    try {
      final raw = await BuiltInAiRouter.withModelFallback(
        configuredModel: model,
        attempt: (activeModel) async {
          final content = await _completeWithRetry(
            system: prompts.system,
            user: prompts.user,
            maxTokens: maxTokens,
            modelOverride: activeModel,
          );
          if (task == 'module_notes') {
            if (!_acceptsModuleNotes(content)) {
              throw UnusableModelOutputException('$task invalid notes');
            }
            return content;
          }
          final score = scorer(content);
          if (score < 8) {
            throw UnusableModelOutputException('$task score=$score');
          }
          if (AiOutputGate.isInstructionLeak(content)) {
            throw UnusableModelOutputException('$task leak');
          }
          return content;
        },
      );
      sw.stop();
      return _ProbeResult(
        task: task,
        score: scorer(raw),
        issues: const [],
        latencyMs: sw.elapsedMilliseconds,
      );
    } catch (e) {
      sw.stop();
      return _ProbeResult(
        task: task,
        score: 0,
        issues: [e.toString()],
        latencyMs: sw.elapsedMilliseconds,
      );
    }
  }

  Future<List<_ProbeResult>> runAll() async {
    _dio.options.headers!['Authorization'] = 'Bearer $apiKey';
    return [
      await _runTask('pulse', _pulsePrompts(), _scorePulse, maxTokens: 256),
      await _runTask('quiz', _quizPrompts(), _scoreQuiz, maxTokens: 1800),
      await _runTask('path', _pathPrompts(), _scorePath, maxTokens: 3072),
      await _runTask('daily_article', _dailyArticlePrompts(), _scoreDailyArticle),
      await _runTask('daily_video', _dailyVideoPrompts(), _scoreDailyVideo),
      await _runTask('goal_topic', _goalTopicPrompts(), _scoreGoalTopic),
      await _runTask('guardrail', _guardrailPrompts(), _scoreGuardrail),
      await _runTask('module_notes', _moduleNotesPrompts(), _scoreModuleNotes, maxTokens: 2048),
      await _runTask('interview_score', _interviewPrompts(), _scoreInterview),
    ];
  }

  Future<_ProbeResult> _runTask(
    String task,
    ({String system, String user}) prompts,
    int Function(String raw) scorer, {
    int maxTokens = 512,
  }) async {
    final sw = Stopwatch()..start();
    final issues = <String>[];
    try {
      final raw = await _completeWithRetry(
        system: prompts.system,
        user: prompts.user,
        maxTokens: maxTokens,
      );
      sw.stop();
      final score = scorer(raw);
      return _ProbeResult(
        task: task,
        score: score,
        issues: issues,
        latencyMs: sw.elapsedMilliseconds,
      );
    } catch (e) {
      sw.stop();
      issues.add(e.toString());
      return _ProbeResult(
        task: task,
        score: 0,
        issues: issues,
        latencyMs: sw.elapsedMilliseconds,
      );
    }
  }

  Future<String> _complete({
    required String system,
    required String user,
    required int maxTokens,
    String? modelOverride,
    bool strictRetry = false,
  }) async {
    final activeModel = modelOverride ?? model;
    final effectiveMax = AiOutputGate.isReasoningChannelModel(activeModel)
        ? (maxTokens * 1.35).round().clamp(maxTokens, 4096)
        : maxTokens;
    final payload = <String, dynamic>{
        'model': activeModel,
        'temperature': AiOutputGate.temperatureForModel(
          activeModel,
          BuiltInAiConfig.temperature,
        ),
        'top_p': BuiltInAiConfig.topP,
        'max_tokens': effectiveMax,
        'messages': [
          {
            'role': 'system',
            'content': AiOutputGate.adaptSystemPrompt(
              strictRetry
                  ? '$system\n\nYour last answer was invalid. Output ONLY valid JSON with real values.'
                  : system,
              activeModel,
            ),
          },
          {
            'role': 'user',
            'content': AiOutputGate.adaptUserPrompt(user, activeModel),
          },
        ],
      };
    if (AiOutputGate.useJsonObjectResponseFormat(activeModel)) {
      payload['response_format'] = {'type': 'json_object'};
    }
    payload.addAll(AiOutputGate.requestExtrasForModel(activeModel));
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/completions',
      data: payload,
    );
    final choices = response.data?['choices'];
    if (choices is! List || choices.isEmpty) {
      throw StateError('empty choices');
    }
    final message = choices.first['message'];
    final content = AiOutputGate.normalizeFromOpenAiMessage(
      message,
      modelId: activeModel,
    );
    if (content == null || content.trim().isEmpty) {
      throw StateError('empty content');
    }
    return content;
  }

  Future<String> _completeWithRetry({
    required String system,
    required String user,
    required int maxTokens,
    String? modelOverride,
  }) async {
    final activeModel = modelOverride ?? model;
    try {
      final first = await _complete(
        system: system,
        user: user,
        maxTokens: maxTokens,
        modelOverride: modelOverride,
      );
      if (AiOutputGate.acceptsJsonObject(first) ||
          !AiOutputGate.isReasoningChannelModel(activeModel)) {
        return first;
      }
    } catch (_) {}
    return _complete(
      system: system,
      user: user,
      maxTokens: maxTokens,
      modelOverride: modelOverride,
      strictRetry: true,
    );
  }

  ({String system, String user}) _pulsePrompts() => (
        system:
            'You are a concise study coach. Respond with a single valid JSON object only. No markdown.',
        user: '''
Goal: Learn Python
Topics: variables, loops
Respond with one JSON object: {"brief":"two short encouraging sentences"}
''',
      );

  ({String system, String user}) _quizPrompts() => (
        system:
            'You are a quiz generator. Respond with a single valid JSON object only. '
            'No markdown, no code fences, no commentary. '
            'The questions array length must exactly match the Count in the user message — never add extra questions. '
            'Each explanation must match the option at correctIndex.',
        user: '''
Quiz generator. Reply with VALID JSON only (no markdown).

MANDATORY (must satisfy every line — wrong counts are rejected):
- User-selected count: 5 (app only allows: 5, 10, 15, 20)
- questions array length: exactly 5 items — no more, no fewer
- Topic: Python variables and data types
- Difficulty: easy
- Question format: All MCQ with exactly 4 options.
- Language: English (all question and option text in this language)
- Unique question stems only (no duplicate or near-duplicate questions)
BEGINNER TRACK: assume ZERO prior knowledge. Ask the most foundational questions within the EXACT subfield named in the topic — start from absolute basics, not intermediate concepts. No advanced jargon, no expert-only traps.
Non-empty short explanation per question (never null).
Rules: correctIndex is 0-based and must match the true answer; unique plausible options with full answer text (never letter-only like "A","B","C","D"); return exactly 5 questions.

Schema (questions array must contain exactly 5 objects like this):
{"questions":[{"text":"What is 2+2?","options":["3","4","5","6"],"correctIndex":1,"type":"mcq","explanation":"Because 2+2 equals 4."}]}
''',
      );

  ({String system, String user}) _pathPrompts() => (
        system:
            'You are a curriculum designer. Respond with a single valid JSON object only. No markdown.',
        user: PathPromptBuilder.build(
          goals: const ['Azure DevOps pipelines'],
          weakTopics: const [],
          skillLevel: 0.2,
          dailyMinutes: 15,
          focus: 'Azure DevOps CI/CD',
          language: 'English',
          moduleCount: 4,
        ),
      );

  ({String system, String user}) _dailyArticlePrompts() => (
        system:
            'You are a curriculum curator. Respond with a single valid JSON object only. No markdown.',
        user: '''
Pick one FREE, real article/tutorial for this topic: "Python variables".
Return a single JSON object only:
{"type":"article","title":"...","url":"https://...","summary":"1-2 sentences"}

Rules:
- Title and summary must be clearly about "Python variables".
- URL must be a real article page (not a site homepage or search results).
- Use ONLY https URLs on: en.wikipedia.org, www.w3schools.com, www.geeksforgeeks.org, docs.python.org
''',
      );

  ({String system, String user}) _dailyVideoPrompts() => (
        system:
            'You are a curriculum curator. Respond with a single valid JSON object only. No markdown.',
        user: '''
Pick one FREE, real YouTube tutorial video for this topic: "Python variables".
Return a single JSON object only:
{"type":"video","title":"...","url":"https://www.youtube.com/watch?v=VIDEO_ID","summary":"1-2 sentences"}

Rules:
- Title and summary must be clearly about "Python variables".
- URL must be a real watch URL with an 11-character video ID.
''',
      );

  ({String system, String user}) _goalTopicPrompts() => (
        system:
            'You infer what a learner wants to study from short or opaque goal labels '
            '(company names, product names, domains like elsai.ai). '
            'Use general knowledge; if unknown, infer from the name and domain. '
            'Respond with a single valid JSON object only. No markdown.',
        user: '''
The learner set this study goal: "elsai.ai"

Think first: what do they most likely want to learn? If it is a company, startup, SaaS product, or domain name, describe what that organization/product does and what skills or knowledge someone studying it should focus on.

Return JSON only:
{
  "effectiveTopic": "short human-readable topic (5-12 words)",
  "learningScope": "2-4 sentences: what to teach, quiz, or recommend. Be specific to this org/product.",
  "avoid": ["list", "of", "irrelevant", "tangents", "to", "exclude"]
}
''',
      );

  ({String system, String user}) _guardrailPrompts() => (
        system: 'You are a study-goal classifier. Respond with a single valid JSON object only.',
        user: '''
Decide if this quiz topic fits the learner's study goals.
Goals: Learn Python; Python basics
Quiz topic: PyTorch tensors
Related libraries/frameworks/subtopics of a goal count as related (e.g. PyTorch for Python).
Unrelated domains count as not related.

Return JSON only: {"related":true|false,"confidence":0.0-1.0,"reason":"short"}
''',
      );

  ({String system, String user}) _moduleNotesPrompts() => (
        system:
            'You are a study coach. Respond with a single valid JSON object only. No markdown fences around the JSON.',
        user: '''
Write structured study notes for this learning module as Markdown.
No video captions or reachable article text. Use the module summary and resource titles only.
If those are empty, write a short beginner outline of the module title itself.

Use this Markdown structure:
# Module overview
## Key takeaways
- bullet points
## Concepts
## What to practice next

Return a single JSON object only:
{"notes":"# Module overview\\n..."}

Module title: Python variables
Existing summary: Intro to storing data in Python
Resources:
- W3Schools Python Variables [w3schools.com] https://www.w3schools.com/python/python_variables.asp
''',
      );

  ({String system, String user}) _interviewPrompts() => (
        system:
            'You are an interview judge. Respond with JSON only: {"score":0.0,"feedback":"..."}. score is 0 - 1.',
        user: '''
Role / company context: Junior Python developer
Question: Explain how you would debug a failing unit test.
Rubric: mentions isolation, reading traceback, minimal reproduction
Candidate answer: I would read the traceback, reproduce with minimal code, and fix the assertion.
''',
      );

  int _scorePulse(String raw) {
    try {
      final map = jsonDecode(AiOutputGate.extractJsonObject(raw));
      if (map is! Map) return 2;
      final brief = map['brief']?.toString();
      if (brief == null) return 4;
      if (!AiStudyPulseService.isValidBrief(brief)) return 6;
      return 10;
    } catch (_) {
      return 0;
    }
  }

  int _scoreQuiz(String raw) {
    try {
      final quiz = QuizJsonParser.parse(raw, expectedCount: 5);
      if (quiz.questions.length != 5) return 6;
      const validator = OutputValidator();
      final map = jsonDecode(AiOutputGate.extractJsonObject(raw)) as Map;
      final check = validator.validateQuizJson(Map<String, dynamic>.from(map));
      return check.valid ? 10 : 7;
    } catch (_) {
      return 0;
    }
  }

  int _scorePath(String raw) {
    try {
      PathJsonParser.parse(raw);
      return 10;
    } catch (_) {
      return 0;
    }
  }

  int _scoreDailyArticle(String raw) {
    try {
      final map = jsonDecode(AiOutputGate.extractJsonObject(raw));
      if (map is! Map) return 2;
      if (map['type']?.toString() != 'article') return 4;
      final url = map['url']?.toString() ?? '';
      if (!url.startsWith('https://')) return 6;
      if (map['title']?.toString().trim().isEmpty ?? true) return 7;
      return 10;
    } catch (_) {
      return 0;
    }
  }

  int _scoreDailyVideo(String raw) {
    try {
      final map = jsonDecode(AiOutputGate.extractJsonObject(raw));
      if (map is! Map) return 2;
      if (map['type']?.toString() != 'video') return 4;
      final url = map['url']?.toString() ?? '';
      if (!url.contains('youtube.com/watch?v=')) return 6;
      final id = url.split('v=').last.split('&').first;
      if (id.length != 11) return 7;
      return 10;
    } catch (_) {
      return 0;
    }
  }

  int _scoreGoalTopic(String raw) {
    try {
      final map = jsonDecode(AiOutputGate.extractJsonObject(raw));
      if (map is! Map) return 2;
      final topic = map['effectiveTopic']?.toString().trim() ?? '';
      final scope = map['learningScope']?.toString().trim() ?? '';
      if (topic.length < 5 || scope.length < 20) return 6;
      return 10;
    } catch (_) {
      return 0;
    }
  }

  int _scoreGuardrail(String raw) {
    try {
      final map = jsonDecode(AiOutputGate.extractJsonObject(raw));
      if (map is! Map) return 2;
      if (map['related'] is! bool) return 5;
      final conf = map['confidence'];
      if (conf is! num) return 7;
      if (conf < 0 || conf > 1) return 8;
      return 10;
    } catch (_) {
      return 0;
    }
  }

  bool _acceptsModuleNotes(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return false;
      final map = jsonDecode(raw.substring(start, end + 1));
      if (map is! Map || map['notes'] == null) return false;
      return map['notes'].toString().trim().length >= 40;
    } catch (_) {
      return false;
    }
  }

  int _scoreModuleNotes(String raw) => _acceptsModuleNotes(raw) ? 10 : 0;

  int _scoreInterview(String raw) {
    try {
      final map = jsonDecode(AiOutputGate.extractJsonObject(raw));
      if (map is! Map) return 2;
      final score = map['score'];
      if (score is! num) return 5;
      if (score < 0 || score > 1) return 7;
      if ((map['feedback']?.toString().trim().isEmpty ?? true)) return 8;
      return 10;
    } catch (_) {
      return 0;
    }
  }
}

void _printReport(String model, List<_ProbeResult> results) {
  // ignore: avoid_print
  print('\n=== Model probe: $model ===');
  for (final r in results) {
    // ignore: avoid_print
    print(
      '${r.task.padRight(14)} ${r.score.toString().padLeft(2)}/10  '
      '${r.latencyMs}ms  ${r.issues.isEmpty ? 'ok' : r.issues.join(', ')}',
    );
  }
  final avg = results.isEmpty
      ? 0
      : results.map((r) => r.score).reduce((a, b) => a + b) / results.length;
  // ignore: avoid_print
  print('Average: ${avg.toStringAsFixed(1)}/10\n');
}
