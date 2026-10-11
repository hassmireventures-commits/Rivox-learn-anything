import 'dart:typed_data';

import 'cloud_ocr_service.dart';
import 'image_prep.dart';
import 'nvidia_ai_config.dart';
import 'nvidia_client.dart';

/// Image to text for the tutor ("snap a question"): turns a photo of a
/// worksheet, diagram, chart, code screenshot, recipe, or exercise form
/// into faithful text the chat model can reason over. It only reads and
/// describes; answering is left to the tutor so explanations stay in one
/// voice and go through the normal chat pipeline.
class VisionService {
  VisionService({NvidiaClient? client}) : _client = client ?? NvidiaClient();

  final NvidiaClient _client;

  static bool get isAvailable => NvidiaAiConfig.isAvailable(NvidiaCapability.vision);

  static const String instruction =
      'You are the eyes of a study tutor. Read this image for a learner.\n'
      '1. Transcribe every piece of text exactly, including maths (use plain '
      'text like x^2, sqrt(x), a/b), code (keep indentation), and table cells '
      '(as "col | col" rows).\n'
      '2. Describe any diagram, chart, graph, or photo precisely: labels, '
      'axes, values, arrows, and what is shown.\n'
      '3. If the image contains a question or exercise, restate it on one '
      'line starting "Question:".\n'
      'Do not solve anything and do not add facts that are not visible. If '
      'part of the image is unreadable, say which part.';

  /// Returns the model's reading of the image. Throws [VisionException] when
  /// the image cannot be decoded or the service cannot be reached.
  Future<String> readImage(Uint8List bytes, {String? learnerNote}) async {
    final dataUrl = await ImagePrep.toJpegDataUrl(bytes);
    if (dataUrl == null) throw const VisionException('That file is not an image Rivox can read.');
    final note = learnerNote?.trim() ?? '';
    final Map<String, dynamic> message;
    try {
      message = await _client.chat(
        model: NvidiaAiConfig.visionModel,
        capability: NvidiaCapability.vision,
        maxTokens: 600,
        temperature: 0.1,
        timeout: const Duration(seconds: 60),
        messages: [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': note.isEmpty ? instruction : '$instruction\nThe learner adds: "$note"',
              },
              {
                'type': 'image_url',
                'image_url': {'url': dataUrl},
              },
            ],
          },
        ],
      );
    } catch (e) {
      throw VisionException('Could not read the photo right now. ($e)');
    }
    final text = message['content']?.toString().trim() ?? '';
    if (text.isEmpty) throw const VisionException('Nothing readable was found in the photo.');
    return text;
  }
}

/// What the tutor got from a photo, and how complete it is.
class PhotoReading {
  const PhotoReading({required this.text, required this.full});

  final String text;

  /// False when only the text could be read (vision model too slow or
  /// down), so diagrams and pictures were not described.
  final bool full;
}

/// Self-healing photo reader. NVIDIA's free-tier vision latency swings from
/// about 3s to over 90s (measured 2026-10-11), so a single vision call is
/// not dependable. Cloud OCR (Nemotron Parse, about 1s) runs in parallel;
/// vision gets [visionBudget]; if it is late or fails, the OCR text is used,
/// then on-device ML Kit as the last resort (needs [imagePath]).
class PhotoReader {
  PhotoReader({
    VisionService? vision,
    CloudOcrService? cloudOcr,
    Future<String> Function(String path)? onDeviceOcr,
    this.visionBudget = const Duration(seconds: 30),
  })  : _vision = vision ?? VisionService(),
        _cloudOcr = cloudOcr ?? CloudOcrService(),
        _onDeviceOcr = onDeviceOcr;

  final VisionService _vision;
  final CloudOcrService _cloudOcr;
  final Future<String> Function(String path)? _onDeviceOcr;
  final Duration visionBudget;

  Future<PhotoReading> read(Uint8List bytes, {String? learnerNote, String? imagePath}) async {
    // recognizeBytes never throws and returns '' when no OCR key is set.
    final ocrFuture = _cloudOcr.recognizeBytes(bytes);
    try {
      final text = await _vision.readImage(bytes, learnerNote: learnerNote).timeout(visionBudget);
      return PhotoReading(text: text, full: true);
    } catch (_) {
      // Fall through to text-only readings.
    }
    var ocr = await ocrFuture;
    final path = imagePath;
    if (ocr.trim().isEmpty && path != null && _onDeviceOcr != null) {
      try {
        ocr = await _onDeviceOcr(path);
      } catch (_) {}
    }
    if (ocr.trim().isEmpty) {
      throw const VisionException('Could not read that photo right now. Try again, or type the question.');
    }
    return PhotoReading(text: 'Text in the photo:\n${ocr.trim()}', full: false);
  }
}

class VisionException implements Exception {
  const VisionException(this.message);
  final String message;

  @override
  String toString() => message;
}
