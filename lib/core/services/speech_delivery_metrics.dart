/// B37 — speech-delivery feedback for voice interviews: words-per-minute and
/// filler-word count.
///
/// Deliberately computed from data this app already fully controls (wall-clock
/// recording duration + the final transcript text) rather than from Whisper's
/// segment-level timestamps. NVIDIA's Whisper NIM deployment's support for
/// `verbose_json` segment timing is unverified in this environment (no live
/// probe was run), and the live-chunked transcription architecture
/// (`WhisperSttService.startLiveTranscription`) re-transcribes short audio
/// chunks separately rather than the whole answer in one call, so per-segment
/// silence-gap ("pause") detection isn't attempted here — it would need
/// stitching timestamps across chunks against an API capability that hasn't
/// been confirmed to exist. WPM and filler-word count need neither: both are
/// reliable with only the pieces already on hand.
class SpeechDeliveryMetrics {
  const SpeechDeliveryMetrics({
    required this.wordsPerMinute,
    required this.fillerWordCount,
    required this.wordCount,
  });

  final double wordsPerMinute;
  final int fillerWordCount;
  final int wordCount;
}

/// Common filler words/phrases. Word-boundary, case-insensitive match.
/// "like" can be a false positive when used as a verb ("I like this") rather
/// than a filler — treat this as directional feedback, not precise
/// linguistic analysis, per this feature's own risk note.
final RegExp _fillerWordPattern = RegExp(
  r'\b(um+|uh+|erm+|like|you know)\b',
  caseSensitive: false,
);

SpeechDeliveryMetrics computeSpeechDeliveryMetrics({
  required String transcript,
  required double durationSeconds,
}) {
  final words = transcript.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final wordCount = words.length;
  final minutes = durationSeconds / 60;
  final wpm = (minutes > 0 && wordCount > 0) ? wordCount / minutes : 0.0;
  final fillerCount = _fillerWordPattern.allMatches(transcript).length;
  return SpeechDeliveryMetrics(
    wordsPerMinute: wpm,
    fillerWordCount: fillerCount,
    wordCount: wordCount,
  );
}

/// Aggregates per-answer metrics across a whole interview into one summary:
/// word-count-weighted average WPM (so a 3-word answer doesn't skew the
/// average as much as a 60-word one) and total filler words across all
/// answers. Returns null if [perAnswer] is empty (nothing to summarize).
SpeechDeliveryMetrics? aggregateSpeechDeliveryMetrics(List<SpeechDeliveryMetrics> perAnswer) {
  if (perAnswer.isEmpty) return null;
  final totalWords = perAnswer.fold<int>(0, (sum, m) => sum + m.wordCount);
  final totalFillers = perAnswer.fold<int>(0, (sum, m) => sum + m.fillerWordCount);
  if (totalWords == 0) {
    return SpeechDeliveryMetrics(wordsPerMinute: 0, fillerWordCount: totalFillers, wordCount: 0);
  }
  final weightedWpmSum = perAnswer.fold<double>(0, (sum, m) => sum + m.wordsPerMinute * m.wordCount);
  return SpeechDeliveryMetrics(
    wordsPerMinute: weightedWpmSum / totalWords,
    fillerWordCount: totalFillers,
    wordCount: totalWords,
  );
}
