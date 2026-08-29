import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/ai_platform/ai_request_pipeline.dart';
import '../../local/models/ai_provider_config.dart';
import '../../local/models/flashcard.dart';
import '../../local/repositories/flashcard_repository.dart';
import '../../local/repositories/knowledge_repository.dart';
import 'ai_json_client.dart';
import 'ai_output_gate.dart';

/// Generates spaced-repetition flashcards from the learner's enabled library
/// sources for a goal. Uses the same AI quota / audit gating as other
/// generation flows (via [AiRequestPipeline.execute]).
class FlashcardGenerationService {
  FlashcardGenerationService({
    required this.aiPipeline,
    required this.knowledgeRepository,
    required this.flashcardRepository,
  });

  final AiRequestPipeline aiPipeline;
  final KnowledgeRepository knowledgeRepository;
  final FlashcardRepository flashcardRepository;
  final _uuid = const Uuid();

  /// Builds up to [count] flashcards from enabled + indexed library sources
  /// for [goalMode], persists them, and returns how many were created.
  /// Returns 0 (no AI call, no quota spent) when there is no indexed content.
  Future<int> generateFromLibrary({
    required AiProviderConfig config,
    required String apiKey,
    required String goalMode,
    int count = 10,
  }) async {
    final enabledSourceUuids = await knowledgeRepository.enabledSourceUuids(goalMode);
    if (enabledSourceUuids.isEmpty) return 0;

    final chunks = await knowledgeRepository.chunksForSources(
      enabledSourceUuids,
      limit: 12,
    );
    if (chunks.isEmpty) return 0;

    final contextBlock = chunks
        .map((c) => '[${c.citationLabel ?? 'Source'}]\n${c.text.trim()}')
        .join('\n---\n');

    final ctx = AiRequestContext(
      task: 'flashcards',
      providerKey: config.uuid,
      goalMode: goalMode,
      // Context is already assembled from library chunks above, so no need
      // for AiRequestPipeline's own vector-store RAG lookup here.
      topic: '',
    );

    final cards = await aiPipeline.execute<List<Flashcard>>(
      ctx: ctx,
      run: (_) async {
        final raw = await AiJsonClient.complete(
          config: config,
          apiKey: apiKey,
          systemPrompt:
              'You are a study-flashcard writer. Respond with a single valid JSON object only, '
              'no markdown: {"cards":[{"front":"...","back":"..."}]}.',
          userPrompt: '''
Create up to $count concise spaced-repetition flashcards from the reference material below.
Each "front" is a short question or prompt; each "back" is the answer or explanation.
Base the cards only on the material - do not invent facts.

Reference material:
$contextBlock
''',
        );
        return _parseCards(raw, goalMode: goalMode);
      },
      onSimplifiedRetry: () => const <Flashcard>[],
    );

    await flashcardRepository.addCards(cards);
    return cards.length;
  }

  List<Flashcard> _parseCards(String raw, {required String goalMode}) {
    final normalized = AiOutputGate.normalizeJsonText(raw) ?? raw;
    final decoded = jsonDecode(normalized);
    final list = decoded is Map ? decoded['cards'] : null;
    if (list is! List) return const [];

    final now = DateTime.now();
    final cards = <Flashcard>[];
    for (final item in list) {
      if (item is! Map) continue;
      final front = (item['front'] ?? '').toString().trim();
      final back = (item['back'] ?? '').toString().trim();
      if (front.isEmpty || back.isEmpty) continue;
      cards.add(
        Flashcard()
          ..uuid = _uuid.v4()
          ..front = front
          ..back = back
          ..sourceType = 'library'
          ..goalMode = goalMode
          ..createdAt = now
          ..nextReviewAt = now,
      );
    }
    return cards;
  }
}
