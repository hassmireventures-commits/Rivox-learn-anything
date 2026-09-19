import 'package:ai_quiz_app/core/services/speech_delivery_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeSpeechDeliveryMetrics', () {
    test('computes words-per-minute from word count and duration', () {
      // 10 words in 30 seconds = 20 wpm.
      final metrics = computeSpeechDeliveryMetrics(
        transcript: 'one two three four five six seven eight nine ten',
        durationSeconds: 30,
      );
      expect(metrics.wordCount, 10);
      expect(metrics.wordsPerMinute, closeTo(20, 0.01));
    });

    test('returns 0 wpm when duration is 0', () {
      final metrics = computeSpeechDeliveryMetrics(
        transcript: 'some words here',
        durationSeconds: 0,
      );
      expect(metrics.wordsPerMinute, 0);
    });

    test('returns 0 wpm and 0 words for an empty transcript', () {
      final metrics = computeSpeechDeliveryMetrics(transcript: '   ', durationSeconds: 10);
      expect(metrics.wordCount, 0);
      expect(metrics.wordsPerMinute, 0);
      expect(metrics.fillerWordCount, 0);
    });

    test('counts filler words case-insensitively with word boundaries', () {
      final metrics = computeSpeechDeliveryMetrics(
        transcript: 'Um, so like, I um think this is, uh, you know, correct',
        durationSeconds: 60,
      );
      // um, like, um, uh, you know = 5 filler hits
      expect(metrics.fillerWordCount, 5);
    });

    test('does not count "like" inside another word', () {
      final metrics = computeSpeechDeliveryMetrics(
        transcript: 'I dislike unlikely likelihoods',
        durationSeconds: 60,
      );
      expect(metrics.fillerWordCount, 0);
    });
  });

  group('aggregateSpeechDeliveryMetrics', () {
    test('returns null for an empty list', () {
      expect(aggregateSpeechDeliveryMetrics([]), isNull);
    });

    test('word-count-weights the average wpm across answers', () {
      // Answer A: 100 wpm over 10 words. Answer B: 50 wpm over 90 words.
      // Weighted average = (100*10 + 50*90) / 100 = 55 wpm.
      final result = aggregateSpeechDeliveryMetrics([
        const SpeechDeliveryMetrics(wordsPerMinute: 100, fillerWordCount: 1, wordCount: 10),
        const SpeechDeliveryMetrics(wordsPerMinute: 50, fillerWordCount: 2, wordCount: 90),
      ]);
      expect(result, isNotNull);
      expect(result!.wordsPerMinute, closeTo(55, 0.01));
      expect(result.fillerWordCount, 3);
      expect(result.wordCount, 100);
    });

    test('sums filler words even when total word count is 0', () {
      final result = aggregateSpeechDeliveryMetrics([
        const SpeechDeliveryMetrics(wordsPerMinute: 0, fillerWordCount: 2, wordCount: 0),
      ]);
      expect(result, isNotNull);
      expect(result!.fillerWordCount, 2);
      expect(result.wordsPerMinute, 0);
    });
  });
}
