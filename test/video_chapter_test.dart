import 'package:ai_quiz_app/core/services/video_chapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VideoChapter', () {
    test('toJson -> fromJson round-trips', () {
      const chapter = VideoChapter(timestampSeconds: 42, label: 'Intro to widgets');
      final decoded = VideoChapter.fromJson(chapter.toJson());
      expect(decoded, isNotNull);
      expect(decoded!.timestampSeconds, 42);
      expect(decoded.label, 'Intro to widgets');
    });

    test('fromJson rejects a missing timestampSeconds', () {
      expect(VideoChapter.fromJson({'label': 'x'}), isNull);
    });

    test('fromJson rejects a missing label', () {
      expect(VideoChapter.fromJson({'timestampSeconds': 10}), isNull);
    });

    test('fromJson rejects an empty label', () {
      expect(VideoChapter.fromJson({'timestampSeconds': 10, 'label': '   '}), isNull);
    });

    test('fromJson rejects a negative timestamp', () {
      expect(VideoChapter.fromJson({'timestampSeconds': -5, 'label': 'x'}), isNull);
    });

    test('fromJson accepts timestampSeconds 0', () {
      final decoded = VideoChapter.fromJson({'timestampSeconds': 0, 'label': 'Start'});
      expect(decoded, isNotNull);
      expect(decoded!.timestampSeconds, 0);
    });
  });
}
