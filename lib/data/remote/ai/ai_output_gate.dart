import 'dart:convert';

import '../../../core/error/app_exception.dart';
import 'ai_response_utils.dart';

/// Shared output rules for every AI provider (Built-in and BYOK).
class AiOutputGate {
  AiOutputGate._();

  /// Models that may return JSON in `reasoning_content` with an empty content stub.
  static bool isReasoningChannelModel(String? modelId) {
    final id = modelId?.toLowerCase() ?? '';
    return id.contains('nemotron') || id.contains('-nano-') || id.contains('reason');
  }

  /// Nemotron-style models emit valid JSON in `content` only without `json_object` mode.
  static bool useJsonObjectResponseFormat(String? modelId) {
    return !isReasoningChannelModel(modelId);
  }

  /// Disables chain-of-thought so JSON lands in `content` (required for long path prompts).
  static Map<String, dynamic> requestExtrasForModel(String? modelId) {
    if (!isReasoningChannelModel(modelId)) return const {};
    return {
      'chat_template_kwargs': {'enable_thinking': false},
    };
  }

  /// Strengthens system prompts for reasoning-channel models.
  static String adaptSystemPrompt(String system, String modelId) {
    if (!isReasoningChannelModel(modelId)) return system;
    return '$system\n\n'
        'CRITICAL Nemotron rules:\n'
        '- Put the COMPLETE final JSON in the content field.\n'
        '- Use REAL values only — never "..." or placeholder text.\n'
        '- Do NOT describe the JSON — output it.\n'
        '- No reasoning, planning, or commentary outside JSON.';
  }

  /// Appends output constraints for reasoning-channel models.
  static String adaptUserPrompt(String user, String modelId) {
    if (!isReasoningChannelModel(modelId)) return user;
    return '$user\n\n'
        'Respond with REAL content now (no ellipsis placeholders). '
        'Valid JSON object only.';
  }

  static double temperatureForModel(String modelId, double defaultTemp) {
    if (isReasoningChannelModel(modelId)) return 0.25;
    return defaultTemp;
  }

  /// Appended to system prompts on strict retry (invalid first answer).
  static const strictRetrySuffix =
      '\n\nYour last answer was invalid. Output ONLY valid JSON with real values.';

  static String strictRetrySystemPrompt(String system) => '$system$strictRetrySuffix';

  /// Best-effort JSON string from raw model text (any provider).
  static String? normalizeJsonText(String? raw) => _bestJsonFromText(raw);

  /// True when a second attempt with [strictRetrySystemPrompt] should run.
  static bool needsStrictRetry(
    String? content, {
    bool Function(String normalized)? validateContent,
  }) {
    final normalized = normalizeJsonText(content);
    if (normalized == null || !acceptsJsonObject(normalized)) return true;
    if (validateContent != null && !validateContent(normalized)) return true;
    return false;
  }

  /// Applies 10/10 rules: extract JSON, reject stubs/placeholders, optional task validation.
  static String requireJsonOutput(
    String? raw, {
    bool Function(String normalized)? validateContent,
  }) {
    final normalized = normalizeJsonText(raw);
    if (normalized == null || !acceptsJsonObject(normalized)) {
      throw const InvalidJsonException(
        'AI returned unusable text. Try again or switch model in Settings.',
      );
    }
    if (validateContent != null && !validateContent(normalized)) {
      throw const InvalidJsonException(
        'AI returned invalid content for this task. Try again.',
      );
    }
    return normalized;
  }

  /// Detects chain-of-thought / parroted prompt rules (Nemotron-style leaks).
  static bool isInstructionLeak(String text) {
    final lower = text.toLowerCase();
    const markers = [
      'json only',
      'must be a single valid json',
      'single valid json object',
      'respond with json',
      'no markdown',
      'em dash',
      'en dash',
      "here's a thinking",
      'thinking process',
      'we need to output',
      'the user wants',
      'must not use',
      'must avoid',
      'so we must',
    ];
    if (markers.any(lower.contains)) return true;
    if (text.length > 320 && !text.trim().startsWith('{')) return true;
    return false;
  }

