/// B35 — an AI-derived chapter marker for a Daily Pack video, cached
/// alongside the video's own [DailyContentItem] JSON so it's computed once
/// per video, not re-fetched every view.
class VideoChapter {
  const VideoChapter({required this.timestampSeconds, required this.label});

  final int timestampSeconds;
  final String label;

  Map<String, dynamic> toJson() => {
        'timestampSeconds': timestampSeconds,
        'label': label,
      };

  static VideoChapter? fromJson(Map<String, dynamic> json) {
    final timestamp = (json['timestampSeconds'] as num?)?.toInt();
    final label = json['label']?.toString().trim();
    if (timestamp == null || timestamp < 0 || label == null || label.isEmpty) return null;
    return VideoChapter(timestampSeconds: timestamp, label: label);
  }
}
