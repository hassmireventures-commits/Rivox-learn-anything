class TextChunk {
  const TextChunk({
    required this.text,
    this.page,
    this.section,
    this.citationLabel,
  });

  final String text;
  final int? page;
  final String? section;
  final String? citationLabel;
}

class ChunkingStrategy {
  const ChunkingStrategy();

  static const _windowWords = 120;
  static const _overlapWords = 20;

  List<TextChunk> chunkDocument({
    required String fullText,
    required String sourceType,
    String? title,
  }) {
    final normalized = fullText.replaceAll(RegExp(r'\r\n'), '\n').trim();
    if (normalized.isEmpty) return const [];

    if (sourceType == 'resume' || sourceType == 'jd') {
      return _sectionAwareChunks(normalized, title ?? sourceType);
    }
    return _slidingWindowChunks(normalized, title ?? sourceType);
  }

  List<TextChunk> _sectionAwareChunks(String text, String label) {
    final lines = text.split('\n');
    final chunks = <TextChunk>[];
    final buffer = StringBuffer();
    String? currentSection;

    void flush() {
      final t = buffer.toString().trim();
      if (t.length < 40) {
        buffer.clear();
        return;
      }
      chunks.add(
        TextChunk(
          text: t,
          section: currentSection,
          citationLabel: currentSection != null ? '$label - $currentSection' : label,
        ),
      );
      buffer.clear();
    }

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        flush();
        continue;
      }
      if (_looksLikeHeading(trimmed)) {
        flush();
        currentSection = trimmed;
      }
      buffer.writeln(trimmed);
      if (buffer.length > 2500) flush();
    }
    flush();
    return chunks.isEmpty ? [TextChunk(text: text, citationLabel: label)] : chunks;
  }

  List<TextChunk> _slidingWindowChunks(String text, String label) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= _windowWords) {
      return [TextChunk(text: text, citationLabel: label)];
    }
    final chunks = <TextChunk>[];
    var start = 0;
    var part = 1;
    while (start < words.length) {
      final end = min(start + _windowWords, words.length);
      final slice = words.sublist(start, end).join(' ');
      chunks.add(TextChunk(text: slice, citationLabel: '$label (part $part)'));
      part++;
      if (end >= words.length) break;
      start = end - _overlapWords;
    }
    return chunks;
  }

  bool _looksLikeHeading(String line) {
    if (line.length > 80) return false;
    if (line.endsWith(':')) return true;
    if (RegExp(r'^(chapter|section|unit|module)\s+\d', caseSensitive: false).hasMatch(line)) {
      return true;
    }
    if (line == line.toUpperCase() && line.split(' ').length <= 8) return true;
    return false;
  }

  int min(int a, int b) => a < b ? a : b;
}
