import '../../data/local/models/ai_provider_config.dart';
import '../../data/local/repositories/provider_repository.dart';
import '../../data/remote/ai/provider_connection_tester.dart';
import '../error/app_exception.dart';
import '../healing/circuit_breaker.dart';
import '../network/network_service.dart';
import 'built_in_ai_config.dart';
import 'usage_tracker.dart';

class AiReadinessResult {
  const AiReadinessResult({
    required this.ready,
    this.providerName,
    this.detail,
    this.handshakeLatencyMs,
  });

  final bool ready;
  final String? providerName;
  final String? detail;
  final int? handshakeLatencyMs;
}

/// Validates Built-in AI / BYOK cloud readiness before showing "Online".
class AiReadinessService {
  AiReadinessService({
    required ProviderRepository providerRepository,
    required UsageTracker usageTracker,
    required CircuitBreaker circuitBreaker,
  })  : _providerRepository = providerRepository,
        _usageTracker = usageTracker,
        _circuitBreaker = circuitBreaker;

  final ProviderRepository _providerRepository;
  final UsageTracker _usageTracker;
  final CircuitBreaker _circuitBreaker;

  AiReadinessResult? _cachedResult;
  DateTime? _cachedAt;

  static const _cacheTtl = Duration(seconds: 45);

  Future<AiReadinessResult> evaluate({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedResult != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl) {
      return _cachedResult!;
    }

    return _evaluateCloud();
  }

  Future<AiReadinessResult> _evaluateCloud() async {
    List<({AiProviderConfig config, String apiKey})> candidates;
    try {
      candidates = await _providerRepository.listResolvableWithKeys();
      if (candidates.isEmpty) {
        return _cache(const AiReadinessResult(
          ready: false,
          detail: 'Add a cloud provider or use Built-in AI in Settings',
        ));
      }
    } catch (_) {
      return _cache(const AiReadinessResult(
        ready: false,
        detail: 'Could not read provider config',
      ));
    }

    try {
      await NetworkService.instance.ensureConnected();
    } on NoInternetException {
      return _cache(const AiReadinessResult(
        ready: false,
        detail: 'No internet connection',
      ));
    } catch (_) {
      return _cache(const AiReadinessResult(
        ready: false,
        detail: 'Network check failed',
      ));
    }

    final now = DateTime.now();
    String? lastProviderName;
    String? lastDetail;

    for (final candidate in candidates) {
      final provider = candidate.config;
      final apiKey = candidate.apiKey;
      final label =
          provider.uuid == BuiltInAiConfig.uuid ? 'Built-in AI' : provider.name;

      if (!_circuitBreaker.allow(provider.uuid)) {
        lastProviderName = label;
        lastDetail = 'Provider paused after repeated failures';
        continue;
      }

      final usage = await _usageTracker.forProvider(provider.uuid);
      if (usage?.retryAfterUntil != null && usage!.retryAfterUntil!.isAfter(now)) {
        lastProviderName = label;
        lastDetail = 'Rate limit active - try again shortly';
        continue;
      }

      final sw = Stopwatch()..start();
      try {
        await ProviderConnectionTester.test(config: provider, apiKey: apiKey);
        sw.stop();
        _circuitBreaker.recordSuccess(provider.uuid);
        return _cache(AiReadinessResult(
          ready: true,
          providerName: label,
          detail: 'Ready to serve requests',
          handshakeLatencyMs: sw.elapsedMilliseconds,
        ));
      } on InvalidApiKeyException catch (e) {
        sw.stop();
        lastProviderName = label;
        lastDetail = e.message;
      } on AppException catch (e) {
        sw.stop();
        lastProviderName = label;
        lastDetail = e.message;
      } catch (_) {
        sw.stop();
        lastProviderName = label;
        lastDetail = 'Handshake failed';
      }
    }

    return _cache(AiReadinessResult(
      ready: false,
      providerName: lastProviderName,
      detail: lastDetail ?? 'No provider available',
    ));
  }

  void invalidateCache() {
    _cachedResult = null;
    _cachedAt = null;
  }

  AiReadinessResult _cache(AiReadinessResult result) {
    _cachedResult = result;
    _cachedAt = DateTime.now();
    return result;
  }
}
