import '../built_in_ai_config.dart';

/// NVIDIA capabilities beyond the Built-in chat model.
enum NvidiaCapability { vision, ocr, embeddings, safety }

/// Models and keys for the NVIDIA API catalog services Rivox uses.
///
/// Every model below was probed live on 2026-10-11 (status and latency in
/// the doc comments). Keys are build-time `--dart-define`s from the
/// gitignored `tool/.local_dart_defines.json`, one per capability so each
/// gets its own rate-limit bucket. A missing capability key falls back to
/// the Built-in AI key, and on 401/403/429 the client fails over to the
/// next key ([keysFor]). Do not commit keys; anything compiled into an APK
/// can be extracted, so treat this as obfuscation, not secrecy.
class NvidiaAiConfig {
  NvidiaAiConfig._();

  static const String chatBaseUrl = 'https://integrate.api.nvidia.com/v1';

  /// Image to text (photo questions, diagrams, worksheets). 200 in about 3s.
  static const String visionModel = 'meta/llama-3.2-11b-vision-instruct';

  /// Document OCR to Markdown (handwriting, tables, formulas). 200 in about 1s.
  static const String ocrModel = 'nvidia/nemotron-parse';

  /// Semantic embeddings for library RAG. 2048 dims (fixed). 200 in about 1s.
  static const String embeddingModel = 'nvidia/nemotron-3-embed-1b';
  static const int embeddingDims = 2048;

  /// Input/output safety classifier for chat. 200 in about 1s.
  static const String safetyModel = 'nvidia/nemotron-3.5-content-safety';

  /// Not used in interactive flows: Kimi K3 took 171s at max effort and did
  /// not answer within 180s at low effort (2026-10-11 probe).
  static const String deepReasoningModel = 'moonshotai/kimi-k3';

  static const String _visionKey = String.fromEnvironment('NVIDIA_VISION_API_KEY');
  static const String _ocrKey = String.fromEnvironment('NVIDIA_OCR_API_KEY');
  static const String _embedKey = String.fromEnvironment('NVIDIA_EMBED_API_KEY');
  static const String _safetyKey = String.fromEnvironment('NVIDIA_SAFETY_API_KEY');
  static const String _spareKey = String.fromEnvironment('NVIDIA_SPARE_API_KEY');

  static String _keyFor(NvidiaCapability c) => switch (c) {
        NvidiaCapability.vision => _visionKey,
        NvidiaCapability.ocr => _ocrKey,
        NvidiaCapability.embeddings => _embedKey,
        NvidiaCapability.safety => _safetyKey,
      }
          .trim();

  /// Keys to try for [capability], in order: its own key, the spare key,
  /// the other capability keys, then the Built-in AI key. De-duplicated,
  /// empty ones dropped.
  static List<String> keysFor(NvidiaCapability capability) {
    final ordered = [
      _keyFor(capability),
      _spareKey.trim(),
      for (final c in NvidiaCapability.values)
        if (c != capability) _keyFor(c),
      BuiltInAiConfig.apiKey,
    ];
    final out = <String>[];
    for (final k in ordered) {
      if (k.isNotEmpty && !out.contains(k)) out.add(k);
    }
    return out;
  }

  static bool isAvailable(NvidiaCapability capability) => keysFor(capability).isNotEmpty;
}
