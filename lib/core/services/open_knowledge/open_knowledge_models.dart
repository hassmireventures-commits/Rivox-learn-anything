/// A single hit from a public knowledge API (Wikipedia, arXiv, etc.).
class OpenKnowledgeHit {
  const OpenKnowledgeHit({
    required this.source,
    required this.title,
    required this.summary,
    this.url,
  });

  final String source;
  final String title;
  final String summary;
  final String? url;

  String get promptLine {
    final link = url != null && url!.isNotEmpty ? ' ($url)' : '';
    return '$source: $title — $summary$link';
  }
}
