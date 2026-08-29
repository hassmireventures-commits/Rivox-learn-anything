import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../error/app_exception.dart';
import '../network/network_service.dart';
import 'built_in_ai_router.dart';
import 'llm_manager.dart';

class AiStudyPulseResult {
  const AiStudyPulseResult({
    required this.online,
    this.message,
    this.providerName,
    this.fromCache = false,
  });

  final bool online;
  final String? message;
  final String? providerName;
  final bool fromCache;
}

/// Short personalized AI blurb that proves chat completions work.
/// Does **not** consume Built-in generation quota.
class AiStudyPulseService {
  AiStudyPulseService({
    required LlmManager llmManager,
  }) : _llm = llmManager;

  final LlmManager _llm;

  static const _cacheFileName = 'ai_study_pulse_cache.json';

  /// Visible for unit tests.
  static bool isValidBrief(String input) {
    final cleaned = _sanitizeDashes(input.trim());
    return _isMeaningfulBrief(cleaned) &&
        !BuiltInAiRouter.isReasoningOrInstructionLeak(cleaned);
  }

  /// Visible for unit tests.
  static String? parseBrief(String raw) => _extractBrief(raw);

  Future<void> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_cacheFileName');
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<AiStudyPulseResult> load({
    required String goalMode,
    required String goalLabel,
    required List<String> weakTopics,
    required List<String> focusTitles,
    bool forceRefresh = false,
  }) async {
    final dayKey = _dayKey(DateTime.now());
    if (!forceRefresh) {
      final cached = await _readCache();
      if (cached != null &&
          cached['day'] == dayKey &&
          cached['goalMode'] == goalMode &&
          cached['goalLabel'] == goalLabel &&
          (cached['message'] as String?)?.trim().isNotEmpty == true) {
        final msg = _sanitizeDashes((cached['message'] as String).trim());
        if (!isValidBrief(msg)) {
          await clearCache();
        } else {
          return AiStudyPulseResult(
            online: true,
            message: msg,
            providerName: cached['providerName'] as String?,
            fromCache: true,
          );
        }
      }
    } else {
      await clearCache();
    }

    final result = await _generate(
      goalMode: goalMode,
      goalLabel: goalLabel,
      weakTopics: weakTopics,
      focusTitles: focusTitles,
    );
    if (result.online &&
        (result.message?.isNotEmpty ?? false) &&
        isValidBrief(result.message!)) {
      await _writeCache({
        'day': dayKey,
        'goalMode': goalMode,
        'goalLabel': goalLabel,
        'message': result.message,
        'providerName': result.providerName,
      });
      return result;
    }
    await clearCache();
    return const AiStudyPulseResult(online: false);
  }

  /// One-shot probe for provider Test connection. Never reads/writes Home cache.
  Future<AiStudyPulseResult> loadOnce({
    required String goalMode,
    required String goalLabel,
    required List<String> weakTopics,
    required List<String> focusTitles,
  }) {
    return _generate(
      goalMode: goalMode,
      goalLabel: goalLabel,
      weakTopics: weakTopics,
      focusTitles: focusTitles,
    );
  }

  Future<AiStudyPulseResult> _generate({
    required String goalMode,
    required String goalLabel,
    required List<String> weakTopics,
    required List<String> focusTitles,
  }) async {
    try {
      await NetworkService.instance.ensureConnected();
    } on NoInternetException {
      return const AiStudyPulseResult(online: false);
    } catch (_) {
      return const AiStudyPulseResult(online: false);
    }

    final topics = [
      ...focusTitles.take(3),
      ...weakTopics.take(3),
    ].where((t) => t.trim().isNotEmpty).toSet().take(5).join(', ');

    final goal = goalLabel.trim().isNotEmpty ? goalLabel.trim() : goalMode;
    final prompt = '''
Goal: $goal
Topics: ${topics.isEmpty ? 'general learning' : topics}
Respond with one JSON object: {"brief":"two short encouraging sentences"}
''';

    try {
      final raw = await _llm.completeStudyPulse(userPrompt: prompt);
      final brief = _extractBrief(raw);
      if (brief == null || brief.isEmpty || !isValidBrief(brief)) {
        return const AiStudyPulseResult(online: false);
      }
      String? providerName;
      try {
        final resolved = await _llm.resolve();
        providerName = resolved.isLocal ? 'On-device LLM' : null;
      } catch (_) {}

      return AiStudyPulseResult(
        online: true,
        message: brief,
        providerName: providerName,
      );
    } on AppException {
      return const AiStudyPulseResult(online: false);
    } catch (_) {
      return const AiStudyPulseResult(online: false);
    }
  }

  static String? _extractBrief(String raw) {
    final trimmed = raw.trim();

    final embedded = _extractEmbeddedJson(trimmed);
    if (embedded != null) {
      final brief = embedded['brief'] ?? embedded['message'] ?? embedded['text'];
      if (brief != null) {
        final cleaned = _sanitizeDashes(brief.toString().trim());
        return isValidBrief(cleaned) ? cleaned : null;
      }
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        final brief = decoded['brief'] ?? decoded['message'] ?? decoded['text'];
        if (brief != null) {
          final cleaned = _sanitizeDashes(brief.toString().trim());
          return isValidBrief(cleaned) ? cleaned : null;
        }
      }
    } catch (_) {}

    if (trimmed.startsWith('{')) return null;
    if (BuiltInAiRouter.isReasoningOrInstructionLeak(trimmed)) return null;

    final text =
        trimmed.length > 400 ? '${trimmed.substring(0, 400).trim()}...' : trimmed;
    final cleaned = _sanitizeDashes(text);
    return isValidBrief(cleaned) ? cleaned : null;
  }

  static Map<String, dynamic>? _extractEmbeddedJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      final decoded = jsonDecode(raw.substring(start, end + 1));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// True when brief has real words (rejects "-", "—", empty punctuation).
  static bool _isMeaningfulBrief(String input) {
    final stripped = input.replaceAll(RegExp(r'[\s\-–—_.,;:!?]'), '');
    return stripped.length >= 8;
  }

  /// Strip em/en dashes from model output so UI never shows them.
  static String _sanitizeDashes(String input) {
    return input
        .replaceAll('\u2014', ', ')
        .replaceAll('\u2013', ', ')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }

  String _dayKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>?> _readCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_cacheFileName');
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(Map<String, dynamic> data) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_cacheFileName');
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }
}
