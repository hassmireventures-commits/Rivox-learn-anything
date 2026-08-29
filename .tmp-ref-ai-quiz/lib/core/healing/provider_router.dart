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
      scored.add((config: config, score: score));
    }

    if (scored.isEmpty) {
      final primary = providers.firstWhere((p) => p.isDefault, orElse: () => providers.first);
      return ProviderPick(primary: primary, fallbacks: providers.where((p) => p.uuid != primary.uuid).toList());
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final primary = scored.first.config;
    final fallbacks = scored.skip(1).map((e) => e.config).toList();
    return ProviderPick(primary: primary, fallbacks: fallbacks);
  }
}
