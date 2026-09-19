import 'package:flutter_tts/flutter_tts.dart';

/// B2 follow-up — reads interview questions aloud via the platform's
/// on-device text-to-speech engine (no network call, no API key, unlike
/// Whisper STT — this is a genuinely different, much lower-risk capability
/// than the fully real-time conversational format scoped separately as B42).
class InterviewTtsService {
  InterviewTtsService() {
    _tts.setLanguage('en-US');
    // Slightly slower than the default 0.5 for a clearer, more
    // interviewer-like cadence rather than a rushed voice assistant read.
    _tts.setSpeechRate(0.45);
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

  Future<void> dispose() => _tts.stop();
}
