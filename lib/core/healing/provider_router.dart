import '../../data/local/models/ai_provider_config.dart';
import '../services/usage_tracker.dart';
import 'circuit_breaker.dart';

class ProviderPick {
  const ProviderPick({required this.primary, this.fallbacks = const []});

  final AiProviderConfig primary;
  final List<AiProviderConfig> fallbacks;
}

class ProviderRouter {
  const ProviderRouter({
    required this.circuitBreaker,
    this.usageTracker,
  });

  final CircuitBreaker circuitBreaker;
  final UsageTracker? usageTracker;

  Future<ProviderPick> pickProviders({
    required List<AiProviderConfig> providers,
    String task = 'quiz',
  }) async {
    if (providers.isEmpty) {
      throw StateError('No AI provider configured');
    }

    final now = DateTime.now();
    final scored = <({AiProviderConfig config, double score})>[];

    for (final config in providers) {
      if (!circuitBreaker.allow(config.uuid)) continue;

      final usage = await usageTracker?.forProvider(config.uuid);
      if (usage?.retryAfterUntil != null && usage!.retryAfterUntil!.isAfter(now)) {
        continue;
      }

      var score = config.isDefault ? 1000.0 : 500.0;
      if (usage != null) {
        score -= usage.callCountToday * 2;
        score -= usage.lastLatencyMs / 100;
      }
      if (task == 'path' && config.isDefault) {
        score += 50;
      }
      if (task == 'quiz_quick') {
        score -= usage?.lastLatencyMs != null && usage!.lastLatencyMs > 5000 ? 30 : 0;
      }
      if (task == 'goal_agent' && !config.isDefault) {
        score -= 100;
      }
      scored.add((config: config, score: score));
    }

    if (scored.isEmpty) {
      // All providers are currently filtered by circuit-breaker or rate-limit.
      // Fall back to the default (or first) provider and let it attempt the
      // request - the real HTTP error will surface a meaningful message to the
      // user rather than a blanket "unavailable" block.
      final primary = providers.firstWhere(
        (p) => p.isDefault,
        orElse: () => providers.first,
      );
      return ProviderPick(
        primary: primary,
        fallbacks: providers.where((p) => p.uuid != primary.uuid).toList(),
      );
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final primary = scored.first.config;
    final fallbacks = scored.skip(1).map((e) => e.config).toList();
    return ProviderPick(primary: primary, fallbacks: fallbacks);
  }
}
