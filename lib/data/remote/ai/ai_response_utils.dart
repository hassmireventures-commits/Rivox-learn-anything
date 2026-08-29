import '../../../core/models/ai_usage_result.dart';

class AiResponseUtils {
  const AiResponseUtils._();

  static String normalizeBaseUrl(String baseUrl) {
    var url = baseUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  /// Extracts assistant text from OpenAI-style `message.content`.
  static String? extractOpenAiContent(dynamic content) {
    if (content == null) return null;
    if (content is String) {
      final text = content.trim();
      return text.isEmpty ? null : text;
    }
    if (content is List) {
      final buffer = StringBuffer();
      for (final part in content) {
        if (part is Map) {
          final text = part['text']?.toString() ?? part['content']?.toString();
          if (text != null && text.isNotEmpty) {
            buffer.write(text);
          }
        } else if (part is String) {
          buffer.write(part);
        }
      }
      final text = buffer.toString().trim();
      return text.isEmpty ? null : text;
    }
    return content.toString().trim().isEmpty ? null : content.toString().trim();
  }

  /// Extracts usable text from a full OpenAI-style `message` object (NIM / Nemotron).
  static String? extractOpenAiMessage(
    dynamic message, {
    bool contentOnly = false,
  }) {
    if (message == null) return null;
    if (message is String) return extractOpenAiContent(message);
    if (message is! Map) return extractOpenAiContent(message);
    final map = Map<String, dynamic>.from(message);
    final primary = extractOpenAiContent(map['content']);
    if (primary != null && primary.isNotEmpty) return primary;
    if (contentOnly) return null;
    for (final key in ['reasoning_content', 'reasoning', 'text', 'output_text']) {
      final alt = extractOpenAiContent(map[key]);
      if (alt != null && alt.isNotEmpty) return alt;
    }
    return null;
  }

  /// Extracts text from Gemini `candidates[0].content.parts`.
  static String? extractGeminiContent(Map<String, dynamic>? data) {
    final candidates = data?['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;

    final first = candidates.first;
    if (first is! Map) return null;

    final finishReason = first['finishReason']?.toString().toUpperCase();
    if (finishReason == 'SAFETY' || finishReason == 'BLOCKED') {
      return null;
    }

    final content = first['content'];
    if (content is! Map) return null;
    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) return null;

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map) {
        final text = part['text']?.toString();
        if (text != null && text.isNotEmpty) {
          buffer.write(text);
        }
      }
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// Extracts text from Claude `content` blocks.
  static String? extractClaudeContent(dynamic contentBlocks) {
    if (contentBlocks is! List || contentBlocks.isEmpty) return null;
    final buffer = StringBuffer();
    for (final block in contentBlocks) {
      if (block is Map && block['type']?.toString() == 'text') {
        final text = block['text']?.toString();
        if (text != null && text.isNotEmpty) {
          buffer.write(text);
        }
      } else if (block is Map) {
        final text = block['text']?.toString();
        if (text != null && text.isNotEmpty) {
          buffer.write(text);
        }
      }
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// Parses OpenAI-compatible `usage` block.
  static AiUsageResult? parseOpenAiUsage(Map<String, dynamic>? data) {
    final usage = data?['usage'];
    if (usage is! Map) return null;
    return AiUsageResult(
      promptTokens: (usage['prompt_tokens'] as num?)?.toInt() ?? 0,
      completionTokens: (usage['completion_tokens'] as num?)?.toInt() ?? 0,
    ).clamped();
  }

  /// Parses Gemini `usageMetadata`.
  static AiUsageResult? parseGeminiUsage(Map<String, dynamic>? data) {
    final usage = data?['usageMetadata'];
    if (usage is! Map) return null;
    var prompt = (usage['promptTokenCount'] as num?)?.toInt() ?? 0;
    var completion = (usage['candidatesTokenCount'] as num?)?.toInt() ?? 0;
    if (prompt == 0 && completion == 0) {
      final total = (usage['totalTokenCount'] as num?)?.toInt() ?? 0;
      if (total > 0) prompt = total;
    }
    return AiUsageResult(promptTokens: prompt, completionTokens: completion).clamped();
  }

  /// Parses Claude `usage` block.
  static AiUsageResult? parseClaudeUsage(Map<String, dynamic>? data) {
    final usage = data?['usage'];
    if (usage is! Map) return null;
    return AiUsageResult(
      promptTokens: (usage['input_tokens'] as num?)?.toInt() ?? 0,
      completionTokens: (usage['output_tokens'] as num?)?.toInt() ?? 0,
    ).clamped();
  }
}
