import 'package:collection/collection.dart';

import 'built_in_ai_config.dart';
import '../../data/local/models/ai_provider_config.dart';
import '../../data/remote/ai/ai_provider.dart';

/// Built-in-oriented clamps so quiz/path generation stays lean on slower NIM.
class GenerationSizing {
  GenerationSizing._();

  static const int maxBuiltinQuizQuestions = 20;
  static const int builtinPathModules = 4;

  static bool isBuiltinProvider(AiProviderConfig? config) {
    if (config == null) return false;
    if (config.uuid == BuiltInAiConfig.uuid) return true;
    return AiProviderType.fromId(config.providerType).isBuiltin;
  }

  /// Prefer the user's default provider; then other BYOK; then Built-in.
  static AiProviderConfig? pickActiveCloudProvider(List<AiProviderConfig> providers) {
    if (providers.isEmpty) return null;
    final preferred = providers.where((p) => p.isDefault).firstOrNull;
    if (preferred != null) return preferred;
    final byok = providers.where((p) => p.uuid != BuiltInAiConfig.uuid).firstOrNull;
    if (byok != null) return byok;
    return providers.where((p) => p.uuid == BuiltInAiConfig.uuid).firstOrNull ??
        providers.first;
  }

  static int clampQuizQuestionCount({
    required int questionCount,
    required bool isBuiltin,
  }) {
    if (!isBuiltin) return questionCount;
    return questionCount.clamp(1, maxBuiltinQuizQuestions);
  }

  static bool explanationsForBuiltin({
    required bool requested,
    required bool isBuiltin,
    int questionCount = 10,
    String? quizKind,
  }) {
    if (!isBuiltin) return requested;
    // Keep explanations for short quizzes, daily, and module practice.
    if (quizKind == 'daily' || quizKind == 'module') return true;
    if (questionCount <= 10) return true;
    return false;
  }

  static int clampPathModuleCount({
    required int moduleCount,
    required bool isBuiltin,
  }) {
    if (!isBuiltin) return moduleCount.clamp(4, 6);
    return builtinPathModules;
  }
}
