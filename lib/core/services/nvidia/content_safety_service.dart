import 'package:flutter/foundation.dart';

import 'nvidia_ai_config.dart';
import 'nvidia_client.dart';

/// Result of a safety check. [safe] is true when the classifier said safe
/// or could not be reached (fail open: the existing on-device prompt
/// firewall still runs, and a classifier outage must not block studying).
class SafetyVerdict {
  const SafetyVerdict({required this.safe, this.categories = const [], this.checked = true});

  static const SafetyVerdict unchecked = SafetyVerdict(safe: true, checked: false);

  final bool safe;
  final List<String> categories;

  /// False when the classifier was unavailable and the verdict is a default.
  final bool checked;
}

/// NVIDIA Nemotron content-safety guard for chat messages: a second line of
/// defence after the local `PromptFirewall`, catching harmful requests that
/// keyword rules miss (in any wording or language). About 1s; run alongside
/// RAG retrieval so it adds no wall-clock time.
class ContentSafetyService {
  ContentSafetyService({NvidiaClient? client}) : _client = client ?? NvidiaClient();

  final NvidiaClient _client;

  static const Duration timeout = Duration(seconds: 6);

  Future<SafetyVerdict> checkUserMessage(String text) async {
    if (text.trim().isEmpty || !NvidiaAiConfig.isAvailable(NvidiaCapability.safety)) {
      return SafetyVerdict.unchecked;
    }
    try {
      final message = await _client
          .chat(
            model: NvidiaAiConfig.safetyModel,
            capability: NvidiaCapability.safety,
            maxTokens: 60,
            temperature: 0,
            timeout: timeout,
            messages: [
              {'role': 'user', 'content': text.length > 4000 ? text.substring(0, 4000) : text},
            ],
          )
          .timeout(timeout);
      return parseVerdict(message['content']?.toString() ?? '');
    } catch (_) {
      return SafetyVerdict.unchecked;
    }
  }

  /// Parses replies like "User Safety: unsafe\nSafety Categories: Violence,
  /// Weapons" or a JSON object with the same keys. Pure, unit-tested.
  @visibleForTesting
  static SafetyVerdict parseVerdict(String raw) {
    final lower = raw.toLowerCase();
    if (lower.trim().isEmpty) return SafetyVerdict.unchecked;
    final user = RegExp(r'user[ _]safety"?\s*:\s*"?(safe|unsafe)').firstMatch(lower);
    final unsafe = user != null ? user.group(1) == 'unsafe' : RegExp(r'\bunsafe\b').hasMatch(lower);
    final cats = RegExp(r'safety[ _]categories"?\s*:\s*"?([^"\n}]*)', caseSensitive: false)
        .firstMatch(raw)
        ?.group(1)
        ?.split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();
    return SafetyVerdict(safe: !unsafe, categories: cats ?? const []);
  }
}
