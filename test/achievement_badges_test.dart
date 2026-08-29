import 'package:ai_quiz_app/data/local/repositories/stats_repository.dart';
import 'package:ai_quiz_app/shared/widgets/dashboard/achievement_badges.dart';
import 'package:flutter_test/flutter_test.dart';

DashboardStats _stats({
  int quizzesAttempted = 0,
  double accuracy = 0,
  double averageScore = 0,
  int topicsCovered = 0,
  int totalQuestionsSolved = 0,
  int currentStreak = 0,
  int longestStreak = 0,
}) {
  return DashboardStats(
    quizzesAttempted: quizzesAttempted,
    accuracy: accuracy,
    averageScore: averageScore,
    topicsCovered: topicsCovered,
    totalQuestionsSolved: totalQuestionsSolved,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    weeklyActivity: const [],
    activityTrend: const [],
    difficultyDistribution: const {},
    topicBreakdown: const {},
    recentQuizzes: const [],
  );
}

AchievementDef _byId(String id) => kAchievements.firstWhere((a) => a.id == id);

void main() {
  group('kAchievements', () {
    test('has 8 fixed milestones with unique ids', () {
      expect(kAchievements.length, 8);
      final ids = kAchievements.map((a) => a.id).toSet();
      expect(ids.length, kAchievements.length);
    });

    group('streak_3', () {
      final def = _byId('streak_3');

      test('locked one below threshold', () {
        final stats = _stats(longestStreak: 2);
        expect(def.isUnlocked(stats), isFalse);
        expect(def.progressLabel(stats), '2/3');
      });

      test('unlocked exactly at threshold', () {
        final stats = _stats(longestStreak: 3);
        expect(def.isUnlocked(stats), isTrue);
      });

      test('stays unlocked even if current streak has since broken', () {
        // Achievements are based on the longest streak ever reached, not the
        // current one - they should not be revoked.
        final stats = _stats(currentStreak: 0, longestStreak: 3);
        expect(def.isUnlocked(stats), isTrue);
      });
    });

    group('streak_7', () {
      final def = _byId('streak_7');

      test('locked one below threshold', () {
        expect(def.isUnlocked(_stats(longestStreak: 6)), isFalse);
      });

      test('unlocked exactly at threshold', () {
        expect(def.isUnlocked(_stats(longestStreak: 7)), isTrue);
      });
    });

    group('streak_30', () {
      final def = _byId('streak_30');

      test('locked one below threshold', () {
        final stats = _stats(longestStreak: 29);
        expect(def.isUnlocked(stats), isFalse);
        expect(def.progressLabel(stats), '29/30');
      });

      test('unlocked exactly at threshold', () {
        expect(def.isUnlocked(_stats(longestStreak: 30)), isTrue);
      });
    });

    group('questions_50', () {
      final def = _byId('questions_50');

      test('locked one below threshold', () {
        final stats = _stats(totalQuestionsSolved: 49);
        expect(def.isUnlocked(stats), isFalse);
        expect(def.progressLabel(stats), '49/50');
      });

      test('unlocked exactly at threshold', () {
        expect(def.isUnlocked(_stats(totalQuestionsSolved: 50)), isTrue);
      });
    });

    group('questions_200', () {
      final def = _byId('questions_200');

      test('locked one below threshold', () {
        expect(def.isUnlocked(_stats(totalQuestionsSolved: 199)), isFalse);
      });

      test('unlocked exactly at threshold', () {
        expect(def.isUnlocked(_stats(totalQuestionsSolved: 200)), isTrue);
      });
    });

    group('topics_5', () {
      final def = _byId('topics_5');

      test('locked one below threshold', () {
        final stats = _stats(topicsCovered: 4);
        expect(def.isUnlocked(stats), isFalse);
        expect(def.progressLabel(stats), '4/5');
      });

      test('unlocked exactly at threshold', () {
        expect(def.isUnlocked(_stats(topicsCovered: 5)), isTrue);
      });
    });

    group('quizzes_10', () {
      final def = _byId('quizzes_10');

      test('locked one below threshold', () {
        final stats = _stats(quizzesAttempted: 9);
        expect(def.isUnlocked(stats), isFalse);
        expect(def.progressLabel(stats), '9/10');
      });

      test('unlocked exactly at threshold', () {
        expect(def.isUnlocked(_stats(quizzesAttempted: 10)), isTrue);
      });
    });

    group('accuracy_80', () {
      final def = _byId('accuracy_80');

      test('locked one point below threshold', () {
        final stats = _stats(accuracy: 79, quizzesAttempted: 5);
        expect(def.isUnlocked(stats), isFalse);
        expect(def.progressLabel(stats), '79/80%');
      });

      test('unlocked exactly at threshold', () {
        expect(
          def.isUnlocked(_stats(accuracy: 80, quizzesAttempted: 5)),
          isTrue,
        );
      });

      test('locked with default zero-quiz stats (no divide-by-zero surprises)', () {
        expect(def.isUnlocked(_stats()), isFalse);
      });
    });
  });
}
