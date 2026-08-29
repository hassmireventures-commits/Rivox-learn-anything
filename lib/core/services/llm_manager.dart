import 'package:collection/collection.dart';

import '../error/app_exception.dart';
import '../../data/local/models/ai_provider_config.dart';
import '../../data/local/repositories/provider_repository.dart';
import '../../data/remote/ai/ai_json_client.dart';
import '../../data/remote/ai/ai_provider.dart';
import '../../data/remote/ai/ai_provider_factory.dart';
import 'ai_engine_mode_store.dart';
import 'built_in_ai_config.dart';
import 'built_in_ai_quota.dart';

/// Resolved engine for a generation call (Built-in AI or BYOK cloud provider).
class ResolvedLlmEngine {
  const ResolvedLlmEngine({
    required this.providerKey,
    required this.providerLabel,
    required this.quizProvider,
    required this.cloudApiKey,
    required this.cloudConfigUuid,
  });

  final String providerKey;
  final String providerLabel;
  final AiProvider quizProvider;
  final String cloudApiKey;
  final String cloudConfigUuid;

  AiEngineMode get mode => AiEngineMode.cloud;
  bool get isLocal => false;
  bool get usedFallback => false;
}

/// Routes generation to Built-in AI or user-configured cloud providers.
class LlmManager {
  LlmManager({
    required ProviderRepository providerRepository,
    AiEngineModeStore? modeStore,
  })  : _providerRepository = providerRepository,
        _modeStore = modeStore ?? AiEngineModeStore.instance;

  final ProviderRepository _providerRepository;
  final AiEngineModeStore _modeStore;

  /// Legacy key kept for circuit-breaker compatibility with older installs.
  static const localProviderKey = 'local-mlc';

  Future<AiEngineMode?> currentMode() async {
    final mode = await _modeStore.load();
    if (mode == AiEngineMode.local) return AiEngineMode.cloud;
    return mode;
  }

  Future<void> setMode(AiEngineMode mode) async {
    await _modeStore.save(mode == AiEngineMode.local ? AiEngineMode.cloud : mode);
  }

  Future<ResolvedLlmEngine?> _tryResolveCloud() async {
    final providers = await _providerRepository.getAll();
    if (providers.isEmpty) {
      return null;
    }
    final builtinRow = providers.where((p) => p.uuid == BuiltInAiConfig.uuid).firstOrNull;
    final primary =
        providers.where((p) => p.isDefault).firstOrNull ?? builtinRow ?? providers.first;
    final fallbackCandidate = await _firstProviderWithKey(
      providers,
      preferredUuid: primary.uuid,
    );
    if (fallbackCandidate != null) {
      final (uuid, config, apiKey) = fallbackCandidate;
      return ResolvedLlmEngine(
        providerKey: uuid,
        providerLabel: config.name,
        quizProvider: AiProviderFactory.create(config: config, apiKey: apiKey),
        cloudApiKey: apiKey,
        cloudConfigUuid: uuid,
      );
    }

    if (builtinRow != null) {
      throw const MissingApiKeyException(
        'Built-in AI is not configured in this build. Reinstall a build that includes '
        'BUILT_IN_AI_API_KEY, or add your own provider in Settings → AI Providers.',
      );
    }

    if (providers.isNotEmpty) {
      throw const MissingApiKeyException(
        'AI provider API key missing. Open Settings → AI Providers to add your key.',
      );
    }
    return null;
  }

  Future<ResolvedLlmEngine> resolve() async {
    final cloud = await _tryResolveCloud();
    if (cloud != null) return cloud;

    final rawMode = await _modeStore.load();
    if (rawMode == null) throw const EngineNotChosenException();
    throw const NoProviderConfiguredException(
      'No cloud provider configured. Add one in Settings → AI Providers.',
    );
  }

  /// Validates that an engine can serve requests (used before quiz UI).
  Future<void> validateReady() async {
    await resolve();
  }

  Future<String> completeJson({
    required String userPrompt,
    String systemPrompt =
        'You are a curriculum designer. Respond with a single valid JSON object only. No markdown.',
    bool recordBuiltinQuota = true,
    bool skipQuota = false,
    bool Function(String content)? validateContent,
  }) async {
    final resolved = await resolve();
    final config = await _providerRepository.getByUuid(resolved.cloudConfigUuid);
    if (config == null) {
      throw const NoProviderConfiguredException();
    }
    final builtin = resolved.providerKey == BuiltInAiConfig.uuid;
    if (builtin && !skipQuota) {
      await BuiltInAiQuota.instance.ensureCanGenerate();
    }
    final result = await AiJsonClient.complete(
      config: config,
      apiKey: resolved.cloudApiKey,
      userPrompt: userPrompt,
      systemPrompt: systemPrompt,
      validateContent: validateContent,
    );
    if (builtin && recordBuiltinQuota) {
      await BuiltInAiQuota.instance.recordGeneration();
    }
    return result;
  }

  /// Connection probe used by Home “AI Study Pulse”. Never records Built-in quota.
  Future<String> completeStudyPulse({required String userPrompt}) async {
    final resolved = await resolve();
    const systemPrompt =
        'You are a concise study coach. Respond with a single valid JSON object only. No markdown.';
    final config = await _providerRepository.getByUuid(resolved.cloudConfigUuid);
    if (config == null) {
      throw const NoProviderConfiguredException();
    }
    try {
      return await AiJsonClient.complete(
        config: config,
        apiKey: resolved.cloudApiKey,
        userPrompt: userPrompt,
        systemPrompt: systemPrompt,
        maxTokens: BuiltInAiConfig.pulseMaxTokens,
        timeout: BuiltInAiConfig.pulseTimeout,
      );
    } catch (e) {
      // Dead BYOK default: fall back to Built-in for the Home brief (quiz already
      // has resilient fallbacks; pulse previously failed closed as offline).
      if (resolved.providerKey == BuiltInAiConfig.uuid) rethrow;
      final builtin = await _providerRepository.getByUuid(BuiltInAiConfig.uuid);
      final builtinKey = builtin == null
          ? null
          : await _providerRepository.getApiKey(BuiltInAiConfig.uuid);
      if (builtin == null || builtinKey == null || builtinKey.isEmpty) rethrow;
      return AiJsonClient.complete(
        config: builtin,
        apiKey: builtinKey,
        userPrompt: userPrompt,
        systemPrompt: systemPrompt,
        maxTokens: BuiltInAiConfig.pulseMaxTokens,
        timeout: BuiltInAiConfig.pulseTimeout,
      );
    }
  }

  Future<(String, AiProviderConfig, String)?> _firstProviderWithKey(
    List<AiProviderConfig> providers, {
    required String preferredUuid,
  }) async {
    final resolved = await _providerRepository.listResolvableWithKeys();
    for (final row in resolved) {
      if (providers.any((p) => p.uuid == row.config.uuid)) {
        return (row.config.uuid, row.config, row.apiKey);
      }
    }
    return null;
  }
}
