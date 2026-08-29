import '../../data/vector/knowledge_vector_store.dart';
import 'ai_consent_gate.dart';
import 'ai_policy_registry.dart';

class RagContext {
  const RagContext({
    required this.promptBlock,
    required this.chunkIds,
    required this.mode,
  });

  final String promptBlock;
  final List<String> chunkIds;
  final String mode;

  static const empty = RagContext(promptBlock: '', chunkIds: [], mode: 'exploratory');
}

class RagContextBuilder {
  const RagContextBuilder({
    required this.vectorStore,
    required this.consentGate,
  });

  final KnowledgeVectorStore vectorStore;
  final AiConsentGate consentGate;

  Future<RagContext> build({
    required String query,
    required String goalMode,
    Set<String>? enabledSourceUuids,
    Map<String, String>? sourceTypes,
    String? modeOverride,
    int? maxTokens,
  }) async {
    await consentGate.load();
    final policy = await AiPolicyRegistry.load();
    final defaults = policy.defaultsForGoal(goalMode);
    final mode = modeOverride ?? consentGate.current.generationMode;
    if (mode == 'exploratory') return RagContext.empty;
    if (!consentGate.canSendChunksToProvider()) return RagContext.empty;

    final tokenBudget = maxTokens ?? defaults.ragMaxTokens;
    final chunks = await vectorStore.retrieve(
      query: query,
      sourceUuids: enabledSourceUuids,
      sourceTypes: sourceTypes,
      limit: 10,
      maxTokens: tokenBudget,
    );
    if (chunks.isEmpty) return RagContext(mode: mode, promptBlock: '', chunkIds: const []);

    final buffer = StringBuffer();
    buffer.writeln('Use the following learner-provided reference material when generating content.');
    buffer.writeln(
      'Highest priority: resume, job description, and uploaded notes/books. '
      'Normalize messy OCR/formatting lightly if needed, but do NOT invent facts.',
    );
    if (mode == 'grounded') {
      buffer.writeln('IMPORTANT: Base questions and content ONLY on the excerpts below. Do not invent facts beyond them.');
    } else {
      buffer.writeln('Prefer the excerpts below; you may supplement with general knowledge when needed.');
    }
    buffer.writeln('---');
    for (var i = 0; i < chunks.length; i++) {
      final c = chunks[i];
      final label = c.citationLabel ?? 'Source ${i + 1}';
      final page = c.page != null ? ' (p.${c.page})' : '';
      buffer.writeln('[$label$page | id:${c.chunkId}]');
      buffer.writeln(c.text.trim());
      buffer.writeln('---');
    }

    return RagContext(
      promptBlock: buffer.toString(),
      chunkIds: chunks.map((c) => c.chunkId).toList(),
      mode: mode,
    );
  }

  static String prependToPrompt(String basePrompt, RagContext context) {
    if (context.promptBlock.isEmpty) return basePrompt;
    return '${context.promptBlock}\n\n$basePrompt';
  }
}
