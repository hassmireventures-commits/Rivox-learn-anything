import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// B34 — Camera-to-Quiz. Wraps ML Kit's on-device text recognition (Latin
/// script) so scanned pages never leave the device — consistent with this
/// app's local-first stance, unlike a cloud OCR API.
class OcrService {
  OcrService() : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  /// Recognizes text in the image at [imagePath]. Returns the recognized
  /// text, or an empty string if nothing was detected (e.g. a blank/blurry
  /// photo) — callers should treat that as "no text found," not an error.
  Future<String> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  /// Recognizes each captured page independently and joins them with a
  /// blank line between pages, so multi-page scans read as one document
  /// without pages bleeding into each other mid-sentence.
  Future<String> recognizePages(List<String> imagePaths) async {
    final texts = <String>[];
    for (final path in imagePaths) {
      final text = await recognizeText(path);
      if (text.trim().isNotEmpty) texts.add(text.trim());
    }
    return texts.join('\n\n');
  }

  Future<void> dispose() => _recognizer.close();
}