  /// Normalizes OpenAI/NIM message into a JSON payload string for parsers.
  static String? normalizeFromOpenAiMessage(
    dynamic message, {
    required String modelId,
  }) {
    if (message == null) return null;
    if (message is! Map) {
      return _bestJsonFromText(message.toString());
    }
    final map = Map<String, dynamic>.from(message);
    final content = AiResponseUtils.extractOpenAiContent(map['content']);
    final reasoning = AiResponseUtils.extractOpenAiContent(map['reasoning_content']) ??
        AiResponseUtils.extractOpenAiContent(map['reasoning']);

    if (isReasoningChannelModel(modelId)) {
      final fromContent = _bestJsonFromText(content);
      if (fromContent != null && !_isEmptyStubJson(fromContent)) {
        return fromContent;
      }
      final fromReasoning = _bestJsonFromText(reasoning);
      if (fromReasoning != null && !_isEmptyStubJson(fromReasoning)) {
        return fromReasoning;
      }
      final combined = [content, reasoning].whereType<String>().join('\n');
      return _bestJsonFromText(combined);
    }

    return _bestJsonFromText(content) ?? _bestJsonFromText(reasoning);
  }

  /// True when content contains parseable, non-stub JSON.
  static bool acceptsJsonObject(String? content) {
    final json = _bestJsonFromText(content);
    return json != null && !_isEmptyStubJson(json) && !_hasPlaceholderValues(json);
  }

  /// Extracts the best JSON object string from model text.
  static String? _bestJsonFromText(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final sanitized = _sanitizeModelText(raw.trim());

    final direct = _tryParseJson(sanitized);
    if (direct != null) {
      final obj = extractJsonObject(sanitized);
      if (!_isEmptyStubJson(obj)) return obj;
    }

    for (final root in [
      '{"questions"',
      '{"steps"',
      '{"brief"',
      '{"title"',
      '{"type"',
      '{"effectiveTopic"',
      '{"notes"',
      '{"score"',
      '{"related"',
    ]) {
      final idx = sanitized.indexOf(root);
      if (idx < 0) continue;
      final candidate = extractBalancedJson(sanitized.substring(idx), '{', '}');
      if (candidate != null &&
          _tryParseJson(candidate) != null &&
          !_isEmptyStubJson(candidate)) {
        return candidate;
      }
    }

    final questionsOnly = _extractQuestionsArray(sanitized);
    if (questionsOnly != null) return questionsOnly;

    final brief = _repairBriefJson(sanitized);
    if (brief != null) return brief;

    final best = extractBestJsonObject(sanitized);
    if (best != null && !_isEmptyStubJson(best)) return best;

    return _repairSingleQuotedJson(sanitized) ?? best;
  }

  static String _sanitizeModelText(String text) {
    return text
        .replaceAll('\u2019', "'")
        .replaceAll('\u2018', "'")
        .replaceAll('\u201c', '"')
        .replaceAll('\u201d', '"');
  }

  static String? _repairBriefJson(String text) {
    final match = RegExp(
      r'''["']brief["']\s*:\s*["'](.+?)["']''',
      dotAll: true,
    ).firstMatch(text);
    if (match == null) return null;
    var brief = match.group(1)?.trim() ?? '';
    final cut = brief.indexOf("'  ");
    if (cut > 0) brief = brief.substring(0, cut);
    if (brief.length < 8) return null;
    return jsonEncode({'brief': brief});
  }

  static String? _extractQuestionsArray(String text) {
    final idx = text.indexOf('"questions"');
    if (idx < 0) return null;
    final arrStart = text.indexOf('[', idx);
    if (arrStart < 0) return null;
    final arr = extractBalancedJson(text.substring(arrStart), '[', ']');
    if (arr == null) return null;
    try {
      final list = jsonDecode(arr);
      if (list is List && list.isNotEmpty) {
        return jsonEncode({'questions': list});
      }
    } catch (_) {}
    return null;
  }

