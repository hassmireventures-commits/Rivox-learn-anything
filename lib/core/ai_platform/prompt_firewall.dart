import 'ai_policy_registry.dart';

class PromptFirewallResult {
  const PromptFirewallResult({
    required this.sanitized,
    required this.blocked,
    this.reason,
  });

  final String sanitized;
  final bool blocked;
  final String? reason;
}

class PromptFirewall {
  const PromptFirewall();

  Future<PromptFirewallResult> sanitize(String input, {AiPolicy? policy}) async {
    final p = policy ?? AiPolicyRegistry.current;
    var text = input
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (text.length > p.maxTopicLength) {
      text = text.substring(0, p.maxTopicLength);
    }

    final lower = text.toLowerCase();
    for (final pattern in p.blockedPromptPatterns) {
      try {
        if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
          return PromptFirewallResult(
            sanitized: text,
            blocked: true,
            reason: 'Prompt contains disallowed content.',
          );
        }
      } catch (_) {
        if (lower.contains(pattern.toLowerCase())) {
          return PromptFirewallResult(
            sanitized: text,
            blocked: true,
            reason: 'Prompt contains disallowed content.',
          );
        }
      }
    }

    for (final pattern in p.blockedProfanityPatterns) {
      try {
        if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
          return PromptFirewallResult(
            sanitized: text,
            blocked: true,
            reason: 'profanity',
          );
        }
      } catch (_) {
        if (lower.contains(pattern.toLowerCase())) {
          return PromptFirewallResult(
            sanitized: text,
            blocked: true,
            reason: 'profanity',
          );
        }
      }
    }

    if (RegExp(r'sk-[a-zA-Z0-9]{20,}').hasMatch(text)) {
      return PromptFirewallResult(
        sanitized: text,
        blocked: true,
        reason: 'Do not paste API keys in study topics.',
      );
    }

    return PromptFirewallResult(sanitized: text, blocked: false);
  }

  /// Returns first blocked topic, or null if all pass.
  Future<PromptFirewallResult?> sanitizeTopics(
    List<String> topics, {
    AiPolicy? policy,
  }) async {
    for (final t in topics) {
      final r = await sanitize(t, policy: policy);
      if (r.blocked) return r;
    }
    return null;
  }
}
