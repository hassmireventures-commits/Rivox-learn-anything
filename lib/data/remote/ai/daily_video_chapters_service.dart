import 'dart:convert';

import '../../../core/services/video_chapter.dart';
import '../../local/models/ai_provider_config.dart';
import 'ai_json_client.dart';
import 'ai_output_gate.dart';
import 'youtube_transcript_fetcher.dart';

/// B35 — derives 3-5 chapter markers for a Daily Pack video from its timed
/// caption track. Degrades to an empty list (no chapter row shown, today's
/// plain-video experience unchanged) whenever a usable transcript isn't
/// available — auto-captions can be missing or poor, and that must never
/// block video display.
///
/// Not combined with SponsorBlock's skip-segment API in this pass (a
/// genuinely different concept — sponsor/intro removal, not content
/// navigation) — left as a clearly separate possible follow-up rather than
/// conflating the two.
class DailyVideoChaptersService {
  const DailyVideoChaptersService();

  /// Caps how much timed-transcript text goes into the prompt, to keep this
  /// a cheap, fast call rather than shipping a whole video's transcript.
  static const int _maxTranscriptChars = 6000;

  Future<List<VideoChapter>> generateChapters({
    required String videoId,
    required AiProviderConfig config,
    required String apiKey,
  }) async {
    final lines = await YoutubeTranscriptFetcher.fetchTimedTranscript(videoId);
    if (lines.isEmpty) return const [];

    final buffer = StringBuffer();
    for (final line in lines) {
      final next = '[${line.startSeconds.round()}s] ${line.text}\n';
      if (buffer.length + next.length > _maxTranscriptChars) break;
      buffer.write(next);
    }
    final transcriptBlock = buffer.toString().trim();
    if (transcriptBlock.isEmpty) return const [];

    try {
      final raw = await AiJsonClient.complete(
        config: config,
        apiKey: apiKey,
        systemPrompt:
            'You are given a timed video transcript as lines like "[12s] some text". Respond with JSON only: '
            '{"chapters":[{"timestampSeconds":0,"label":"..."}]}. Produce 3 to 5 chapters covering the whole '
            'video, roughly evenly spaced. Each timestampSeconds must be a number taken from the transcript '
            '(the bracketed seconds value of the line where that chapter begins). Each label is a short '
            '(3-6 word) description of what starts at that point. The first chapter should start at or near 0.',
        userPrompt: transcriptBlock,
      );
      final normalized = AiOutputGate.normalizeJsonText(raw) ?? raw.trim();
      final decoded = jsonDecode(normalized);
      if (decoded is! Map || decoded['chapters'] is! List) return const [];
      final chapters = (decoded['chapters'] as List)
          .whereType<Map>()
          .map((m) => VideoChapter.fromJson(Map<String, dynamic>.from(m)))
          .whereType<VideoChapter>()
          .toList()
        ..sort((a, b) => a.timestampSeconds.compareTo(b.timestampSeconds));
      return chapters;
    } catch (_) {
      return const [];
    }
  }
}