  static String? _repairSingleQuotedJson(String text) {
    final fixed = text.replaceAllMapped(
      RegExp(r"'([^'\\]*(?:\\.[^'\\]*)*)'"),
      (m) => '"${m[1]!.replaceAll('"', r'\"')}"',
    );
    final candidate = extractBestJsonObject(fixed);
    if (candidate != null &&
        _tryParseJson(candidate) != null &&
        !_isEmptyStubJson(candidate)) {
      return candidate;
    }
    return null;
  }

  /// Extracts the outermost JSON object or array from model text.
  static String extractJsonObject(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) return trimmed;
    final fromObject = extractBalancedJson(trimmed, '{', '}');
    if (fromObject != null) return fromObject;
    return extractBalancedJson(trimmed, '[', ']') ?? trimmed;
  }

  /// Picks the best JSON object when reasoning text contains nested objects.
  static String? extractBestJsonObject(String text) {
    final candidates = <String>[];
    var searchFrom = 0;
    while (searchFrom < text.length) {
      final idx = text.indexOf('{', searchFrom);
      if (idx < 0) break;
      final candidate = extractBalancedJson(text.substring(idx), '{', '}');
      if (candidate != null && _tryParseJson(candidate) != null) {
        candidates.add(candidate);
      }
      searchFrom = idx + 1;
    }
    if (candidates.isEmpty) return null;
    String? best;
    var bestScore = -1;
    for (final candidate in candidates) {
      final score = _jsonCandidateScore(candidate);
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }
    return best;
  }

  static int _jsonCandidateScore(String jsonText) {
    final decoded = _tryParseJson(jsonText);
    if (decoded is! Map) return jsonText.length ~/ 20;
    const preferredKeys = [
      'questions',
      'steps',
      'brief',
      'title',
      'type',
      'effectiveTopic',
      'notes',
      'score',
      'related',
    ];
    var score = jsonText.length ~/ 10;
    for (final key in preferredKeys) {
      if (decoded.containsKey(key)) score += 100;
    }
    return score;
  }

  /// Finds the best valid `{...}` JSON object in [text].
  static String? extractLastValidJsonObject(String text) => extractBestJsonObject(text);

  static String? extractBalancedJson(String text, String open, String close) {
    final start = text.indexOf(open);
    if (start < 0) return null;
    var depth = 0;
    var inString = false;
    var escape = false;
    for (var i = start; i < text.length; i++) {
      final c = text[i];
      if (escape) {
        escape = false;
        continue;
      }
      if (c == r'\' && inString) {
        escape = true;
        continue;
      }
      if (c == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;
      if (c == open) depth++;
      if (c == close) {
        depth--;
        if (depth == 0) return text.substring(start, i + 1);
      }
    }
    return null;
  }

  static dynamic _tryParseJson(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  static bool _isEmptyStubJson(String jsonText) {
    final decoded = _tryParseJson(jsonText);
    if (decoded is! Map) return false;
    final questions = decoded['questions'];
    if (questions is List && questions.isEmpty) return true;
    final steps = decoded['steps'];
    if (steps is List && steps.isEmpty) return true;
    if (decoded.containsKey('brief')) {
      final brief = decoded['brief']?.toString().trim() ?? '';
      if (brief.isEmpty) return true;
    }
    if (decoded.containsKey('notes')) {
      final notes = decoded['notes']?.toString().trim() ?? '';
      if (notes.isEmpty) return true;
    }
    return false;
  }

  static bool _hasPlaceholderValues(String jsonText) {
    return jsonText.contains('"..."') ||
        jsonText.contains("'...'") ||
        jsonText.contains('": "..."') ||
        jsonText.contains('": "…"');
  }

  /// Validates pulse brief text after JSON extraction.
  static bool acceptsPulseBrief(String? brief) {
    if (brief == null || brief.trim().isEmpty) return false;
    if (isInstructionLeak(brief)) return false;
    final stripped =
        brief.replaceAll(RegExp(r'[\s\-–—_.,;:!?]'), '');
    return stripped.length >= 8;
  }
}
